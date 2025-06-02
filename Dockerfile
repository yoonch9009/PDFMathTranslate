FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
EXPOSE 7860
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN uv pip install --system --no-cache -r pyproject.toml && babeldoc --version && babeldoc --warmup

COPY . .

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN uv pip install --system --no-cache . && \
    uv pip install --system --no-cache -U babeldoc "pymupdf<1.25.3" && \
    babeldoc --version && babeldoc --warmup

CMD ["pdf2zh", "--gui"]
