FROM sharelatex/sharelatex:latest

RUN apt-get update && \
    apt-get install texlive-xetex latex-cjk-all -y && \
    apt-get install texmaker -y && \
    tlmgr update --all && \
    tlmgr install ctex && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
