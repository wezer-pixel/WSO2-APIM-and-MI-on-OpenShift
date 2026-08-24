#FROM docker.io/wso2/wso2am:4.7.0
FROM wso2/wso2am-acp:4.7.0

ENV USER_HOME=/home/wso2carbon
ENV WSO2_SERVER_HOME=/home/wso2carbon/wso2am-4.7.0

USER root

COPY lib/*.jar ${WSO2_SERVER_HOME}/repository/components/lib/

RUN sed -i 's/\r$//' ${USER_HOME}/docker-entrypoint.sh && \
    chmod 755 ${USER_HOME}/docker-entrypoint.sh && \
    chgrp -R 0 ${USER_HOME} && \
    chmod -R g=u ${USER_HOME} && \
    namei -l ${USER_HOME}/docker-entrypoint.sh

USER 802