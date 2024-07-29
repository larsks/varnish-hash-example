vcl 4.0;

import std;
import directors;
import cookie;
import header;

backend server1 {
        .host = "backend1:80";
        .probe = {
                .url = "/";
                .interval = 5s;
                .timeout = 5s;
                .window = 5;
                .threshold = 3;
        }
}

backend server2 {
        .host = "backend2:80";
        .probe = {
                .url = "/";
                .interval = 5s;
                .timeout = 5s;
                .window = 5;
                .threshold = 3;
        }
}


sub vcl_init {
        new cluster1 = directors.hash();
        cluster1.add_backend(server1, 1);
        cluster1.add_backend(server2, 1);
}


sub vcl_recv {
        if(req.url ~ "^/solr"){
                return(synth(404,""));
        }


        if ( (req.url ~ "images.html" && req.url !~ "nocache") || (req.url ~ "\.(png|gif|jpg|jpeg|swf|css|js)$") ) {
                unset req.http.cookie;
        }

        cookie.parse(req.http.cookie);
        if (cookie.get("JSESSIONID")) {
                set req.http.sticky = cookie.get("JSESSIONID");
        } else {
                set req.http.sticky = std.random(1, 100);
        }

        set req.backend_hint = cluster1.backend(req.http.sticky);
}


sub vcl_deliver {
        if (req.http.sticky) {
                header.append(resp.http.Set-Cookie,"sticky=bar" + req.http.sticky + ";   Expires=" + cookie.format_rfc1123(now, 60m));
        }
}
