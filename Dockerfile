FROM quay.io/keboola/docker-custom-julia:0.1.0

WORKDIR /home

# Initialize the transformation runner
COPY . /home/

# Run the application
ENTRYPOINT julia ./main.jl --data=/data/
