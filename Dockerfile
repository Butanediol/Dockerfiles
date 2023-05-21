FROM linuxserver/code-server:latest
ENTRYPOINT ["/init"]
EXPOSE 8443

COPY setup.sh /setup.sh

RUN echo "**** install swift-lang ****" && \
    curl -fsSL https://archive.swiftlang.xyz/swiftlang_repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/swiftlang_repo.gpg.key && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/swiftlang_repo.gpg.key] https://archive.swiftlang.xyz/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/swiftlang.list > /dev/null && \
    apt-get update && \
    apt-get install -y swiftlang make && \
    echo "**** install Vapor Toolbox" && \
    git clone https://github.com/vapor/toolbox.git && \
    cd toolbox && \
    make install && \
    cd .. && \
    rm -rf toolbox && \
    bash /setup.sh && \
    rm /setup.sh
