#! /bin/bash

# Set uwsgi mount point to the defined context root
echo Configuring context root
: "${CONTEXT_ROOT:?Error, variable CONTEXT_ROOT unset or empty}"
sed -i "s#CONTEXT_ROOT#$CONTEXT_ROOT#g" /app/uwsgi.ini


# -----------------------------------------------------------------------------
# From here on, it's the base image's original entrypoint script, do not modify
# this part.

set -e

# Get the maximum upload file size for Nginx, default to 0: unlimited
USE_NGINX_MAX_UPLOAD=${NGINX_MAX_UPLOAD:-0}
# Generate Nginx config for maximum upload file size
echo "client_max_body_size $USE_NGINX_MAX_UPLOAD;" > /etc/nginx/conf.d/upload.conf

# Explicitly add installed Python packages and uWSGI Python packages to PYTHONPATH
# Otherwise uWSGI can't import Flask
export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages:/usr/lib/python2.7/site-packages

# Get the number of workers for Nginx, default to 1
USE_NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-1}
# Modify the number of worker processes in Nginx config
sed -i "/worker_processes\s/c\worker_processes ${USE_NGINX_WORKER_PROCESSES};" /etc/nginx/nginx.conf

# Get the listen port for Nginx, default to 80
USE_LISTEN_PORT=${LISTEN_PORT:-80}
# Modify Nignx config for listen port
if ! grep -q "listen ${USE_LISTEN_PORT};" /etc/nginx/conf.d/nginx.conf ; then
    sed -i -e "/server {/a\    listen ${USE_LISTEN_PORT};" /etc/nginx/conf.d/nginx.conf
fi

exec "$@"
