FROM home-app-1-build as builder

FROM alpine:3.15.0

WORKDIR /opt/tomcat

RUN apk add openjdk8-jre-base

COPY --from=builder /opt/tomcat/ /opt/tomcat/

COPY --from=builder /app/target/*.war /opt/tomcat/webapps/

WORKDIR /opt/tomcat/ROOT

COPY Config.properties .

WORKDIR /opt/tomcat/

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]