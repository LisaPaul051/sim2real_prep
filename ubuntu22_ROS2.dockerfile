FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Basics
RUN apt-get update && apt-get install -y \
    locales \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Locale (ROS often expects UTF-8)
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add ROS 2 apt repo + key
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS 2 + dev tools
RUN apt-get update && apt-get install -y \
    ros-humble-ros-base \
    ros-humble-demo-nodes-cpp \
    ros-humble-demo-nodes-py \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-pip \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Init rosdep (safe in docker; ignore error if already initialized)
RUN rosdep init || true
RUN rosdep update

# Auto-source ROS
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

WORKDIR /root/ws
CMD ["bash"]
