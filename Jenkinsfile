def labelArm = "docker-ansible-build-arm64${UUID.randomUUID().toString()}"
def labelx86_64 = "docker-ansible-build-x86_64${UUID.randomUUID().toString()}"

def imageVersion = "1.0"
def imageName = "ansible-k8s"
def imageRepo = "voight"
def nexusServer = "nexus.voight.org:9042"

stage('Build') {
    podTemplate(
            label: labelArm,
            containers: [
                    containerTemplate(name: 'docker',
                            image: 'docker:20.10.9',
                            alwaysPullImage: false,
                            ttyEnabled: true,
                            command: 'cat',
                            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
                            privileged: true),
                    containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}'),
            ],
            volumes: [
                    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
            ],
            nodeSelector: 'kubernetes.io/arch=arm64'
    ) {
        node(labelArm) {
            stage('Git Checkout') {
                def scmVars = checkout([
                        $class           : 'GitSCM',
                        userRemoteConfigs: scm.userRemoteConfigs,
                        branches         : scm.branches,
                        extensions       : scm.extensions
                ])

                // used to create the Docker image
                env.GIT_BRANCH = scmVars.GIT_BRANCH
                env.GIT_COMMIT = scmVars.GIT_COMMIT
            }

            stage('Push') {
                container('docker') {
                    docker.withRegistry("https://${nexusServer}", 'NexusDockerLogin') {
                        image = docker.build("${imageRepo}/${imageName}:${imageVersion}-arm64")
                        image.push("${imageVersion}-arm64")
                        image.push("arm64-latest")
                    }
                }
            }
        }
    }


    podTemplate(
            label: labelx86_64,
            containers: [
                    containerTemplate(name: 'docker',
                            image: 'docker:20.10.9',
                            alwaysPullImage: false,
                            ttyEnabled: true,
                            command: 'cat',
                            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
                            privileged: true),
                    containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}'),
            ],
            volumes: [
                    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
            ],
            nodeSelector: 'kubernetes.io/arch=amd64'
    ) {
        node(labelx86_64) {
            stage('Git Checkout') {
                def scmVars = checkout([
                        $class           : 'GitSCM',
                        userRemoteConfigs: scm.userRemoteConfigs,
                        branches         : scm.branches,
                        extensions       : scm.extensions
                ])

                // used to create the Docker image
                env.GIT_BRANCH = scmVars.GIT_BRANCH
                env.GIT_COMMIT = scmVars.GIT_COMMIT
            }

            stage('Push') {
                container('docker') {
                    docker.withRegistry("https://${nexusServer}", 'NexusDockerLogin') {
                        image = docker.build("${imageRepo}/${imageName}:${imageVersion}-amd64")
                        image.push("${imageVersion}-amd64")
                        image.push("amd64-latest")
                    }
                }
            }

            stage('Manifest') {
                container('docker') {
                    docker.withRegistry("https://${nexusServer}", 'NexusDockerLogin') {
                        sh "docker pull ${imageRepo}/${imageName}:arm64-latest"
                        sh "docker pull ${imageRepo}/${imageName}:amd64-latest"

                        sh "docker manifest create --insecure ${nexusServer}/${imageRepo}/${imageName}:latest -a ${nexusServer}/${imageRepo}/${imageName}:amd64-latest -a ${nexusServer}/${imageRepo}/${imageName}:arm64-latest"
                        sh "docker manifest push --insecure ${nexusServer}/${imageRepo}/${imageName}:latest"

                        sh "docker manifest create --insecure ${nexusServer}/${imageRepo}/${imageName}:${imageVersion} -a ${nexusServer}/${imageRepo}/${imageName}:${imageVersion}-amd64 -a ${nexusServer}/${imageRepo}/${imageName}:${imageVersion}-arm64"
                        sh "docker manifest push --insecure ${nexusServer}/${imageRepo}/${imageName}:${imageVersion}"
                    }
                }
            }
        }
    }
}


