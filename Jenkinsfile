pipeline {
    agent any 

    stages {
        stage('Checkout') {
            // On récupère notre dossier git

            git 'https://github.com/Siete7777/projet_devops.git'
        }

        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Owncloud \
                    -Dsonar.projectKey=Owncloud '''
                }
            }
        }

        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-tokens' 
                }
            } 
        }

        stage('OWASP FS SCAN') {
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

        stage('Docker Build & Push'){
            steps{
                script{
                    sh "docker compose up"
                }
            }
        }

        stage('Personnalisation Owncloud'){
            steps{
                sh "docker exec -it projet_devops apt install unzip"
                sh "docker exec -it owncloud cd /var/www/owncloud/apps"
                sh "docker exec -it owcloud wget https://github.com/owncloud/theme-example/archive/master.zip"
                sh "docker exec -it owcloud unzip master.zip"
                sh "docker exec -it owncloud rm master.zip"
                sh "docker exec -it owncloud mv theme-example-master mynewtheme"
                sh "docker exec -it owncloud sed -i "s#<id>theme-example<#<id>mynewtheme<#" "mynewtheme/appinfo/info.xml""
                sh "docker exec -it owncloud sudo chown -R www-data: mynewtheme"
                sh "docker exec -it owncloud sudo -u www-data ./occ app:enable mynewtheme"
            }
        }
    }

}