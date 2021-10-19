def labelArm = "docker-ansible-build-arm64${UUID.randomUUID().toString()}"
def labelx86_64 = "docker-ansible-build-x86_64${UUID.randomUUID().toString()}"


stage('Build') {
    podTemplate(
            label: labelArm,
            containers: [
                    containerTemplate(name: 'docker',
                            image: 'docker:20.10.9',
                            alwaysPullImage: false,
                            ttyEnabled: true,
                            command: 'cat',
                            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock"),//containerEnvVar(key: 'DOCKER_TLS_CERTDIR', value: "/certs")],
                            privileged: true),
                    containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}'),
            ],
            volumes: [
                    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/ca'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/server'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/client')
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
                    docker.withRegistry('https://nexus.voight.org:9042', 'NexusDockerLogin') {
                        image = docker.build("voight/docker-ansible:arm64")
                        image.push("arm64")
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
                            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock"),//containerEnvVar(key: 'DOCKER_TLS_CERTDIR', value: "/certs")],
                            privileged: true),
                    containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}'),
            ],
            volumes: [
                    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/ca'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/client'),
                    hostPathVolume(hostPath: '/etc/ssl/certs', mountPath: '/certs/server')
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
                    docker.withRegistry('https://nexus.voight.org:9042', 'NexusDockerLogin') {
                        image = docker.build("voight/docker-ansible:amd64")
                        image.push("amd64")
                        image.push("amd64-latest")
//                        sh "docker pull voight/mvn-jdk-1.8:arm64-latest"
//                        sh "docker manifest create nexus.voight.org:9042/voight/mvn-jdk-1.8:latest -a nexus.voight.org:9042/voight/mvn-jdk-1.8:amd64-latest -a nexus.voight.org:9042/voight/mvn-jdk-1.8:arm64-latest"
//                        sh "docker push nexus.voight.org:9042/voight/mvn-jdk-1.8:latest"
                    }
                }

            }
        }
    }
}
