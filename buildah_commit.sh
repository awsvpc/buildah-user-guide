#! /bin/bash

# Basic BASH script to build a python/flask container from scratch using buildah
# Script assumes that it is being run on Centos and tested on Centos 8 stream


# Install software dependencies
sudo yum install -y podman buildah skopeo


# Define the container context and mount to the filesystem.
# Container context id added to var $newcontainer
# Mount path is added to var $scratchmount
newcontainer=$(buildah from scratch)
scratchmnt=$(buildah mount $newcontainer)


# Install base structure and python into the container
# This is broken into 2 commands to flatten the RPM dependency tree
yum install --installroot $scratchmnt bash coreutils --releasever 8 --setopt=install_weak_deps=false --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8 -y

yum install --installroot $scratchmnt python3 python3-pip --releasever 8 --setopt=install_weak_deps=false --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8 -y


# Further optimise container size by cleaning up the yum cache
yum clean --installroot $scratchmnt all


# Use buildah run command to install flask web framework and dependencies
buildah run $newcontainer pip3 install flask


# Create a basic single route flask web app to test entrypoint.sh
# Copy the app directory to the root of the container context
mkdir -p ~/app

tee ~/app/app.py > /dev/null << EOF
from flask import Flask
app = Flask(__name__)
@app.route('/')
def index():
    return 'Web App with Python Flask!'
EOF

cp -r ~/app $scratchmnt


# Now the web app is in place define entrypoint.sh to start app when container is invoked
# Make the script executable and copy to the container using buildah copy
tee ~/entrypoint.sh > /dev/null << EOF
#! /bin/bash
export FLASK_APP=/app/app.py
/usr/local/bin/flask run
EOF

chmod775 ./entrypoint.sh
buildah copy $newcontainer ~/entrypoint.sh /


# Update the container config to use entrypoint.sh as the entry point script
# Update the metadata in the container to define author and creator
buildah config --entrypoint /entrypoint.sh $newcontainer
buildah config --author "Dale Stirling" --created-by "dalethestirling" --label name=python3-flask-demo $newcontainer


# Unmount the container context from the host and collit the changes to a layer in the container
buildah unmount $newcontainer
buildah commit $newcontainer python3-flask-demo
