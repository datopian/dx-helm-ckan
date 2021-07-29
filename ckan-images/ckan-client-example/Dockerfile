FROM ckan-build:2.8.2-1.0.0 as build

FROM ckan-base:2.7-1.0.0

COPY --from=build ${APP_DIR} ${APP_DIR}