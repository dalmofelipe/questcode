podTemplate(
    cloud: 'kubernetes', 
    name: 'questcode', // ref para que o node execute nesse pod
    label: 'questcode', 
    namespace: 'devops', 
    containers: [
        containerTemplate(
            args: 'cat', 
            command: '/bin/sh -c', 
            image: 'docker', 
            livenessProbe: containerLivenessProbe(
                execArgs: '', 
                failureThreshold: 0, 
                initialDelaySeconds: 0, 
                periodSeconds: 0, 
                successThreshold: 0, 
                timeoutSeconds: 0
            ), 
            name: 'docker-container', 
            resourceLimitCpu: '', 
            resourceLimitEphemeralStorage: '', 
            resourceLimitMemory: '', 
            resourceRequestCpu: '', 
            resourceRequestEphemeralStorage: '', 
            resourceRequestMemory: '', 
            ttyEnabled: true, 
            workingDir: '/home/jenkins/agent'
        )
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
            sh 'ls -ltra'
        }
        stage('Build') {
            echo 'Executando NPM install'
            sh 'ls -ltra'
        }
        stage('Deploy') {
            echo 'Iniciando deploy com Helm'
            sh 'ls -ltra'
        }
    }
}