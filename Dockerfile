FROM nvcr.io/nvidia/pytorch:24.01-py3

LABEL description="Docker container for DUSt3R with dependencies installed. CUDA VERSION"
ENV DEVICE="cuda"
ENV MODEL="DUSt3R_ViTLarge_BaseDecoder_512_dpt.pth"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git=1:2.34.1-1ubuntu1.10 \
    libglib2.0-0=2.72.4-0ubuntu2.2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo $CUDA_HOME
RUN ls -l $CUDA_HOME
RUN nvcc --version


RUN git clone --recursive https://github.com/msam13/dust3r_aws.git /dust3r
WORKDIR /dust3r
RUN pip install -r requirements.txt
RUN pip install -r requirements_optional.txt
RUN pip install opencv-python==4.8.0.74

RUN echo $CUDA_HOME
RUN ls -l $CUDA_HOME
RUN nvcc --version


# Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda-12.3/
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

RUN echo $CUDA_HOME
RUN ls -l $CUDA_HOME
RUN nvcc --version


WORKDIR /dust3r/croco/models/curope/
RUN python setup.py build_ext --inplace

RUN echo $CUDA_HOME
RUN ls -l $CUDA_HOME
RUN nvcc --version


WORKDIR /dust3r
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
