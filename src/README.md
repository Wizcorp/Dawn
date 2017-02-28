dawn binary
===========

The `dawn` binary is written in Go.

Requirements
------------

  - [glide](https://glide.sh/)

Build
-----

```bash
# Make a development build for your local environment
go run make.go

# Assign a version number to this build (default: development)
go run make.go --version [semver|development]

# Cross-compile (or build for all targets)
go run make.go --target [windows|darwin|linux|all]
```

You will find the built binary under the `./dist` folder
