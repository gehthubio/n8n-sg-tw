FROM docker.n8n.io/n8nio/n8n:latest

USER root
# Install your external modules

RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7

# Make global modules resolvable
ENV NODE_PATH=/usr/local/lib/node_modules

# Install Python 3 + pip (required for yt-dlp) + ffmpeg (very useful bonus for media handling)
# Clean up in the same layer to keep image small
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install latest yt-dlp binary (recommended way — no pip needed, always fresh)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

# Optional: Pre-install your favorite yt-dlp transcript community node
# Uncomment one (or both) if you want it baked-in — otherwise install via n8n UI later
RUN npm install -g @rsraven/n8n-nodes-ytdlp-transcript
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

USER node
