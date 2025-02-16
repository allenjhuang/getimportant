# Build a virtualenv using the appropriate Debian release
# * Install python3-venv for the built-in Python3 venv module (not installed by default)
# * Install gcc libpython3-dev to compile C Python modules
# * Update pip to support bdist_wheel
FROM docker.io/debian:buster-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip

# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

# Copy the the necessary files into the distroless image
FROM gcr.io/distroless/python3-debian10 AS pre
COPY --from=build-venv /venv /venv
COPY ./app /app

# Basically squashing the COPY commands in the final image
FROM gcr.io/distroless/python3-debian10
COPY --from=pre / /
ENV GUNICORN_CMD_ARGS="--workers=1 --worker-class=uvicorn.workers.UvicornWorker"
ENTRYPOINT ["/venv/bin/gunicorn", "app.main:app"]
