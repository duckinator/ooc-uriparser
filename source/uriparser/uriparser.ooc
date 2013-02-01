import structs/ArrayList, structs/HashMap, text/StringTokenizer

/**
 * URIs parser implemented in pure ooc
 *
 * Generic URI format:  scheme:[//][authority][?query][#fragment]
 *                      scheme:[//][userinfo@]path[:port][?query][#fragment]
 *
 * NOTE: This can not handle magnet URIs very well at all:
 *+        http://en.wikipedia.org/wiki/Magnet_URI_scheme
 */
URI: class {
    _doubleSlashStart := false // So we know whether or not to add preceding //
    _portInOriginal   := false // So we know whether or not to add the port
    raw, scheme, host, authority, full: String
    port        := -1 // Why? Idk. More sensible than 80, to me.
    path        := ""
    userinfo    := ""
    queryString := ""
    fragment    := ""
    query: HashMap<String, String> // for: query[key] //=> val

    init: func (=raw) {
        parts: ArrayList<String>
        tmp: String

        // Get scheme
        parts  = raw split(':', 2)
        scheme = parts[0]

        // Skip optional "//" after colon, if it's there
        if (parts[1][0..2] == "//") {
            tmp = parts[1][2..-1]
            _doubleSlashStart = true
        } else {
            tmp = parts[1]
        }

        // Get userinfo, if it's there
        if (tmp contains?('@')) {
            parts = tmp split('@')
            userinfo = parts[0]
            tmp = parts[1]
        }

        // Get host
        if (tmp contains?('[') && tmp contains?(']') &&
            (tmp indexOf('[') < tmp indexOf(']'))){
            parts = tmp split(']', 2)
            host  = parts[0] + ']'
            tmp   = parts[1]
        } else if (tmp contains?(':') && ((tmp indexOf(':') < tmp indexOf('/')) ||
                                  (!tmp contains?('/') && tmp split(':') size == 2))\
           ) {
            // if we're here, we have "scheme://userinfo@host:port/path"
            parts = tmp split(':', 2)
            host  = parts[0]
            tmp   = ":" + parts[1]
        } else if (tmp contains?('/')) {
            // if we're here, we have "scheme://userinfo@host/path"
            parts = tmp split('/', 2)
            host  = parts[0]
            if (tmp length() > 1)
                tmp = "/" + parts[1]
            else
                tmp = "/"
        } else {
            // if we're here, we have "scheme://userinfo@host"
            host = tmp
            tmp  = ""
        }
        
        // Get port
        if (tmp contains?(':')) {
            _portInOriginal = true // We have a port in the URI
            parts = tmp split(':', 2)
            tmp = parts[1]
            if (tmp[0] == '/' || tmp[0] == '?' || tmp[0] == '#') {
                // TODO: Can this be done better?
                _portInOriginal = false
            } else if (tmp contains?('/')) {
                // if we're here, we have "scheme://host:port/path"
                parts = tmp split('/', 2)
                port  = parts[0] toInt()
                tmp   = "/" + parts[1]
            } else if (tmp contains?('?')) {
                // if we're here, we have "scheme://host:port?query"
                parts = tmp split('?', 2)
                port  = parts[0] toInt()
                tmp   = "?" + parts[1]
            } else if (tmp contains?('#')) {
                // if we're here, we have "scheme://host:port#fragment"
                parts = tmp split('#', 2)
                port  = parts[0] toInt()
                tmp   = "#" + parts[1]
            } else {
                // if we're here, we have "scheme://host:port"
                port = tmp toInt()
            }
        }
        
        if (!_portInOriginal) {
            // No port specified. Handle default port on a per-scheme basis. Argh!
            // TODO: Use getservent() and friends to deal with this
            port = match  (scheme) {
                case "http"   => 80
                case "https"  => 443
                case => -1
            }
        }
        
        if(_portInOriginal && port <= 0) {
            Exception new("Invalid port \"%i\"" format(port)) throw()
        }
        
        // Get path
        if (tmp indexOf('/') < tmp indexOf('?') && 
            (!tmp contains?('#') || tmp indexOf('?') < tmp indexOf('#'))) {
            // if we're here, we have scheme://.../path?query#fragment
            parts = tmp split('?', 2)
            path  = parts[0]
            tmp   = "?" + parts[1]
        } else if (tmp indexOf('/') < tmp indexOf('#')) {
            // if we're here, we have scheme://.../path#fragment
            parts = tmp split('#', 2)
            path  = parts[0]
            tmp   = "#" + parts[1]
        } else {
            // if we're here, we have scheme://.../path
            path  = tmp
        }
        
        // Get querystring and fragment
        if (tmp contains?('?') && tmp indexOf('?') < tmp indexOf('#')) {
            // if we're here, we have scheme://.../path?query#fragment
            parts       = tmp split('?', 2)
            queryParts := parts[1] split('#', 2)
            queryString = queryParts[0]
            fragment    = queryParts[1]
            tmp         = ""
        } else if (tmp contains?('#')) {
            // if we're here, we have scheme://.../path#fragment
            parts    = tmp split('#', 2)
            fragment = parts[1]
            tmp      = ""
        } else if (tmp contains?('?')) {
            // if we're here, we have scheme://.../path?query
            parts       = tmp split('?', 2)
            queryString = parts[1]
            tmp         = ""
        }
        
        if (_doubleSlashStart) {
            scheme = scheme toLower()
            host   = host toLower()
        }
        
        if (path empty?() && _doubleSlashStart)
            path = "/"

        if ((path size - 1) >= 2) {
            i := 0
            while ((i + 1) < path size) {
                if (path[i] == '/' && path[i+1] == '.') {
                    if ((path size -1) < (i + 2)) // (path size - 1) < (i + 2)
                        path = path[0..i]
                    else if ((path size - 1) >= (i + 2) && path[i+2] != '.')
                        path = path[0..i] + path[(i+2)..-1]
                }
                i += 1
            }
        }
        
        full   = getFullURI()
        query  = getQuery()
    }

    getFullURI: func -> String {
        str := scheme + ":"
        
        if (_doubleSlashStart)
            str += "//"
        
        if (!userinfo empty?())
            str += userinfo + "@"
        
        str += host
        
        if (_portInOriginal)
            str += ":" + port toString()
        
        str += path
        
        if (!queryString empty?())
            str += "?" + queryString
        
        if (!fragment empty?())
            str += "#" + fragment
        
        str        
    }

    getQuery: func -> HashMap<String, String> {
        q := HashMap<String, String> new()
        queryParts := queryString split('&')
        queryParts each(|x|
            parts := x split('=', 2)
            if (parts size == 2) {
                if (parts[1] == null)
                    parts[1] = ""
                
                q add(parts[0], parts[1])
            }
        )
        q
    }
}

