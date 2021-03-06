#!/bin/bash

# Name:         start.sh
# Description:  bring up a mercuryiss/kali docker container
# Date:         2018-04-18
# Author:       Alexi Chiotis - Mercury ISS

# command line arguments 
[ -z "$1" ] && echo "No container/hostname supplied." && exit 1
[ -z "$2" ] && echo "No persistent data path supplied." && exit 1
[ -z "$3" ] && echo "No scripts path supplied." && exit 1
[ -z "$4" ] && echo "No installers path supplied." && exit 1

CNAME="$1"
DATA_PATH="$2"
SCRIPTS="$3"
INSTALLERS="$4"

USERNAME="$USER"
HNAME="$CNAME"

# image will be built on first run
sudo docker build \
    --build-arg USERNAME=$USERNAME  \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    docker/ -t mercuryiss/kali 

# Share X socket with docker container for GUI apps, dirbuster etc.
# http://wiki.ros.org/docker/Tutorials/GUI - 3. The Isolated Way
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
# show X authorisation entries for $DISPLAY in numerical format, 
# mask the first 2 octets with ffff, merge these entries into .docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# --rm for ephemeral container, --net host to share host's network stack / /etc/hosts
sudo docker run -it --hostname "$HNAME" --name "$CNAME"\
    --user "$USERNAME" \
    --volume="$DATA_PATH":/data \
    --volume="$SCRIPTS":/scripts \
    --volume="$INSTALLERS":/installers \
    --volume="$XSOCK":"$XSOCK":rw \
    --volume="$XAUTH":"$XAUTH":rw \
    --env="XAUTHORITY=${XAUTH}" \
    --env="DISPLAY" \
    mercuryiss/kali sh -c "stty cols $(tput cols) rows $(tput lines) && bash"

