FROM maven:3.8.4-jdk-8

WORKDIR /

RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello app

WORKDIR /app

RUN mvn package

WORKDIR /opt/tomcat

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.58/bin/apache-tomcat-9.0.58.tar.gz

RUN tar zxvf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components 1