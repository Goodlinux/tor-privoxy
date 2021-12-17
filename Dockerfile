FROM alpine:latest
MAINTAINER Ludovic MAILLET <Ludo.goodlinux@gmail.com>

RUN apk -U add tor privoxy tini
EXPOSE 8118 9050
ENV  TZ=Europe/Paris

#Construction of redirection and php use for nginx
RUN echo "server { " > /etc/nginx/http.d/default.conf  \
    &&  echo "        listen 80 default_server; " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        listen [::]:80 default_server; " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        index index.php index.html index.htm; " >> /etc/nginx/http.d/default.conf	  \
    &&  echo "        root /var/www/zipsme; " >> /etc/nginx/http.d/default.conf		\
    &&  echo "		if (!-e \$request_filename){ " >> /etc/nginx/http.d/default.conf		\
    &&  echo "			rewrite ^/([A-Za-z0-9-]+)/?$ /redirect.php?url_name=\$1 break; } " >> /etc/nginx/http.d/default.conf	\
    &&  echo "    location ~ \.php$ { " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        try_files \$uri =404; " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        fastcgi_pass localhost:9000; " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        fastcgi_index index.php; " >> /etc/nginx/http.d/default.conf	\
    &&  echo "        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; " >> /etc/nginx/http.d/default.conf		\
    &&  echo "        include fastcgi_params;    } " >> /etc/nginx/http.d/default.conf	\
    &&  echo "}  " >> /etc/nginx/http.d/default.conf

#Import project from GitHub
RUN git clone https://github.com/Goodlinux/zipsme.git /var/www/zipsme/ && rm /var/www/zipsme/Dockerfile && touch /var/www/zipsme/error.txt

#Construction of entrypoint
RUN echo "#! /bin/sh" > /usr/local/bin/entrypoint.sh \
	&& echo "echo mise a jour de la config php"  >>  /usr/local/bin/entrypoint.sh  \
	&& echo "tini --runserv /etc/service"  >>  /usr/local/bin/entrypoint.sh  \
	&& echo "exec /bin/sh" >> /usr/local/bin/entrypoint.sh  \
	&& chmod a+x /usr/local/bin/*

CMD /usr/local/bin/entrypoint.sh
