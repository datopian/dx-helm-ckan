FROM python:2.7.18-alpine3.11 as build

ENV GIT_BRANCH ckan-2.8.2
ENV SRC_DIR /srv/app/src
ENV PIP_SRC ${SRC_DIR}

WORKDIR ${SRC_DIR}

RUN apk add --no-cache \
        autoconf \
        automake \
        curl \
        g++ \
        gcc \
        git \
        libtool \
        linux-headers \
        make \
        musl-dev \
        pcre \
        pcre-dev \
        postgresql-dev \
        python-dev

RUN pip install -e git+https://github.com/ckan/ckan.git@${GIT_BRANCH}#egg=ckan && \
    rm -rf /srv/app/src/ckan/.git
RUN pip wheel --wheel-dir=/wheels -r ckan/requirements.txt
RUN pip wheel --wheel-dir=/wheels gevent==1.4.0 uwsgi



FROM python:2.7.18-alpine3.11 as basic

ENV APP_DIR /srv/app
ENV SRC_DIR /srv/app/src
ENV PIP_SRC ${SRC_DIR}
ENV CKAN__PLUGINS envvars image_view text_view recline_view datastore datapusher
ENV CKAN_SITE_URL http://localhost:5000

COPY --from=build /wheels /srv/app/wheels
COPY --from=build /srv/app/src/ckan /srv/app/src/ckan
COPY --from=datopian/ckan:2.8.2 ${APP_DIR} ${APP_DIR}

WORKDIR ${APP_DIR}

RUN apk add --no-cache \
        apache2-utils \
        bash \
        build-base \
        curl \
        gettext \
        git \
        libffi-dev \
        libmagic \
        openssl-dev \
        pcre \
        postgresql-client \
        python-dev \
        redis \
        tzdata && \
    # Create SRC_DIR
    mkdir -p ${SRC_DIR} && \
    # Additional install steps for build stages artifacts
    pip install --no-index --find-links=/srv/app/wheels gevent uwsgi && \
    # Create a local user and group to run the app
    addgroup -g 92 -S ckan && \
    adduser -u 92 -h /srv/app -H -D -S -G ckan ckan && \
    # Install CKAN
    pip install -e /srv/app/src/ckan && \
    cd ${SRC_DIR}/ckan && \
    cp who.ini ${APP_DIR} && \
    pip install --no-index --find-links=/srv/app/wheels -r requirements.txt && \
    # Install CKAN envvars to support loading config from environment variables
    pip install -e git+https://github.com/okfn/ckanext-envvars.git@0.0.1#egg=ckanext-envvars && \
    # Create and update CKAN config
    rm -f $APP_DIR/production.ini && paster --plugin=ckan make-config ckan ${APP_DIR}/production.ini && \
    paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.plugins = ${CKAN__PLUGINS}" && \
    # Change ownership to app user
    chown -R ckan:ckan /srv/app && \
    # Remove wheels
    rm -rf /srv/app/wheels

COPY licenses.json /ext/licenses.json

EXPOSE 5000

USER ckan

CMD ["/srv/app/start_ckan.sh"]



FROM basic AS enterprise

USER root

RUN pip install --no-cache-dir -r https://raw.githubusercontent.com/datopian/ckanext-aircan/master/requirements.txt && \
    pip install --no-cache-dir -e git+https://github.com/datopian/ckanext-aircan.git#egg=ckanext-aircan && \
    pip install --no-cache-dir -r https://raw.githubusercontent.com/datopian/ckanext-authz-service/master/requirements.py2.txt && \
    pip install -e git+https://github.com/datopian/ckanext-authz-service.git#egg=ckanext-authz-service && \
    pip install --no-cache-dir -r https://raw.githubusercontent.com/datopian/ckanext-external-storage/master/requirements.py2.txt && \
    pip install -e git+https://github.com/datopian/ckanext-external-storage.git#egg=ckanext-external-storage && \
    pip install --no-cache-dir -r https://raw.githubusercontent.com/datopian/ckanext-s3filestore/fix-null-content-type/requirements.txt && \
    pip install --no-cache-dir git+https://github.com/datopian/ckanext-s3filestore.git@fix-null-content-type#egg=ckanext-s3filestore && \
    pip install --no-cache-dir -r https://raw.githubusercontent.com/okfn/ckanext-sentry/master/requirements.txt && \
    pip install --no-cache-dir git+https://github.com/okfn/ckanext-sentry.git#egg=ckanext-sentry && \
    paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.plugins = envvars"

USER ckan
