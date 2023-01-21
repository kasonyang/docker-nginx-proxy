upstream upstream_server_{{domain}} {
    {% for us in upstream %}
    server {{us}};
    {% endfor %}
}

server {
    server_name {{domain}};
    listen    80;
    {% if ssl_key %}
    listen    443 ssl http2;
    ssl_certificate      {{ssl_cert}};
    ssl_certificate_key  {{ssl_key}};
    {% endif %}

    location ^~ /.well-known/ {
        root /usr/share/nginx/html;
    }

    location / {
        # By default, proxy_pass will rewrite Host header
        {% if upstream_host %}
            proxy_set_header Host {{upstream_host}};
        {% else %}
            proxy_set_header Host $host;
        {% endif %}
        proxy_pass http://upstream_server_{{domain}};
        proxy_http_version 1.1;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

}

