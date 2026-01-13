FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Step 1: Reinstall apk-tools (your original hardening workaround – keep it)
RUN ARCH=$(uname -m) && \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[^"]*\.apk"' | head -1 | cut -d'"' -f2 | \
    xargs -I {} wget -q "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/{}" && \
    tar -xzf apk-tools-static-*.apk && \
    ./sbin/apk.static -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-*.apk

# Step 2: Install build dependencies + runtime deps (added gcc musl-dev for cffi/compilation)
RUN apk update && apk upgrade && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        curl \
        unzip \
        ca-certificates \
        build-base \
        gcc \
        musl-dev \
        python3-dev \
        libffi-dev \
        openssl-dev

# Create venv
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip and install yt-dlp with curl-cffi (force reinstall if needed)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir "yt-dlp[default,curl-cffi]" --no-build-isolation || \
    echo "curl_cffi failed to build – impersonation may be limited (common on Alpine arm64)" && \
    pip install --no-cache-dir "yt-dlp[default]"  # fallback just in case

# Install Deno (your method is fine – official script works well on Alpine)
RUN curl -fsSL https://deno.land/install.sh | sh && \
    mv /root/.deno/bin/deno /usr/local/bin/deno && \
    rm -rf /root/.deno
ENV PATH="/usr/local/bin:$PATH"

# Your original npm globals
RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7
ENV NODE_PATH=/usr/local/lib/node_modules

# Optional community nodes
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

# Switch back to node user
USER node

# Debug layer – uncomment during testing (will show in build logs)
# RUN deno --version && \
#     yt-dlp --version && \
#     yt-dlp --list-impersonate-targets 2>&1 || echo "No impersonate targets available – check curl_cffi"
