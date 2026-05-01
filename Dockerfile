FROM alpine:3.20

ENV SCAN_TIME="0 2 * * *"
ENV SCAN_PATH="/scan"

# Base packages + GNU tools + compatibility
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    python3 \
    py3-pip \
    clamav \
    clamav-daemon \
    inotify-tools \
    coreutils \
    findutils \
    gawk \
    sed \
    grep \
    tar \
    musl-fts \
    libc6-compat \
    supervisor \
    dcron

# Install Flask
RUN pip install flask

# Update ClamAV signatures
RUN freshclam

# Install Maldet
RUN cd /usr/local/src && \
    wget https://www.rfxn.com/downloads/maldetect-current.tar.gz && \
    tar -xzf maldetect-current.tar.gz && \
    cd maldetect-* && \
    bash ./install.sh

# Configure Maldet to use ClamAV
RUN sed -i 's/clamav_scan="0"/clamav_scan="1"/' /usr/local/maldetect/conf.maldet

COPY scan.sh /usr/local/bin/scan.sh
RUN chmod +x /usr/local/bin/scan.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY webui /opt/webui

EXPOSE 8888

CMD ["/start.sh"]
