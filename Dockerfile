FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
EXPOSE 7860
ENV PYTHONUNBUFFERED=1

# 환경 변수 설정
ENV CFLAGS="-march=x86-64 -mtune=generic -O2"
ENV CXXFLAGS="-march=x86-64 -mtune=generic -O2"

# OpenSSL 개발 패키지 포함하여 설치
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 \
    build-essential libssl-dev && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN uv pip install --system --no-cache -r pyproject.toml && babeldoc --version && babeldoc --warmup

COPY . .

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN uv pip install --system --no-cache . && \
    uv pip install --system --no-cache -U babeldoc "pymupdf<1.25.3" && \
    babeldoc --version && babeldoc --warmup

CMD ["pdf2zh", "--gui"]
