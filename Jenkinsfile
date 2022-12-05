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
         withAWS(credentials: "${params.Environment}-AWS-Key", region: 'ap-southeast-1'){
         script {  
           sh 'rm -rf .terraform'  
           sh "terraform init -get=true -input=false -no-color -backend-config='bucket=dev-elk-statefile' -backend-config='key=${params.env}/${params.Environmrnt}-keymanager.tfstate'" 
           sh "terraform plan -input=false  -no-color -var='env=${params.Environment}' -refresh=true  -out='${workspace}/plan'"
           //sh "terraform plan -destroy -input=false  -no-color -var='environment=${params.Environment}' -refresh=true  -out='${workspace}/plan'"
         }
       //}
       }
     }
     stage('Approval') {
      steps {
        script {
          input message: 'Would you like to procced with applying these terrafrom changes?',ok: 'Yes'
        }
      }
    }
     stage('TF Apply') {
      steps {
        //withAWS(credentials: "${params.Environment}-AWS-Key", region: 'ap-southeast-1'){
        script {
          sh "terraform apply -no-color -input=false '${workspace}/plan'"
        }
      //}
      }
    }
  }
}
}