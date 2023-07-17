FROM golang:1.18 as builder

RUN apt-get update
RUN git clone https://github.com/pgaskin/easy-novnc.git
WORKDIR easy-novnc
RUN go build

WORKDIR /go
RUN git clone https://github.com/yudai/gotty.git
WORKDIR gotty
RUN go mod init && go mod tidy && go mod vendor
RUN go build

FROM debian:10 as final
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    sudo\
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    xterm \
    x11-xserver-utils \
    dbus-x11 

RUN mkdir ~/.vnc && echo "password" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd
RUN touch ~/.Xresources && echo "Xft.dpi: 96" > ~/.Xresources
RUN mkdir -p ~/.vnc && \
    echo "#!/bin/sh" > ~/.vnc/xstartup && \
    echo "xrdb ~/.Xresources" >> ~/.vnc/xstartup && \
    echo "dbus-launch startxfce4 &" >> ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

COPY --from=builder /go/easy-novnc/easy-novnc /usr/bin
COPY --from=builder /go/gotty/gotty /usr/bin

ENV USER=root

CMD ["bash", "-c", "vncserver :1 -geometry 1280x800 -depth 24; gotty -p 7654 -w /bin/bash & easy-novnc -p 5901"]
