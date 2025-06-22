pipeline{
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'nodejs16'
    }
    environment{
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('checkout from GIT'){
            steps{
                git credentialsId: 'github-token',  branch: 'master', url:'https://github.com/pguleria52-devops/reddit-clone.git'
            }
        }
        stage("SonarQube Analysis"){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Reddit \
                    -Dsonar.projectKey=Reddit '''
                }
            }
        }
        stage("Quality Gate"){
            steps{
                waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
            }
        }
        stage("Install Dependencies"){
            steps{
                sh "npm install"
            }
        }
        stage("OWASP FS SCAN"){
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "docker build -t reddit ."
                       sh "docker tag reddit pguleria/reddit:latest "
                       sh "docker push pguleria/reddit:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image pguleria/reddit:latest > trivy.txt" 
            }
        }
        stage('Deploy to container'){
            steps{
                sh 'docker run -d --name reddit -p 3000:3000 pguleria/reddit:latest'
            }
        }
        stage("Deploy to Kubenertes"){
            steps{
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                       sh 'kubectl apply -f deployment.yml'
                       sh 'kubectl apply -f service.yml'
                       sh 'kubectl apply -f ingress.yml'
                    }
                }
            }
        }        
    }
}