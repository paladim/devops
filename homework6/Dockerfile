FROM ubuntu:20.04

RUN apt-get update

RUN apt-get install default-jdk -y
RUN apt-get install wget -y
RUN apt-get install git-core -y
RUN apt-get install maven -y

RUN useradd tomcat -U -s /bin/false -d /opt/tomcat -m

WORKDIR /opt/tomcat

USER tomcat

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.58/bin/apache-tomcat-9.0.58.tar.gz

RUN tar zxvf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components 1

RUN git clone https://github.com/koddas/war-web-project

WORKDIR /opt/tomcat/war-web-project

RUN mvn package

RUN cp /opt/tomcat/war-web-project/target/wwp-1.0.0.war /opt/tomcat/webapps

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]