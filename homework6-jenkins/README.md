# build

`docker build . -t ubuntu/tomcat`

# run

## create volume

`docker volume create jenkins`

## run

`docker run -p 8080:8080 -e JENKINS_HOME=/opt/tomcat/jenkins -v jenkins:/opt/tomcat/jenkins ubuntu/tomcat`