# Used to test the bootstrapping script
FROM ubuntu:24.04

RUN apt-get update && apt-get install sudo -y

RUN usermod --append --groups sudo ubuntu

RUN echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER ubuntu
