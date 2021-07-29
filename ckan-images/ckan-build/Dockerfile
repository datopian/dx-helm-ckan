##################
### CKAN Build ###
##################
FROM ckan-base:2.7-1.0.0

# Set CKAN version to build
ENV GIT_URL=https://github.com/ckan/ckan.git
ENV GIT_BRANCH=ckan-2.8.2
ENV WHEEL_DIR=${APP_DIR}/venv/wheels

ENV CKAN_SITE_URL=http://localhost:5000
# Lets try whitout the s3filestore
#ENV CKAN__PLUGINS envvars image_view text_view recline_view recline_grid recline_graph recline_map datastore datapusher resource_proxy

COPY scripts /usr/local/bin/
COPY patches /srv/patches

USER 0

# Fetch and build CKAN and requirements
RUN apk add --update --no-cache \
        git \
        curl \
        python \
        postgresql-dev \
        linux-headers \
        gcc \
        make \
        g++ \
        autoconf \
        automake \
        libtool \
        pcre-dev \
        libffi-dev \
        python-dev
 RUN curl -o ${SRC_DIR}/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python ${SRC_DIR}/get-pip.py pip==20.3.3 \
 && rm -f ${SRC_DIR}/get-pip.py \
 && ${APP_DIR}/venv/bin/pip install -e git+${GIT_URL}@${GIT_BRANCH}#egg=ckan \
 && rm -rf /srv/app/src/ckan/.git \
 && cd ${SRC_DIR} \
 && pip wheel --wheel-dir=${WHEEL_DIR} -r ckan/requirements.txt \
 && pip wheel --wheel-dir=${WHEEL_DIR} gunicorn gevent==1.4.0 \
 && . ${APP_DIR}/venv/bin/activate \
 && pip install --no-index --find-links=${WHEEL_DIR} -r ckan/requirements.txt \
 && pip install --no-index --find-links=${WHEEL_DIR} gunicorn gevent \
 && cp ${SRC_DIR}/ckan/who.ini ${APP_DIR} \
    # Install CKAN envvars to support loading config from environment variables
 && pip install -e git+https://github.com/okfn/ckanext-envvars.git@0.0.1#egg=ckanext-envvars 
 # Apply any patches needed to CKAN core or any of the built extensions (not the
 # runtime mounted ones)
 # See https://github.com/okfn/docker-ckan#applying-patches
 RUN for d in /srv/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done 
    # Create and update CKAN config
 RUN chown -R 92:92 ${APP_DIR}

ONBUILD COPY *_dx.txt ${APP_DIR}/
ONBUILD RUN build && rm -rf ${APP_DIR}/*_dx.txt
