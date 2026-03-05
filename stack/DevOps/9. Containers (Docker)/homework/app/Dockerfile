FROM alpine:latest

RUN apk add --no-cache nginx

COPY nginx/default.conf /etc/nginx/http.d/default.conf
COPY html/ /usr/share/nginx/html/

EXPOSE 80

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
