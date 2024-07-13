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

        stage('Personnalisation Owncloud/exécution du script bash'){
            steps{// Copie le script bash dans un fichier temporaire
                    sh """
                        echo '#!/bin/bash' > script.sh
                        echo '$scriptContent' >> script.sh
                    """
                    // Exécute le script bash à l'intérieur d'un conteneur Docker
                    sh "docker cp script.sh owncloud:/tmp/script.sh"
                    sh "docker exec owncloud chmod +x /tmp/script.sh"
                    sh "docker exec owncloud /tmp/script.sh"
            }
        }
    }

}