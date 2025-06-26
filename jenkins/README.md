# Jenkins with Docker Support

This setup provides a Jenkins instance with Docker support, allowing you to run Docker commands in Jenkins pipelines.

## Features

- Jenkins LTS with Docker CLI installed
- Docker socket mounted from host
- Proper permissions for Jenkins user to access Docker
- Persistent Jenkins home volume

## Setup

1. Build and start the Jenkins container:
```bash
docker-compose up -d --build
```

2. Get the initial admin password:
```bash
docker logs jenkins
```
Look for the line that starts with "Jenkins initial admin password:"

3. Access Jenkins at `http://localhost:8080`

4. Install the Docker Pipeline plugin in Jenkins:
   - Go to Manage Jenkins > Manage Plugins
   - Search for "Docker Pipeline" and install it

## Usage in Jenkins Pipelines

You can now use Docker commands in your Jenkins pipelines:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('my-app:latest', '.')
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                script {
                    docker.image('my-app:latest').run('-p 8080:8080', '--name my-app-container')
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up containers
                sh 'docker rm -f my-app-container || true'
            }
        }
    }
}
```

Or using shell commands:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Docker Commands') {
            steps {
                sh 'docker --version'
                sh 'docker ps'
                sh 'docker build -t my-app .'
                sh 'docker run --rm my-app'
            }
        }
    }
}
```

## Troubleshooting

If you encounter permission issues:

1. Check if the docker group exists:
```bash
docker exec jenkins groups jenkins
```

2. Verify Docker socket permissions:
```bash
ls -la /var/run/docker.sock
```

3. Restart the container if needed:
```bash
docker-compose restart
```

## Security Notes

- The Jenkins container runs with access to the host's Docker socket
- This gives Jenkins the ability to run any Docker command on the host
- Consider using Docker-in-Docker (DinD) for more isolated environments in production 