# Base node image
FROM node:20.11-bullseye-slim as base

# Set environment for base and all layers that inherit from it
ENV NODE_ENV production

# Install openssl for Prisma, sqlite3 for Ghost, and Nginx for routing
RUN apt-get update && apt-get install -y openssl sqlite3 nginx python3 build-essential procps gettext

# Install Ghost CLI
RUN npm install ghost-cli@1.25.3 -g

# Create the Ghost directory and set appropriate permissions
RUN mkdir -p /var/www/ghost \
    && adduser --disabled-password --gecos '' ghostuser \
    && chown -R ghostuser:ghostuser /var/www/ghost

# Switch to the non-root user
USER ghostuser

# Set up Ghost
WORKDIR /var/www/ghost
RUN ghost install local --no-start



# Environment variables
ENV DATABASE_URL=file:/var/www/ghost/content/data/ghost-local.db
ENV GHOST_URL=http://localhost:2368
ENV PORT=3000
ENV NODE_ENV=production
# Disable Prisma telemetry
ENV CHECKPOINT_DISABLE=1

# Shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli
RUN chmod +x /usr/local/bin/database-cli

COPY nginx.prod.conf /etc/nginx/nginx.prod.conf

RUN chmod +x ./start.sh

ENTRYPOINT [ "./start.sh" ]