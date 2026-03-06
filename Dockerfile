# Claude Code Sandbox — batteries-included build environment
# Based on Ubuntu 24.04 LTS
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ── Core system & build essentials ───────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    # Build fundamentals
    build-essential \
    gcc g++ gdb \
    clang clang-format clang-tidy lldb \
    cmake ninja-build meson \
    make automake autoconf libtool \
    pkg-config \
    # Version control
    git git-lfs \
    # Network / download tools
    curl wget \
    # Archives
    zip unzip tar gzip bzip2 xz-utils zstd \
    # Scripting
    bash zsh fish \
    # Text / file tools
    jq yq ripgrep fd-find fzf bat \
    tree htop ncdu file \
    # Editors
    vim neovim \
    # TLS / crypto
    ca-certificates openssl \
    libssl-dev \
    # Shared libs often needed
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses-dev \
    libgdbm-dev \
    liblzma-dev \
    uuid-dev \
    # Process / system tools
    procps lsof strace \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# ── Python ────────────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages \
    uv \
    poetry \
    pipx \
    black isort ruff mypy \
    pytest httpx requests

RUN uv tool install brokk
# ── Node.js (via nvm) ─────────────────────────────────────────────────────────
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=22

RUN mkdir -p $NVM_DIR \
    && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH"

RUN . $NVM_DIR/nvm.sh \
    && npm install -g \
        npm@latest \
        yarn \
        pnpm \
        typescript \
        ts-node \
        tsx \
        eslint \
        prettier

# ── Go ────────────────────────────────────────────────────────────────────────
ENV GO_VERSION=1.26.0
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

# ── Rust ──────────────────────────────────────────────────────────────────────
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:$PATH"

RUN /root/.cargo/bin/cargo install \
    cargo-watch \
    cargo-edit \
    cargo-audit

# ── Java (JDK 21) ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# ── Ruby ──────────────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    ruby ruby-dev ruby-bundler \
    && rm -rf /var/lib/apt/lists/*

# ── Databases / data tools ────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# ── DevOps / infra tools ──────────────────────────────────────────────────────
# kubectl
RUN curl -fsSL https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Terraform
RUN apt-get update && apt-get install -y gnupg lsb-release \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── Shell config ──────────────────────────────────────────────────────────────
RUN echo 'source /usr/local/nvm/nvm.sh' >> /root/.bashrc \
    && echo 'export PATH="/root/.cargo/bin:$PATH"' >> /root/.bashrc \
    && echo 'export PATH="/usr/local/go/bin:$PATH"' >> /root/.bashrc

# ── Workspace ─────────────────────────────────────────────────────────────────
WORKDIR /workspace

# Mount your project here:   docker run -v $(pwd):/workspace ...

CMD ["brokk"]

