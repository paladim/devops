FROM my/javabuild as builder

FROM alpine:3.15.0

WORKDIR /opt/tomcat

RUN apk add openjdk8-jre-base

COPY --from=builder /opt/tomcat/ /opt/tomcat/

COPY --from=builder /app/target/hello-1.0.war /opt/tomcat/webapps/

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]

