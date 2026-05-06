#!/bin/bash

sudo mkdir -p /workspace/{src,build,cache,images,data,tools,tmp,notes,bin}
sudo chown -R sj:sj /workspace

sudo apt update
sudo apt install -y ccache
ccache --set-config=cache_dir=/workspace/cache/ccache
ccache --set-config=max_size=50G
ccache -s

