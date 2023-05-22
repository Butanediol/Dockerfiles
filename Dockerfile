FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Install Tools
RUN apt-get update && \
	apt-get install -y zsh curl git ca-certificates gnupg && \
	chsh --shell /usr/bin/zsh root

# Install Code-Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install Swift
RUN curl -fsSL https://archive.swiftlang.xyz/swiftlang_repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/swiftlang_repo.gpg.key && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/swiftlang_repo.gpg.key] https://archive.swiftlang.xyz/ubuntu jammy main" | tee /etc/apt/sources.list.d/swiftlang.list > /dev/null && \
	apt-get update && \
	apt-get install -y swiftlang

VOLUME /root

CMD code-server --auth none --bind-addr 0.0.0.0:8080