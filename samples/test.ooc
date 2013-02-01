use uriparser

import structs/ArrayList

test: func (originals: ArrayList<String>) {
    originals each(|original|
        parsed := URI new(original)
        queryParts := ArrayList<String> new()
        parsed query each(|k, v|
            queryParts add("%s=%s" format(k, v))
        )
        generatedQueryString := queryParts join('&')
        //"%s\n%s\n%s\n%s\n\n" printfln(original, parsed full, generatedQueryString, parsed queryString)
        "%s\n%s\n\n" printfln(original, parsed full)
    )
}

test([
    "http://foo:bar@duckinator.net:8000/test?a#b"
    "http://foo:bar@duckinator.net:8000/test?a"
    "http://foo:bar@duckinator.net:8000/test#b"
    "http://foo:bar@duckinator.net:8000/test"
    "http://foo:bar@duckinator.net/test?a#b"
    "http://foo:bar@duckinator.net/test?a"
    "http://foo:bar@duckinator.net/test#b"
    "http://duckinator.net:8000/test?a#b"
    "http://duckinator.net:8000/test?a"
    "http://duckinator.net:8000/test#b"
    "http://duckinator.net:8000/test"
    "http://duckinator.net/test?a#b"
    "http://duckinator.net/test?a"
    "http://duckinator.net/test#b"
    "http://foo:bar@72.219.215.216:8000/test?a#b"
    "http://foo:bar@72.219.215.216:8000/test?a"
    "http://foo:bar@72.219.215.216:8000/test#b"
    "http://foo:bar@72.219.215.216:8000/test"
    "http://foo:bar@72.219.215.216/test?a#b"
    "http://foo:bar@72.219.215.216/test?a"
    "http://foo:bar@72.219.215.216/test#b"
    "http://72.219.215.216:8000/test?a#b"
    "http://72.219.215.216:8000/test?a"
    "http://72.219.215.216:8000/test#b"
    "http://72.219.215.216:8000/test"
    "http://72.219.215.216/test?a#b"
    "http://72.219.215.216/test?a"
    "http://72.219.215.216/test#b"
    "http://duckinator.net/test?a=b&c==d&e=f=g"
    "http://duckinator.net/test?a=b&c="
    "http://duckinator.net/test?a=b&c"
    "magnet:?xl=10826029&dn=mediawiki-1.15.1.tar.gz&xt=urn:tree:tiger:7N5OAMRNGMSSEUE3ORHOKWN4WWIQ5X4EBOOTLJY"
    "ftp://ftp.is.co.za/rfc/rfc1808.txt"
    "http://www.ietf.org/rfc/rfc2396.txt"
    "mailto:John.Doe@example.com"
    "news:comp.infosystems.www.servers.unix"
    "tel:+1-816-555-1212"
    "telnet://192.0.2.16:80/"
    "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
    "example://a/b/c/%7Bfoo%7D"
    "eXAMPLE://a/./b/../b/%63/%7bfoo%7d"
    "eXAMPLE://A/./b/../b/%63/%7bfoo%7d"
    "http://example.com/a/./b"
    "http://example.com/a/./"
    "http://example.com/a/."
    "http://example.com/a/../b"
    "http://example.com/a/../"
    "http://example.com/a/.."
    "http://example.com/a/./../b"
    "http://example.com/a/./../"
    "http://example.com/a/./.."
    "http://example.com/./b"
    "http://example.com/./"
    "http://example.com/."
    "http://example.com/../b"
    "http://example.com/../"
    "http://example.com/.."
    "http://example.com/./../b"
    "http://example.com/./../"
    "http://example.com/./.."
    "http://example.com/././../b"
    "http://example.com/././../"
    "http://example.com/././.."
    "http://example.com/././b"
    "http://example.com/././"
    "http://example.com/./."
    "http://example.com"
    "http://example.com/"
    "http://example.com:/"
    "http://example.com:80/"
    "ftp://cnn.example.com&story=breaking_news@10.0.0.1/top_story.htm"
    "ldap://[2001:db8::7]/c=GB?objectClass?one"
    "http://example.com:-1"
] as ArrayList<String>)

