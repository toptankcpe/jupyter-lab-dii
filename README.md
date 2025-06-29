# JupyterLab with PySpark and S3 Integration

This repository provides a Docker-based setup for running JupyterLab integrated with PySpark and AWS S3 using `s3contents`. It supports multiple Python environments (3.9.21 & 3.12.9), with Apache Spark 3.5.5 and Iceberg support.

## Features

* JupyterLab environment preconfigured with multiple Python kernels (3.9.21, 3.12.9)
* Integration with AWS S3 for notebook storage
* Apache Spark and Iceberg libraries pre-installed

## Project Structure

```
jupyter-lab-dii/
├── Dockerfile                  # Docker image definition
├── docker-compose.yaml         # Docker compose configuration
├── entrypoint-jupyter.sh       # JupyterLab startup script
├── 01-s3config.sh              # Jupyter server configuration for S3
└── requirements.txt            # Python dependencies
```

## Quick Start

### 1. Clone Repository

```bash
git clone <your-repo-url>
cd jupyter-lab-dii
```

### 2. Configure AWS S3 (environment variables)

Edit the environment variables in `docker-compose.yaml`:

```yaml
environment:
  - AWS_REGION=ap-southeast-7
  - S3_BUCKET=dii-dev
  - S3_PREFIX=notebooks/your-username
  - S3_ENDPOINT_URL=https://s3.ap-southeast-7.amazonaws.com
```

### 3. Build and Run

```bash
docker-compose up --build -d
```

Access JupyterLab at: [http://localhost:8888](http://localhost:8888)

## Configuration Files

### Jupyter Server Configuration (`01-s3config.sh`)

Automatically configures JupyterLab to use S3 bucket as notebook storage:

```python
from s3contents import S3ContentsManager

c.ServerApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = os.environ.get('S3_BUCKET', 'dii-dev')
c.S3ContentsManager.prefix = os.environ.get('S3_PREFIX', 'notebooks')
c.S3ContentsManager.region_name = os.environ.get('AWS_REGION', 'ap-southeast-7')
c.S3ContentsManager.endpoint_url = os.environ.get('S3_ENDPOINT_URL', 'https://s3.ap-southeast-7.amazonaws.com')
```

## Environment Variables

Set the following environment variables in your `docker-compose.yaml`:

* `AWS_REGION`: AWS region for S3
* `S3_BUCKET`: Name of your S3 bucket
* `S3_PREFIX`: Folder path in your S3 bucket
* `S3_ENDPOINT_URL`: Custom S3 endpoint (useful for alternative providers)
* `NB_USER`: Jupyter notebook user
* `GRANT_SUDO`: Enable sudo access (yes/no)
* `CHOWN_HOME`: Adjust home directory permissions (yes/no)

## Included Python Packages

* PySpark
* Pandas
* PyArrow
* NumPy
* Boto3
* IPyKernel

(See `requirements.txt` for exact versions.)

## Kernels Included

* Python 3.9.21
* Python 3.12.9

## Notes

* Ensure AWS credentials or IAM roles are properly set to allow access to S3.
* Modify `requirements.txt` to add or remove additional packages as required.

## Troubleshooting

* Confirm environment variables are correctly set in `docker-compose.yaml`.
* Verify permissions for S3 access if encountering issues loading or saving notebooks.
