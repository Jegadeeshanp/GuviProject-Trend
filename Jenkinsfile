pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-creds')  
        IMAGE = "jegadeeshanjeggy/trend-app:v1"
        AWS_REGION = "eu-north-1"                   
        CLUSTER_NAME = "trend-cluster-new"
        KUBECONFIG_PATH = "/var/lib/jenkins/.kube/config"
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
                echo "Updating kubeconfig for EKS cluster $CLUSTER_NAME in region $AWS_REGION..."

                mkdir -p /var/lib/jenkins/.kube

                aws eks update-kubeconfig \
                    --name $CLUSTER_NAME \
                    --region $AWS_REGION \
                    --kubeconfig $KUBECONFIG_PATH

                echo "KUBECONFIG file generated."
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                export KUBECONFIG=$KUBECONFIG_PATH

                echo "Applying Kubernetes manifests..."
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml

                echo "Waiting for rollout..."
                kubectl rollout status deployment/trend-app-deployment --timeout=180s || true

                echo "Pods:"
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

