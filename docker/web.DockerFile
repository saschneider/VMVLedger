#
# NGINX Docker file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Based on https://itnext.io/docker-rails-puma-nginx-postgres-999cd8866b18.

# NGINX.
FROM nginx

# Dependencies.
RUN apt-get update && apt-get install -y apache2-utils

# Copy over the app and install gems.
ENV RAILS_ROOT /app
WORKDIR $RAILS_ROOT

# Create log directory.
RUN mkdir log

# Copy over static assets.
COPY public public/

# Copy over the NGINX configuration and substitute in the relative variables.
COPY docker/nginx.conf ./
RUN envsubst '$RAILS_ROOT' < nginx.conf > /etc/nginx/conf.d/default.conf

# Expose the HTTP port.
EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`).
CMD [ "nginx", "-g", "daemon off;" ]
