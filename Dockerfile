FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Change to n8n's node_modules directory and install packages globally there
WORKDIR /usr/local/lib/node_modules/n8n

RUN npm install -g @sendgrid/mail @sendgrid/client twilio

USER node

WORKDIR /home/node
