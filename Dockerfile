# Base node image
FROM node:18.19-bullseye-slim

# Set environment
ENV NODE_ENV=production \
    DATABASE_URL=file:/var/www/ghost/content/data/ghost-local.db \
    CHECKPOINT_DISABLE=1

# Install openssl for Prisma, sqlite3 for Ghost, and Nginx for routing
RUN apt-get update && apt-get install -y openssl sqlite3 nginx python3 build-essential procps

# Shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli
RUN chmod +x /usr/local/bin/database-cli

# Install Ghost CLI
RUN npm install ghost-cli@1.25.3 -g

# Set up Ghost
RUN mkdir -p /var/www/ghost && \
    adduser --disabled-password --gecos '' ghostuser && \
    chown -R ghostuser:ghostuser /var/www/ghost

USER ghostuser
WORKDIR /var/www/ghost
RUN ghost install local --no-start

# Switch back to root user to install Prisma
USER root
WORKDIR /myapp

# Install only production dependencies
COPY package.json ./
RUN npm install --omit=dev

COPY prisma ./prisma
RUN npx prisma generate


# Copy Nginx configuration
COPY nginx.prod.conf /etc/nginx/nginx.conf

COPY config.template.json /var/www/ghost/config.template.json

# Prepare start script
COPY start.sh .
RUN chmod +x start.sh

# Expose ports if necessary (for Ghost and/or your app)
EXPOSE 8080

ENTRYPOINT [ "./start.sh" ]
