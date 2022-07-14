#!groovy
import groovy.json.JsonSlurperClassic
node {

    // ID's dos certificados utilizados para autenticação com JWT
    
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_HML
    def JWT_KEY_CRED_ID_PROD = env.JWT_CRED_ID_PROD

    // Variáveis de login para o ambiente de Build

    def HUB_ORG_BU = env.HUB_ORG_BU
    def SFDC_HOST_BU = env.SFDC_HOST_BU   
    def CONNECTED_APP_CONSUMER_KEY_BU = env.CONNECTED_APP_CONSUMER_KEY_BU
    
    // Variáveis de login para o ambiente de QA

    def HUB_ORG_QA = env.HUB_ORG_QA
    def SFDC_HOST_QA = env.SFDC_HOST_QA
    def CONNECTED_APP_CONSUMER_KEY_QA = env.CONNECTED_APP_CONSUMER_KEY_QA
    
    // Variáveis de login para o ambiente de UAT

    def HUB_ORG_UAT = env.HUB_ORG_UAT
    def SFDC_HOST_UAT = env.SFDC_HOST_UAT
    def CONNECTED_APP_CONSUMER_KEY_UAT = env.CONNECTED_APP_CONSUMER_KEY_UAT
    
    // Variáveis de login para o ambiente de Stage

    def HUB_ORG_STG = env.HUB_ORG_STG
    def SFDC_HOST_STG = env.SFDC_HOST_STG
    def CONNECTED_APP_CONSUMER_KEY_STG = env.CONNECTED_APP_CONSUMER_KEY_STG
    
    // Variáveis de login para o ambiente de Produção

    def HUB_ORG = env.HUB_ORG
    def SFDC_HOST = env.SFDC_HOST
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY

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
                if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
            }
        }
        
        stage('Procedimentos Manuais'){
            def userInput = input(
                    id: 'userInput', message: 'Procedimentos Manuais', parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
                ])
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

    //Etapa de implantação no ambiente de QA

    if (scmVars.GIT_BRANCH.contains('develop')){
        stage('Autenticação'){
            withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
                if (isUnix()){
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_QA} --username ${HUB_ORG_QA} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST_QA}"
                }else{
                     rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_QA} --username ${HUB_ORG_QA} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST_QA}"
                }
                if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
            }
        }
        
        stage('Procedimentos Manuais'){
            def userInput = input(
                    id: 'userInput', message: 'Procedimentos Manuais', parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
                ])
        }
    
        // Rollback pré-deploy

        stage('Rollback Pré-Implantação'){
            if (isUnix()){
            rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }              
        }

        stage('Deploy'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }
        }

        // Rollback pós-deploy

        stage('Rollback Pós-Implantação'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.qa"
            }
        }                    
    }

    // Etapa de implantação no ambiente de UAT

    if (scmVars.GIT_BRANCH.contains('release')){
        stage('Autenticação em Build'){
            withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
                if (isUnix()){
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_BU} --username ${HUB_ORG_BU} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST_BU}"
                }else{
                     rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_BU} --username ${HUB_ORG_BU} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST_BU}"
                }
                if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
            }
        }
        
        stage('Procedimentos Manuais'){
            def userInput = input(
                id: 'userInput', message: 'Procedimentos Manuais', parameters: [
                [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
            ])
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
        
        stage('Aprovação'){
            def userInput = input(
                id: 'userInput', message: 'Aprovação', parameters: [
                [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Seguir com Implantação em UAT?']
            ])
        }
              
        stage('Autenticação em UAT'){
            withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
                if (isUnix()){
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_UAT} --username ${HUB_ORG_UAT} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST_UAT}"
                }else{
                     rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_UAT} --username ${HUB_ORG_UAT} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST_UAT}"
                }
                if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
            }
        }
        
        stage('Procedimentos Manuais'){
            def userInput = input(
                id: 'userInput', message: 'Procedimentos Manuais', parameters: [
                [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
            ])
        }
    
        // Rollback pré-deploy

        stage('Rollback Pré-Implantação'){
            if (isUnix()){
            rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }              
        }

        stage('Deploy'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }
        }

        // Rollback pós-deploy

        stage('Rollback Pós-Implantação'){
            if (isUnix()){
                rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }else{
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.uat"
            }
        }                    
    }
    
    //Etapa de implantação nos ambientes de Stage e Produção
    
    if (scmVars.GIT_BRANCH.contains('main')){
	stage('Autenticação em Stage'){
		withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
			if (isUnix()){
			rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_STG} --username ${HUB_ORG_STG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST_STG}"
			}else{
				 rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY_STG} --username ${HUB_ORG_STG} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST_STG}"
			}
			if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
		}
	}
    
    stage('Procedimentos Manuais'){
        def userInput = input(
            id: 'userInput', message: 'Procedimentos Manuais', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
        ])
    }

	// Rollback pré-deploy

	stage('Rollback Pré-Implantação'){
		if (isUnix()){
		rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}else{
			rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}              
	}

	stage('Deploy'){
		if (isUnix()){
			rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}else{
			rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}
	}

	// Rollback pós-deploy

	stage('Rollback Pós-Implantação'){
		if (isUnix()){
			rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}else{
			rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br.stg"
		}
	}
    
    stage('Aprovação'){
        def userInput = input(
            id: 'userInput', message: 'Aprovação', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Seguir com Implantação em Produção?']
        ])
    }
    
    stage('Autenticação em Produção'){
        withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]){
            if (isUnix()){
            rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            }else{
                 rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            }
            if (rc != 0) { error 'A tentativa de autorização com a Org falhou!' }
        }
    }
    
    stage('Procedimentos Manuais'){
        def userInput = input(
            id: 'userInput', message: 'Procedimentos Manuais', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Procedimentos Realizados?']
        ])
    }

    // Rollback pré-deploy

    stage('Rollback Pré-Implantação'){
        if (isUnix()){
        rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br"
        }else{
            rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --predestructivechanges manifest/destructiveChangesPre.xml -u thiago.xaviercosta@portoseguro.com.br"
        }              
    }

    stage('Deploy'){
        if (isUnix()){
            rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br"
        }else{
            rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml -u thiago.xaviercosta@portoseguro.com.br"
        }
    }

    // Rollback pós-deploy

    stage('Rollback Pós-Implantação'){
        if (isUnix()){
            rmsg = sh returnStdout: true, script: "${toolbelt} force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br"
        }else{
            rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:source:deploy --manifest manifest/package.xml --postdestructivechanges manifest/destructiveChangesPost.xml -u thiago.xaviercosta@portoseguro.com.br"
        }
    }
	}
}
