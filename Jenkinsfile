pipeline {
  agent { label 'jenkins-slave' }

  environment {
    DB_USERNAME = credentials('DB_USERNAME')
    DB_PASSWORD = credentials('DB_PASSWORD')
  }

  stages {
    stage('Parse Terraform Output and Write Vars') {
      steps {
        script {
          def tfOutput = readJSON file: "${env.HOME}/tf-output.json"

          def varsContent = """
          RDS_HOSTNAME: "${tfOutput['mysql-endpoint'].value.split(":")[0]}"
          RDS_PORT: "${tfOutput['mysql-endpoint'].value.split(":")[1]}"
          RDS_USERNAME: "${env.DB_USERNAME}"
          RDS_PASSWORD: "${env.DB_PASSWORD}"
          REDIS_HOSTNAME: "${tfOutput['redis-endpoint'].value[0].address}"
          REDIS_PORT: "${tfOutput['redis-endpoint'].value[0].port}"
          """.stripIndent()

          writeFile file: "roles/Deploy_app/vars/main.yaml", text: varsContent
        }
      }
       post {
                
                success {
                    slackSend channel: '#jenkins-pipelines' ,color: "good", message: "✅ *Parseing Terraform Output Successfully*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }

                failure {
                    slackSend channel: '#jenkins-pipelines' ,color: "danger", message: "❌ *Parseing Terraform Output failed*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }
            }
    }

    stage('Build and Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'Docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin
            sudo docker build -t pipeline-node-app .
            sudo docker tag pipeline-node-app salmayasser5/pipeline-node-app:latest
            sudo docker image push salmayasser5/pipeline-node-app:latest
          '''
        }
      }
       post {
                
                success {
                    slackSend channel: '#jenkins-pipelines' ,color: "good", message: "✅ *Building and Pushing Docker Image Successfully*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }

                failure {
                    slackSend channel: '#jenkins-pipelines' ,color: "danger", message: "❌ *Building and Pushing Docker Image Failed*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }
            }
    }
    
    stage('Run Ansible Playbook') {
      steps {
          dir('ansible') {
             sh 'ansible-playbook deploy.yaml'
         }
       }
      post {
                
                success {
                    slackSend channel: '#jenkins-pipelines' ,color: "good", message: "✅ *Ansible playbook run Successfully*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }

                failure {
                    slackSend channel: '#jenkins-pipelines' ,color: "danger", message: "❌ *Ansible playbook running Failed*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }
            }
    }

    stage('Print Load Balancer DNS') {
      steps {
        script {
          def tfOutput = readJSON file: "${env.HOME}/tf-output.json"
          def dns = tfOutput['app-dns'].value
          echo "App is running at: ${dns}"
        }
        success {
                    slackSend channel: '#jenkins-pipelines' ,color: "good", message: "✅ *your pipeline running Successfully and your dns is *: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }

                failure {
                    slackSend channel: '#jenkins-pipelines' ,color: "danger", message: "❌ *Ansible playbook running Failed*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }
      }
    }
  }
}
