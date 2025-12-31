FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install the required packages globally
RUN npm install -g @sendgrid/mail @sendgrid/client twilio

# Optional: Upgrade npm first if needed (some older guides do this)
# RUN npm install -g npm@latest

USER node
