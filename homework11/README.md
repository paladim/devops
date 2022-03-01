### run jenkins
```
docker build -f JenkinsDockerfile . -t myjenkins:latest

docker volume create jenkins

docker run -p 8081:8080 -e JENKINS_HOME=/opt/tomcat/jenkins -v jenkins:/opt/tomcat/jenkins myjenkins:latest
```

### run nexus
```
docker volume create --name nexus-data

docker run -d -p 8082:8081 -p 8123:8123 -v nexus-data:/nexus-data sonatype/nexus3
```

#### build jenkins agent
```
docker login -u admin -p admin 192.168.0.103:8123

```
```
cat /etc/docker/daemon.json 
{
    "insecure-registries" : [ "192.168.0.103:8123" ]
}
```
```
docker build -f JenkinsAgentDockerfile . -t jenkins-agent:latest

docker image tag jenkins-agent:latest 192.168.0.103:8123/docker/jenkins-agent:latest

docker push 192.168.0.103:8123/docker/jenkins-agent:latest
```
