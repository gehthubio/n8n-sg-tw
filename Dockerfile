FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install packages in n8n's main node_modules directory
WORKDIR /usr/local/lib/node_modules/n8n

RUN npm install --omit=dev @sendgrid/mail @sendgrid/client twilio

USER node

WORKDIR /home/node
