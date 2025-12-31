FROM docker.n8n.io/n8nio/n8n:latest

USER root
# Install your external modules

RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail

# Make global modules resolvable
ENV NODE_PATH=/usr/local/lib/node_modules

USER node
