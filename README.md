[![Build Status](https://travis-ci.com/keboola/julia-transformation.svg?branch=master)](https://travis-ci.com/keboola/julia-transformation)

Application which runs KBC transformations writen in Julia, interface is provided by [docker-bundle](https://github.com/keboola/docker-bundle).

## Installation
The application is registered as standard KBC component. To run locally, use

```
docker build -t juliatransformation .
docker run -v path_to_data_dir:/data/ juliatransformation
```

The core functionality is wrapped in a package, so it may be used directly in Julia like this:
```
using Pkg;
Pkg.add(PackageSpec(url="https://github.com/keboola/julia-transformation", rev="master"))
```

## License

MIT licensed, see [LICENSE](./LICENSE) file.
