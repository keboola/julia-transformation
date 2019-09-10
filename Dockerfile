FROM quay.io/keboola/docker-custom-julia:0.1.0

WORKDIR /home

# Initialize the transformation runner
COPY . /home/

RUN julia -e "using Pkg; Pkg.add(PackageSpec(url=\"https://github.com/keboola/julia-component\", rev=\"odin-init\"));"

# Run the application
ENTRYPOINT julia ./main.jl --data=/data/
