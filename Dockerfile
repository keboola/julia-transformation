FROM quay.io/keboola/docker-custom-julia:0.1.0

WORKDIR /code

RUN julia -e "using Pkg; Pkg.add(PackageSpec(url=\"https://github.com/keboola/julia-component\", rev=\"odin-init\"));"

# Initialize the transformation runner
COPY . /code/

# Run the application
ENTRYPOINT julia /code/main.jl
