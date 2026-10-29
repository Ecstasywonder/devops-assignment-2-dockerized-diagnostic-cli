<!-- PORTFOLIO_STAR_V1 -->
# Dockerized Linux Diagnostic CLI

**Portfolio case study — Situation · Task · Action · Result (STAR)**

### Situation
A Bash diagnostic tool depended on each host's installed packages and environment.

### Task
Package repeatable diagnostic commands into a container with an executable health check and documented behavior.

### Action
Built an Alpine-based Docker image, CLI entrypoint, Docker Compose configuration, syntax checks and integration smoke tests covering valid and invalid usage.

### Result
The repository provides a runnable Docker/Compose diagnostic workflow and test script. No cloud or production deployment is claimed.

**Review the evidence:** [Dockerfile](Dockerfile) · [Integration tests](test.sh)

> **Scope:** Results describe what the repository documents; they are not blanket claims of production readiness. Original/upstream code is credited where applicable.

---

## Detailed project documentation

# DevOps Assignment 2 — Dockerized Diagnostic CLI

## Overview

A Bash-based Linux diagnostic CLI packaged in a lightweight
Alpine Linux Docker image.

The application provides system information, disk usage reports,
network connectivity checks, and built-in help.

No cloud deployment is required.

## Project Structure

```text
.
├── README.md
├── app/
│   ├── diagnostic.sh
│   └── health-check.sh
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── .gitignore
├── test.sh
└── grade.sh
```

## Requirements

- Linux environment
- Bash
- Git
- Docker Engine with access to the Docker daemon
- Docker Compose plugin
- Internet access for downloading the base image and packages
  during the initial build

## Available Commands

| Command | Description |
|---------|-------------|
| system | Display system information |
| network HOST | Resolve and check a host |
| disk | Display filesystem usage |
| help | Display usage instructions |

## Setup

Clone the repository:

```bash
git clone <repository-url>
cd devops-assignment-2-dockerized-diagnostic-cli
```

Build the Docker image:

```bash
docker build -t diagnostic-tool .
```

## Running with Docker

```bash
docker run --rm diagnostic-tool help
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool network localhost
```

## Running with Docker Compose

Build:

```bash
docker compose build
```

Run commands:

```bash
docker compose run --rm diagnostic help
docker compose run --rm diagnostic system
docker compose run --rm diagnostic disk
docker compose run --rm diagnostic network localhost
```

## Health Check

Run the application health-check script inside the container:

```bash
docker run --rm \
  --entrypoint /opt/diagnostic/health-check.sh \
  diagnostic-tool
```

The health check verifies that the diagnostic CLI is executable
and responds successfully to the help command.

## Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 0 | Successful operation |
| 1 | Operational or runtime failure |
| 2 | Invalid command or input |

## Testing

Validate Bash syntax:

```bash
bash -n app/diagnostic.sh
bash -n app/health-check.sh
bash -n test.sh
```

Run the automated integration tests:

```bash
./test.sh
```

The test suite covers:
- Help
- System information
- Disk information
- Invalid commands
- Missing commands
- Missing network hostname
- Invalid network hostname
- Localhost connectivity
- Application health check

Run the instructor-provided grader:

```bash
./grade.sh
```

## Docker Implementation

The Dockerfile:
- Uses Alpine Linux as its base image
- Installs required Linux diagnostic utilities
- Copies the Bash application into the image
- Sets executable permissions
- Defines the CLI entrypoint and default help command

The .dockerignore file excludes Git metadata, logs, secrets,
and unnecessary local development files.

## Assumptions and Limitations

- Diagnostics report information visible inside the container.
- Container filesystem and hostname values can differ from the host.
- Host networking and container networking may differ.
- ICMP ping can be blocked even when TCP services are reachable.
- Internet access may be needed for Docker image builds.
- The health check verifies basic CLI execution, not every subsystem.
- No external network ports or host directories are required.

## Git Workflow

Development used feature branches for CLI implementation,
Docker configuration, and automated testing.

Completed feature branches were merged into main.

## Grading

The instructor can clone the repository and execute:

```bash
./grade.sh
```

The application was tested on an Ubuntu Linux host using Docker.
