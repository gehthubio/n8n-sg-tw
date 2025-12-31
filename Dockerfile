FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install required packages
# @sendgrid/mail is often better for sending emails; client is low-level
RUN npm install --omit=dev @sendgrid/mail @sendgrid/client twilio

# Add any other packages you need here, e.g.:
# RUN npm install --omit=dev lodash moment axios

USER node
