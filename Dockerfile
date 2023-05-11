FROM alpine:latest
LABEL maintainer="casey@geekbleek.com"
RUN apk add nginx
RUN mkdir -p /run/nginx
RUN touch /run/nginx/nginx.pid
COPY default.conf /etc/nginx/http.d/default.conf
COPY network.local.pem /etc/ssl/certs/
COPY network.local.key /etc/ssl/private/
EXPOSE 80
EXPOSE 443
# RUN COMMAND
STOPSIGNAL SIGQUIT
CMD ["/bin/sh", "-c", "nginx -g 'daemon off;'"]