FROM quay.io/keboola/docker-custom-julia:2.1.0

WORKDIR /code

RUN julia -e "using Pkg; Pkg.add(PackageSpec(url=\"https://github.com/keboola/julia-component\", rev=\"master\"));"

# Initialize the transformation runner
COPY . /code/

# Run the application
CMD julia /code/main.jl
