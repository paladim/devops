#### BUILD

docker build . -t ubuntu/tomcat

#### RUN

docker volume create jenkins

docker run -p 8080:8080 -e JENKINS_HOME=/opt/tomcat/jenkins -v jenkins:/opt/tomcat/jenkins ubuntu/tomcat