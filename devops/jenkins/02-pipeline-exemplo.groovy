podTemplate(
    cloud: 'kubernetes', 
    name: 'questcode', // ref para que o node execute nesse pod
    label: 'questcode', 
    namespace: 'devops', 
    containers: [
        containerTemplate(
            name: 'docker-container', 
            image: 'docker', 
            args: 'cat', 
            command: '/bin/sh -c', 
            ttyEnabled: true, 
            livenessProbe: containerLivenessProbe(
                execArgs: '', 
                failureThreshold: 0, 
                initialDelaySeconds: 0, 
                periodSeconds: 0, 
                successThreshold: 0, 
                timeoutSeconds: 0
            ), 
            resourceLimitCpu: '', 
            resourceLimitEphemeralStorage: '', 
            resourceLimitMemory: '', 
            resourceRequestCpu: '', 
            resourceRequestEphemeralStorage: '', 
            resourceRequestMemory: '', 
            workingDir: '/home/jenkins/agent'
        )
        // containerTemplate(name: 'nodejs')
    ],
    volumes: [
        hostPathVolume(
            hostPath: '/var/run/docker.sock', 
            mountPath: '/var/run/docker.sock', 
            readOnly: false
        )
    ]
) 
{
    // este node será executado no podTemplate 'questcode'
    node('questcode') { 
        stage('Checkout') {
            echo 'Clone do repositório do código no Github'
            sh 'pwd'
            checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/dalmofelipe/questcode.git']])
            sh 'ls -ltra'
        }
        stage('Package') {
            container('docker-container') { // os comandos serão executados no container especificado
                echo 'comunicando docker k8s com docker do host'
                echo 'listando imagens do host'
                sh 'docker images'

                // sh 'cd app/frontend' // não mudou diretório
                dir('app/frontend') { // OK Success
                    sh 'pwd'
                    sh 'ls -ltra'
                }
            }
        }
        stage('Deploy') {
            echo 'Iniciando deploy com Helm'
            sh 'pwd' // volta a raiz do repositorio
            sh 'ls -ltra'
        }
    }
}