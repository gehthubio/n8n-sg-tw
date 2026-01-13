FROM docker.n8n.io/n8nio/n8n:latest

USER root
# Install your external modules

RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7

# Make global modules resolvable
ENV NODE_PATH=/usr/local/lib/node_modules

# Step 1: Re-bootstrap apk-tools (critical for hardened/distroless Alpine images)
# This downloads and installs a static apk binary, then uses it to add the full apk-tools package
RUN ARCH=$(uname -m) && \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[^"]*\.apk"' | head -1 | cut -d'"' -f2 | \
    xargs -I {} wget -q "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/{}" && \
    tar -xzf apk-tools-static-*.apk && \
    ./sbin/apk.static -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-*.apk

# Step 2: Now apk works — install your packages (python3 + pip + ffmpeg + curl)
# Use --no-cache to keep the layer small
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    curl

# Step 3: Install latest yt-dlp binary (recommended, no pip deps needed)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

# Optional: Pre-install the community node (uncomment if desired)
RUN npm install -g @rsraven/n8n-nodes-ytdlp-transcript
# OR
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

USER node
