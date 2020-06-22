#!/bin/bash

setenforce 0
yum -y install nginx
systemctl start nginx
systemctl enable nginx
systemctl stop firewalld