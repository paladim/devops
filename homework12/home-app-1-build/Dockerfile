FROM maven:3.8.4-jdk-8

ADD https://api.github.com/repos/shephertz/App42PaaS-Java-MySQL-Sample/git/refs/heads/master version.json
RUN git clone https://github.com/shephertz/App42PaaS-Java-MySQL-Sample -b master app

WORKDIR /app

RUN mvn package

WORKDIR /opt/tomcat

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.58/bin/apache-tomcat-9.0.58.tar.gz

RUN tar zxvf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components 1