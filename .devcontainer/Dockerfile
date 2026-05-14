FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm

# The base image ships a Yarn apt source whose signing key is no longer valid,
# which makes `apt-get update` fail during feature installation (docker-in-docker).
# Yarn is not used by this Python project, so the stale source is removed.
RUN rm -f /etc/apt/sources.list.d/yarn.list
