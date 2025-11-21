pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-creds')  // Jenkins credential
        IMAGE = "jegadeeshanjeggy/trend-app:v1"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "trend-cluster-new"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Jegadeeshanp/GuviProject-Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $IMAGE .
                """
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh """
                echo \$DOCKERHUB_PSW | docker login -u \$DOCKERHUB_USR --password-stdin
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                docker push $IMAGE
                """
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh """
                aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml

                echo "Wait for rollout..."
                kubectl rollout status deployment/trend-app-deployment || true

                echo "Current Pods:"
                kubectl get pods -o wide

                echo "Services:"
                kubectl get svc -o wide
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment to EKS Successful!'
        }
        failure {
            echo 'Pipeline Failed! Check logs.'
        }
    }
}

