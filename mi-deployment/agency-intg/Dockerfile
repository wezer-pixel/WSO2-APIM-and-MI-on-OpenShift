FROM docker.wso2.com/wso2mi:4.4.0

USER root

# Install probe/troubleshooting tools (nc, curl, etc.)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      netcat-openbsd curl ca-certificates procps iproute2 iputils-ping dnsutils python3; \
    rm -rf /var/lib/apt/lists/*

USER wso2carbon

# Copy your CAR + configs
COPY carbonapps/*.car ${WSO2_SERVER_HOME}/repository/deployment/server/carbonapps/
COPY libs/* ${WSO2_SERVER_HOME}/lib/
COPY conf/* ${WSO2_SERVER_HOME}/conf/


