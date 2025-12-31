FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install the SendGrid packages
# @sendgrid/mail is recommended for sending emails (easier than the low-level client)
# Include both if you need the client specifically
RUN npm install --omit=dev @sendgrid/mail @sendgrid/client

# Optional: Add twilio if you're using that too (since it's in your allowlist)
RUN npm install --omit=dev twilio

USER node
