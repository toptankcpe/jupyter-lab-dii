#!/bin/bash

JUPYTER_CONFIG_DIR="/home/$NB_USER/.jupyter"
mkdir -p "$JUPYTER_CONFIG_DIR"

cat <<EOF > "$JUPYTER_CONFIG_DIR/jupyter_server_config.py"
from s3contents import S3ContentsManager
import os
c.ServerApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = os.environ.get('S3_BUCKET', 'dii-dev')
c.S3ContentsManager.prefix = os.environ.get('S3_PREFIX', 'notebooks')
c.S3ContentsManager.region_name = os.environ.get('AWS_REGION', 'ap-southeast-7')
c.S3ContentsManager.endpoint_url = os.environ.get('S3_ENDPOINT_URL', 'https://s3.ap-southeast-7.amazonaws.com')
EOF
cd /home/$NB_USER