############################
### CKAN Base Virtualenv ###
############################
FROM alpine:3.11 as virtualenv

# Set src dirs
ENV APP_DIR=/srv/app

    # Create a local user and group to run the app
RUN mkdir -p ${APP_DIR} \
    # Install pip
 && apk add --update --no-cache \
        python \
        curl \
 && curl -o ${APP_DIR}/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python ${APP_DIR}/get-pip.py pip==20.3.3 \
 && rm -f ${APP_DIR}/get-pip.py \
 && pip install virtualenv \
 && cd ${APP_DIR} && virtualenv --symlinks -p /usr/bin/python venv

#################
### CKAN Base ###
#################
FROM alpine:3.11

LABEL maintainer="info@datopian.com"

# Set CKAN version to build
ENV GIT_URL=https://github.com/ckan/ckan.git

# Set src dirs
ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV PIP_SRC=${SRC_DIR}
ENV TZ UTC

# Copies the virtual environment and utility files
COPY --from=virtualenv /srv/app /srv/app
COPY scripts /usr/local/bin/
COPY startup ${APP_DIR}

    # Create a local user and group to run the app
RUN addgroup -g 92 -S ckan \
 && adduser -u 92 -h /srv/app -H -D -S -G ckan ckan \
    # Install minimum runtime dependencies
 && apk add --update --no-cache \
        python \
        bash \
        pcre \
        libffi \
        libmagic \
        libpq \
    # Create the src directory
 && mkdir -p ${SRC_DIR} /var/lib/ckan \
    # Assign permissions to ckan user
 && chown -R 92:92 ${APP_DIR} /var/lib/ckan /usr/local/bin/start

WORKDIR ${APP_DIR}

# Sets the user to ckan
USER 92

# For uWSGI proper termination the SIGINT should be sent instead the default SIGTERM
# Ref: https://uwsgi-docs.readthedocs.io/en/latest/Management.html#signals-for-controlling-uwsgi
#STOPSIGNAL SIGINT

ENTRYPOINT ["start"]

ONBUILD COPY license*.json /etc/
