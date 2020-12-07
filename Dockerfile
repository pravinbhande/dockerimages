FROM centos:8

LABEL maintainer="Ravi Durge"  dockerfile_version="1.0.0"

COPY ./nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum install -y nginx && \
    yum clean all && \
    rm -rf /etc/nginx /usr/share/nginx/html && \
    mkdir -p /etc/nginx /usr/share/nginx/html && \
    mkdir -p /etc/nginx/ssl && \
    mkdir -p /startup-hooks && \
    adduser nginxadm && \
    chown -R  nginxadm /etc/nginx /startup-hooks /usr/share/nginx /var/log/nginx /var/run /run /etc/nginx/ssl /var/lib/nginx/

#VOLUME ["/etc/nginx/ssl", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

COPY ./conf/ /etc/nginx/
COPY ./html/ /usr/share/nginx/html
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# Create a self-signed certificate so the build doesn't blow up by default.
# If actually using SSL, a user will likely want to provide actual certificate
# files for the target deployment.
RUN openssl \
      req \
      -x509 \
      -nodes \
      -newkey rsa:4096 \
      -keyout /etc/nginx/ssl/server.key \
      -out /etc/nginx/ssl/server.crt \
      -days 365 \
      -subj '/C=IN/ST=Example_street/L=Example_location/O=Organization/OU=OrgUnit/CN=localhost' && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chmod 444 /etc/nginx/ssl/server.crt && \
    chmod 444  /etc/nginx/ssl/server.key && chmod 400 /etc/nginx/ssl/dhparam.pem

EXPOSE 8080
EXPOSE 8443
STOPSIGNAL SIGQUIT

USER  nginxadm
#CMD [ "/docker-entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
