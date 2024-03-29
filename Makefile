# Default image name
IMAGE_NAME ?= ghost-easy-deploy
# Default Ghost API key
BLOG_URL ?= http://localhost:8080
SITE_TITLE ?= Test
SITE_DESCRIPTION ?= "A test description"
OWNER_NAME ?= Test
OWNER_SLUG ?= test
OWNER_EMAIL ?= test@example.com
OWNER_PASSWORD ?= password
MAILGUN_DOMAIN ?= sandbox@mailbox.com
MAILGUN_API_KEY ?= somkey
MAILGUN_BASE_URL ?= https://api.mailgun.net/
MAILGUN_USER ?= someuser
MAILGUN_PASSWORD ?= somepassword

# Container name
CONTAINER_NAME ?= ghost-easy-deploy-container

# Phony targets
.PHONY: build run all clean clean-image clean-all terminal

all: build run
clean-all: clean clean-image

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run -d --name $(CONTAINER_NAME) -p 8080:8080 \
	-e SITE_TITLE=$(SITE_TITLE) \
	-e SITE_DESCRIPTION=$(SITE_DESCRIPTION) \
	-e OWNER_NAME=$(OWNER_NAME) \
	-e OWNER_SLUG=$(OWNER_SLUG) \
	-e OWNER_EMAIL=$(OWNER_EMAIL) \
	-e OWNER_PASSWORD=$(OWNER_PASSWORD) \
	-e BLOG_URL=$(BLOG_URL) \
	-e MAILGUN_DOMAIN=$(MAILGUN_DOMAIN) \
	-e MAILGUN_API_KEY=$(MAILGUN_API_KEY) \
	-e MAILGUN_BASE_URL=$(MAILGUN_BASE_URL) \
	-e MAILGUN_USER=$(MAILGUN_USER) \
	-e MAILGUN_PASSWORD=$(MAILGUN_PASSWORD) \
	$(IMAGE_NAME)

clean:
	docker stop $(CONTAINER_NAME) && docker rm $(CONTAINER_NAME)

# Remove the Docker image
clean-image:
	docker rmi $(IMAGE_NAME)

terminal:
	docker exec -it $(CONTAINER_NAME) /bin/bash
