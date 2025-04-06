FROM nginx:alpine

# Copy website files
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create entrypoint script
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'sed -i "s/ENVIRONMENT_PLACEHOLDER/$ENVIRONMENT/g" /usr/share/nginx/html/index.html' >> /docker-entrypoint.sh && \
    echo 'sed -i "s/SECRET_PLACEHOLDER/$SECRET_VALUE/g" /usr/share/nginx/html/index.html' >> /docker-entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]