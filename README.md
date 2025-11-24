**Trend App – AWS EKS Deployment with Jenkins**

link : https://docs.google.com/document/d/114RStvA92SmiU2uzsvMW-4LR6Yjq13mKCyXYyIvaBOM/edit?tab=t.0#heading=h.om483ueayxd7


**Architecture**

GitHub Repository -> Jenkins -> Docker Build -> DockerHub -> EKS Cluster -> LoadBalancer

**Project Structure**

<img width="346" height="409" alt="image" src="https://github.com/user-attachments/assets/7eabc373-8a2a-43b2-bc68-cd4857c9b57e" />


**1. Clone & Prepare React Application**

Steps:

Fork the repo: Trend

git clone https://github.com/Jegadeeshanp/GuviProject-Trend.git

Verify the React app runs locally:

npm install

npm start

App should run on http://13.48.84.237:3000.

**2. Dockerize the React App**

<img width="940" height="491" alt="image" src="https://github.com/user-attachments/assets/e95c7f93-36fc-4d45-88f5-40c6a8049a94" />

<img width="940" height="505" alt="image" src="https://github.com/user-attachments/assets/69e44353-1f9e-4c39-a18f-eb1d59953554" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/c486cc86-6ed1-4815-b0a5-178644533c31" />

<img width="940" height="431" alt="image" src="https://github.com/user-attachments/assets/9916d4fa-a662-4485-8d3a-eec5ee6a9f1d" />


**3. Terraform (Infrastructure Setup)**

Terraform files inside /terraform:

1. main.tf
2. variables.tf
3. outputs.tf
4. eks-cluster.tf

Commands:

terraform init

terraform plan

terraform apply -auto-approve

Terraform Logs: https://github.com/Jegadeeshanp/GuviProject-Trend/blob/main/Terraform_Logs.txt

Creates:
VPC : vpc-0b83eefc414ea422b
<img width="940" height="484" alt="image" src="https://github.com/user-attachments/assets/6908734c-c0ba-4c0b-8c64-262df42eb0c6" />

EKS cluster : trend-eks-cluster

Endpoint: https://81D0A9550FFF5891B119E987F3619E40.gr7.eu-north-1.eks.amazonaws.com

<img width="940" height="475" alt="image" src="https://github.com/user-attachments/assets/d12d3458-2490-4c90-be52-34a74611913a" />


<img width="940" height="434" alt="image" src="https://github.com/user-attachments/assets/99b06f9f-1134-431b-8381-1080622d804d" />

EC2 Jenkins server

<img width="940" height="318" alt="image" src="https://github.com/user-attachments/assets/36ed52c5-5b1a-4084-a879-7f608bb8f5ae" />

Load Balancer 

http://af8f2975c265344b0a83fc93a4977d53-1236729486.eu-north-1.elb.amazonaws.com/

<img width="940" height="489" alt="image" src="https://github.com/user-attachments/assets/7e72f024-00dd-4349-bb31-2677539b7718" />

IAM User

<img width="940" height="441" alt="image" src="https://github.com/user-attachments/assets/c0ba933a-1c4d-4f14-8035-d5abc28924bb" />



**4. Jenkins Server Setup**

<img width="940" height="499" alt="image" src="https://github.com/user-attachments/assets/b938d8cc-1c90-40c3-a6e6-202f8df1b7cd" />

<img width="940" height="523" alt="image" src="https://github.com/user-attachments/assets/3ff922cc-6089-4ef9-b18f-44865120f823" />

Jenkinsfile:
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


**5. Kubernetes Deployment**

k8s/deployment.yaml

k8s/service.yaml


**6. Monitoring**

CloudWatch Container Insights

<img width="814" height="94" alt="image" src="https://github.com/user-attachments/assets/886e75b8-9093-489f-aed1-6c080652d605" />

<img width="940" height="354" alt="image" src="https://github.com/user-attachments/assets/b11b6811-0346-4115-b0ec-bacb4147b7f3" />

<img width="940" height="338" alt="image" src="https://github.com/user-attachments/assets/9acec21c-f727-4799-a564-ce559a3f285b" />

<img width="940" height="440" alt="image" src="https://github.com/user-attachments/assets/388d7d1d-9119-49b8-ab26-c24a5c552c4d" />

<img width="940" height="464" alt="image" src="https://github.com/user-attachments/assets/310204d3-9e3a-4f32-925d-9d45c842a487" />


**7. GitHub Version Control Setup**

Files :
1. .gitignore
2. .dockerignore


**Jenkins Success & logs**

Success Logs: https://github.com/Jegadeeshanp/GuviProject-Trend/blob/main/Jenkin_Success_Log%2311.txt


<img width="940" height="474" alt="image" src="https://github.com/user-attachments/assets/743424e9-a62b-4135-b243-7eb22c953851" />

<img width="940" height="464" alt="image" src="https://github.com/user-attachments/assets/825938ed-9215-43e4-9c67-b5eb54b287f6" />

<img width="940" height="482" alt="image" src="https://github.com/user-attachments/assets/85a923cd-47c7-42ff-9dba-60c909c0f3ad" />

<img width="940" height="543" alt="image" src="https://github.com/user-attachments/assets/99e88e5b-aa3a-4794-8ab3-26b66edaa4c0" />




















