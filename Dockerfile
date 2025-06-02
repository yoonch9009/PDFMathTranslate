FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
EXPOSE 7860
ENV PYTHONUNBUFFERED=1

# 최소 CPU 요구사항으로 컴파일 강제
ENV CFLAGS="-march=x86-64 -mtune=generic -O2"
ENV CXXFLAGS="-march=x86-64 -mtune=generic -O2"
ENV ARCHFLAGS="-arch x86_64"

RUN apt-get update && \
     apt-get install --no-install-recommends -y libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 build-essential && \
     rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .

# babeldoc와 관련 패키지를 소스에서 빌드
RUN uv pip install --system --no-cache --no-binary :all: numpy && \
    uv pip install --system --no-cache -r pyproject.toml

COPY . .

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

# 최종 설치도 소스에서 빌드
RUN uv pip install --system --no-cache . && \
    uv pip install --system --no-cache --force-reinstall --no-binary babeldoc -U babeldoc "pymupdf<1.25.3" && \
    babeldoc --version && babeldoc --warmup

CMD ["pdf2zh", "--gui"]
