FROM python:3.9.5-slim

LABEL maintainer="MainKronos"


RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get -y install --no-install-recommends; \
    apt-get -y install ffmpeg; \
    apt-get -y install tzdata; \
    apt-get -y install locales && locale-gen it_IT.UTF-8; \
    apt-get clean; \
    apt-get autoclean; \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip

RUN pip3 install config --upgrade --no-cache-dir

COPY requirements.txt /tmp/

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

RUN groupadd --gid 1000 dockergroup
RUN useradd --no-log-init -r -m --gid dockergroup --uid 1000 dockeruser 

RUN mkdir /downloads && chown -R dockeruser /downloads
RUN mkdir /script && chown -R dockeruser /script

WORKDIR /script

COPY --chown=dockeruser:dockergroup config/ /script/

RUN chmod 777 /downloads -R 
RUN chmod 777 /script -R 

RUN sed -i -e 's/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=it_IT.UTF-8

ENV WERKZEUG_RUN_MAIN true
ENV FLASK_ENV production

USER dockeruser

ENV VERSION "1.7.4"

EXPOSE 5000

VOLUME [ "/downloads", "/script/json" ]

CMD ["python3","-u","/script/main.py"]