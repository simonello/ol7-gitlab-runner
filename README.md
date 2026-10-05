# ol7-gitlab-runner

A **legacy Docker build environment** that runs
[GitLab Runner](https://docs.gitlab.com/runner/) on **Oracle Linux 7**,
pre-loaded with a C++/Java build toolchain. It exists to keep building and
testing legacy targets that require an EL7-era environment (GCC 4.8/7,
OpenJDK 8, Python 2, etc.) inside CI jobs.

> **Note:** Oracle Linux 7 is past end of life, and this image is frozen in
> time on purpose — everything in it is pinned for legacy compatibility.
> Don't use it as the basis for new work.

## Image contents

| Component | Version / source |
|---|---|
| Base OS | `oraclelinux:7-slim` |
| GitLab Runner | latest `linux-amd64` binary, SHA256-verified (see below) |
| C/C++ toolchain | GCC 4.8.5 (default) + devtoolset-7 (GCC 7.3.1, opt-in), autoconf, automake, libtool, bison, flex |
| Libraries | Boost (runtime + devel + static), OpenSSL (devel + static), krb5-devel, zlib |
| Java | OpenJDK 8 (+ devel), Ant |
| Python | Python 2 & 3, pip, setuptools, numpy |
| Math/Sci | BLAS, LAPACK, ATLAS, OpenBLAS |
| Misc | git, gtk2/X11 runtime libraries, DejaVu fonts |

The full package list is in [`requirements.txt`](requirements.txt).

### Compilers

Two GCC toolchains are installed, and the default is the *old* one — this is
deliberate, so legacy build scripts keep working unmodified:

- **GCC 4.8.5** (base OS) — first on `PATH`, used unless a job opts out
- **GCC 7.3.1** (devtoolset-7) — opt in per job when needed:

  ```bash
  source /opt/rh/devtoolset-7/enable   # prepends /opt/rh/devtoolset-7/root/bin to PATH
  ```

## Prerequisites

- Docker (or Docker Desktop)
- `make`, `curl`, `wget`, `sha256sum` on the build host

## Building

```bash
make            # download the runner binary, build the image, tag :latest
```

This runs three steps, which can also be invoked individually:

| Target | What it does |
|---|---|
| `make download` | Downloads the GitLab Runner binary into `bin/` and **verifies its SHA256 checksum** against the official manifest |
| `make build` | Builds `simonello/ol7-gitlab-runner:1.3` (`--no-cache`) |
| `make tag` | Tags the versioned image as `:latest` |
| `make push` | Pushes both tags to Docker Hub |
| `make clean` | Removes both local image tags |

The version/tag is controlled by the variables at the top of the
[`Makefile`](Makefile) (`IMAGE_VERSION`, `PUBLISHER`, `PROJECT`).

### Checksum verification

`make download` fetches the runner from the `latest/` directory on the
official GitLab S3 bucket, then downloads the *current* `release.sha256`
manifest and compares hashes (see [`bin/check`](bin/check)). If the checksum
doesn't match, the binary is deleted and the build stops. Both files are
git-ignored — never commit them.

## Running

The container's entrypoint starts the runner as the unprivileged
`gitlab-runner` user, expecting a config file at
`/etc/gitlab-runner/config.toml`:

```bash
docker run -d --name gitlab-runner --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /path/to/config:/etc/gitlab-runner \
  simonello/ol7-gitlab-runner:latest
```

Mounting the Docker socket lets jobs use the `docker` executor; drop that
volume if you only need the `shell` executor.

### Docker Compose

A working example lives in [`test/DockerCompose/`](test/DockerCompose/):

```bash
cd test/DockerCompose
docker compose up -d
```

It mounts `./config` as `/etc/gitlab-runner`, constrains the container to
4 CPUs / 8 GB RAM, and restarts it unless stopped.

> The committed `config.toml` is a **template with placeholder values** —
> replace `url` and `token` with your own before bringing the stack up.

## Registering a runner

For an unregistered runner, either edit `config.toml` by hand, or register
interactively:

```bash
docker run --rm -it \
  -v /path/to/config:/etc/gitlab-runner \
  simonello/ol7-gitlab-runner:latest \
  gitlab-runner register
```

On GitLab 16+, create the runner in the GitLab UI first
(**Admin/Project → Settings → CI/CD → Runners**) and use the authentication
token it gives you; the old registration-token flow has been removed.

## Project layout

```
├── Dockerfile              # image definition
├── Makefile                # download / build / tag / push / clean
├── entrypoint              # container entrypoint (execs gitlab-runner)
├── requirements.txt        # yum packages installed into the image
├── bin/
│   ├── check               # SHA256 verification script
│   └── (downloaded artifacts, git-ignored)
├── etc/                    # yum repo definitions + GPG key baked into the image
└── test/
    ├── Docker/             # quick interactive shell into the image
    └── DockerCompose/      # full compose example with config template
```

## Maintainer

Simon Smith <simon.r.smith@gmail.com>
