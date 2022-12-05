pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('TF Plan') {
       steps {
         //withAWS(roleAccount:'818682305270', role:'jenkins-cross-account-role-ss-sgtradex') {
           withAWS(credentials: "${params.Environment}-cdi-aws", region: 'ap-southeast-1'){
         script {
           sh 'rm -rf .terraform'
           //sh 'terraform state replace-provider registry.terraform.io/-/aws hashicorp/aws'
           sh "terraform init -upgrade -reconfigure -get=true -input=false -no-color -backend-config='bucket=dev-elk-statefile' -backend-config='key=${params.env}/${params.Environmrnt}-keymanager.tfstate'" 
           sh "terraform plan -input=false  -no-color -refresh=true -var='env=${params.Environment}' -refresh=true  -out='${workspace}/plan'"
           //Enable below line to destroy nothing to add extra
           //sh "terraform plan -destroy -input=false  -no-color -refresh=true  -var='pitstop_license_key=${params.pitstopLicenseKey}' -var='environment=${params.Environment}' -var='pitstop_name=${params.Pitstop_Name}' -var-file='${params.Environment}-pitstop.tfvars' -out='${workspace}/plan'"

         }
         }
       }
     }
     stage('Approval') {
      steps {
        script {
          //sh 'echo OK'
          input message: 'Would you like to procced with applying these terrafrom changes?',ok: 'Yes'
        }
      }
    }
     stage('TF Apply') {
      steps {
                  withAWS(credentials: "${params.Environment}-Pitstop-AWS-Key", region: 'ap-southeast-1'){
        script {
          sh "terraform apply -no-color -input=false '${workspace}/plan'"
        }
        }
      }
    }
  }
}
