cpython:2.7.15-slim-stretch

LABEL maintaner="knownsec.com"

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}

ADD sources.list /etc/apt/

RUN apt-get update \
    && apt-get install -y net-tools wget jq rsync curl vim \
         iputils-ping --allow-unauthenticated \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && pip install -i https://pypi.doubanio.com/simple redis requests

WORKDIR /

CMD ["bash"]