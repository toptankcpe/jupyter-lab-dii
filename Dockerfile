FROM jupyter/base-notebook

USER root

# --- System Dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    curl \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    openjdk-11-jdk \
    sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Download Spark, Hadoop, and Iceberg JARs ---
RUN mkdir -p /opt/jars && \
    curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.782/aws-java-sdk-bundle-1.12.782.jar \
        -o /opt/jars/aws-java-sdk-bundle-1.12.782.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar \
        -o /opt/jars/hadoop-aws-3.3.4.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.8.1/iceberg-spark-runtime-3.5_2.12-1.8.1.jar \
        -o /opt/jars/iceberg-spark-runtime-3.5_2.12-1.8.1.jar && \
    curl -L https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.31.45/bundle-2.31.45.jar \
        -o /opt/jars/bundle-2.31.45.jar

# --- Install Python Libraries ---
RUN pip install s3contents \
    hybridcontents

COPY requirements.txt .
RUN pip install -r requirements.txt

# --- Install Python 3.9.21 and Python 3.12.9 ---
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.9.21/Python-3.9.21.tgz && \
    tar -xzf Python-3.9.21.tgz && \
    cd Python-3.9.21 && \
    ./configure --enable-optimizations && \
    make -j4 && \
    make altinstall && \
    rm -rf /tmp/*

WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tgz && \
    tar -xzf Python-3.12.9.tgz && \
    cd Python-3.12.9 && \
    ./configure --enable-optimizations && \
    make -j4 && \
    make altinstall && \
    rm -rf /tmp/*

COPY requirements.txt /tmp/requirements.txt
# --- Install pip + packages for both versions ---
RUN /usr/local/bin/python3.9 -m ensurepip && \
    /usr/local/bin/python3.9 -m pip install --upgrade pip && \
    /usr/local/bin/python3.9 -m pip install -r /tmp/requirements.txt

RUN /usr/local/bin/python3.12 -m ensurepip && \
    /usr/local/bin/python3.12 -m pip install --upgrade pip && \
    /usr/local/bin/python3.12 -m pip install -r /tmp/requirements.txt

# --- Register Jupyter Kernels ---
RUN /usr/local/bin/python3.9 -m ipykernel install --name python39 --display-name "Python 3.9.21" && \
    /usr/local/bin/python3.12 -m ipykernel install --name python312 --display-name "Python 3.12.9"

# --- Set JAVA_HOME ---
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# --- Entrypoint Script ---
COPY entrypoint-jupyter.sh /usr/local/bin/entrypoint-jupyter.sh
RUN chmod +x /usr/local/bin/entrypoint-jupyter.sh

# --- Set Hadoop Config for Spark to connect EMR ---
COPY 01-s3config.sh /usr/local/bin/before-notebook.d/01-s3config.sh
RUN chmod +x /usr/local/bin/before-notebook.d/01-s3config.sh

# default workdir
WORKDIR /home
