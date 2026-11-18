# Imagen de Jenkins para el laboratorio: Jenkins LTS + Node.js 22 + Docker CLI
FROM jenkins/jenkins:lts-jdk21

USER root

# Docker CLI (usa el motor Docker del host a través del socket montado)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

# Node.js 22 LTS (para npm ci, jest, eslint, npm audit)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && node --version && npm --version

# Plugins de Jenkins (instalados en la imagen = infraestructura como código)
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Configuración como código (usuario admin, mensaje de sistema, URL)
COPY casc/jenkins.yaml /usr/share/jenkins/casc/jenkins.yaml

USER jenkins
