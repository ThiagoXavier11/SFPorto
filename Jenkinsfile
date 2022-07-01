#!groovy
import groovy.json.JsonSlurperClassic
node {

    environment {
        LC_ALL = 'pt_BR.UTF-8'
        LANG    = 'pt_BR.UTF-8'
        LANGUAGE = 'pt_BR.UTF-8'
    }

    // ID's dos certificados utilizados para autenticação com JWT
    
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def JWT_KEY_CRED_ID_PROD = env.JWT_CRED_ID_DH

    // Variáveis de login para o ambiente de Build

    def HUB_ORG_BU = env.HUB_ORG_DH
    def SFDC_HOST_BU = env.SFDC_HOST_DH    
    def CONNECTED_APP_CONSUMER_KEY_BU = env.CONNECTED_APP_CONSUMER_KEY_DH
    
    // Variáveis de login para o ambiente de QA

    def HUB_ORG_QA = env.HUB_ORG_DH
    def SFDC_HOST_QA = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY_QA = env.CONNECTED_APP_CONSUMER_KEY_DH
    
    // Variáveis de login para o ambiente de UAT

    def HUB_ORG_UAT = env.HUB_ORG_DH
    def SFDC_HOST_UAT = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY_UAT = env.CONNECTED_APP_CONSUMER_KEY_DH
    
    // Variáveis de login para o ambiente de Stage

    def HUB_ORG_STG = env.HUB_ORG_DH
    def SFDC_HOST_STG = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY_STG = env.CONNECTED_APP_CONSUMER_KEY_DH
    
    // Variáveis de login para o ambiente de Produção

    def HUB_ORG = env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

    // Custom Tool com o caminho de instalação do SFDX
    
    def toolbelt = tool 'toolbelt'
    
    // Checkout no repositório

    stage('Checkout no Repositório') {
        scmVars = checkout scm
    }
    
    // Etapa de implantação no ambiente de Build
    
    
    if (scmVars.GIT_BRANCH.contains('feature')){
        stage('Autenticação'){
            withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
                if (isUnix()){
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_BU} --username ${HUB_ORG_BU} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST_BU}"
                }else{
                     rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_BU} --username ${HUB_ORG_BU} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST_BU}"
                }
                if (rc != 0) { error 'hub org authorization failed' }
            }
        }
    
        // Rollback pré-deploy

        stage('Rollback Pré-Implantação'){
            if (isUnix()){
            rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }              
        }

        stage('Deploy'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }
        }

        // Rollback pós-deploy

        stage('Rollback Pós-Implantação'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.bu"
            }
        }                    
    }
}