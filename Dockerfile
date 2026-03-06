FROM ghcr.io/brokkai/build-platform-image:v0.1.0

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ---- System packages & build tools ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core build essentials
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    # Version control
    git \
    git-lfs \
    # Networking & fetch
    curl \
    wget \
    ca-certificates \
    openssh-client \
    # Archive tools
    unzip \
    zip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    # Python ecosystem
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # Shell & scripting
    bash \
    jq \
    yq \
    less \
    vim-tiny \
    # Process & system
    procps \
    htop \
    sudo \
    # Docker CLI (for Docker-in-Docker or socket mounts)
    docker.io \
    # Misc dev libraries
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    pipx \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# ---- Create non-root user ----
RUN useradd -m -s /bin/bash -u 10000 brokk \
    && echo "brokk ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/brokk

# ---- Workspace ----
RUN mkdir -p /workspace && chown brokk:brokk /workspace
WORKDIR /workspace

USER brokk

# ---- Python common packages ----
RUN pipx install \
    uv \
    ruff \
    black \
    brokk \
    pytest

ENV PATH="/usr/local/go/bin:/home/brokk/.local/bin:${PATH}"

CMD ["brokk"]

