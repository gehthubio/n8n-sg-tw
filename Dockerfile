FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Step 1: Reinstall apk-tools (critical - n8n removes it in v2.1+ for hardening)
RUN ARCH=$(uname -m) && \
    # Fetch the latest static apk-tools from Alpine repo
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[^"]*\.apk"' | head -1 | cut -d'"' -f2 | \
    xargs -I {} wget -q "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/{}" && \
    tar -xzf apk-tools-static-*.apk && \
    ./sbin/apk.static -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-*.apk

# Step 2: Now apk is available — update & install your packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        curl \
        unzip \
        ca-certificates \
        build-base \
        python3-dev \
        libffi-dev \
        openssl-dev

# Create venv for Python packages (avoids conflicts)
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install yt-dlp + extras (curl_cffi may skip on musl, but that's ok)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "yt-dlp[default]" && \
    (pip install --no-cache-dir curl_cffi || echo "curl_cffi skipped - impersonate limited")

# Install Deno via multi-stage copy
COPY --from=denoland/deno:alpine /deno /usr/local/bin/deno
ENV PATH="/usr/local/bin:$PATH"

# Your npm globals
RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7

ENV NODE_PATH=/usr/local/lib/node_modules

# Optional community nodes
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

USER node

# Optional: Debug checks (uncomment to verify in build logs)
# RUN deno --version && yt-dlp --version && yt-dlp --list-impersonate-targets || echo "Impersonate limited"
