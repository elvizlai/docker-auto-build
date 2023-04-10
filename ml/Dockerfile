FROM nvidia/cuda:12.1.0-base-ubuntu22.04

RUN apt update \
    && apt install -y curl vim git \
        python3 python3-pip python3-venv \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip config set install.trusted-host https://pypi.tuna.tsinghua.edu.cn \
    && rm -rf /var/lib/apt/lists/*
