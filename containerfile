FROM registry.access.redhat.com/ubi9
RUN dnf install -y httpd
WORKDIR /var/www/html
RUN echo "It is a test website running by registry.access.redhat.com/ubi9" > index.html
CMD ["httpd", "-D", "FOREGROUND"]
EXPOSE 80
