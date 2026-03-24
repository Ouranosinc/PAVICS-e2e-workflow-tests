# Use micromamba for improved speed and reduced image size
FROM mambaorg/micromamba
# No interactive apt calls
ENV DEBIAN_FRONTEND=noninteractive

# Install conda and mamba in base for mamba_gator
RUN micromamba install --yes --name base "conda>=4.7.12" "mamba>=2.0" && \
    micromamba clean --all --yes

# Rename mambauser to jenkins for our Jenkins e2e notebooks test suite.
ARG NEW_MAMBA_USER=jenkins
ARG NEW_MAMBA_USER_ID=1000
ARG NEW_MAMBA_USER_GID=1000

# Run username rename and environment setup as root
USER root
# Rename mambauser to jenkins; copied from mambaorg/micromamba documentation
RUN if grep -q '^ID=alpine$' /etc/os-release; then \
      # alpine does not have usermod/groupmod
      apk add --no-cache --virtual temp-packages shadow; \
    fi && \
    usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
        --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" \
        "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
    if grep -q '^ID=alpine$' /etc/os-release; then \
      # remove the packages that were only needed for usermod/groupmod
      apk del temp-packages; \
    fi && \
    # Update the expected value of MAMBA_USER for the
    # _entrypoint.sh consistency check.
    echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$NEW_MAMBA_USER

# Alias UID and GID for use with docker-stacks
ENV NB_USER=${MAMBA_USER}
ARG NB_GID="${NEW_MAMBA_USER_GID}"

# Save build configurations
RUN mkdir build-src

# Copy environment file
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /build-src/environment.yml

# Add additional fonts and x11-utils for matplotlib and firefox support
RUN apt-get update && \
    apt-get install --yes fonts-humor-sans wget x11-utils && \
    apt-get clean

# Create "birdy" environment
# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
RUN umask 0000 && \
    micromamba create --name birdy --file /build-src/environment.yml "python>=3.12,<3.13" --yes && \
    micromamba clean --all --yes

# Notebooks are hardcoded to lookup for kernel named 'birdy' created in the previous code block
RUN umask 0000 && \
    micromamba run --name birdy python -m ipykernel install --name birdy && \
    micromamba env export --name birdy | tee /build-src/conda-env-export-final.yml && \
    du -sh "${MAMBA_ROOT_PREFIX}" | tee /build-src/conda-envs-size-final.txt

# Docker-stacks commit from last time base-notebook was modified (2025/05/24)
ENV DOCKER_STACKS_COMMIT=e73d308ba06fd5bcc75a4ee8417711743860c964

# /notebook_dir for Pavics-landing notebooks to re-create Jupyter env layout:
# /notebook_dir/writable-workspace, /notebook_dir/pavics-homepage.
#
# Path to the /notebook_dir/pavics-homepage/tutorial_data/*.geojson files are
# hardcoded so users can copy the nb to writable-workspace/ dir and still be able
# to run them seemlessly from the Jupyter env (without having to also copy
# those *.geojson files with the notebooks).
RUN wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/start-singleuser.py --output-document /usr/local/bin/start-singleuser.py && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/start-singleuser.sh --output-document /usr/local/bin/start-singleuser.sh && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/start-notebook.py --output-document /usr/local/bin/start-notebook.py && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/start-notebook.sh --output-document /usr/local/bin/start-notebook.sh && \
    mkdir /etc/jupyter && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/jupyter_server_config.py --output-document /etc/jupyter/jupyter_server_config.py && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/images/base-notebook/docker_healthcheck.py --output-document /etc/jupyter/docker_healthcheck.py && \
    chmod a+rx /usr/local/bin/start-singleuser.py /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.py /usr/local/bin/start-notebook.sh /etc/jupyter/docker_healthcheck.py && \
    chmod a+r /etc/jupyter/jupyter_server_config.py && \
    mkdir -p /notebook_dir/writable-workspace && \
    chown "${MAMBA_USER}" /notebook_dir/writable-workspace && \
    mkdir -p /notebook_dir/pavics-homepage && \
    chown "${MAMBA_USER}" /notebook_dir/pavics-homepage && \
    chown root:root /notebook_dir && \
    chmod a-w /notebook_dir && \
    mkdir -p "${MAMBA_ROOT_PREFIX}/envs/birdy/fonts" && \
    chmod a+rwX -R "${MAMBA_ROOT_PREFIX}/envs/birdy/fonts" && \
    mkdir -p "${MAMBA_ROOT_PREFIX}/pkgs/cache" && \
    chown "${MAMBA_USER}":"${MAMBA_USER}" -R "${MAMBA_ROOT_PREFIX}/pkgs/cache" && \
    touch "${MAMBA_ROOT_PREFIX}/pkgs/pkgs.lock" && \
    chown "${MAMBA_USER}":"${MAMBA_USER}" "${MAMBA_ROOT_PREFIX}/pkgs/pkgs.lock" && \
    mkdir -p /usr/local/bin && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz -O /usr/local/bin/globusconnectpersonal-latest.tgz && \
    tar xzf /usr/local/bin/globusconnectpersonal-latest.tgz -C /usr/local/bin/ && \
    ln -vs /usr/local/bin/globusconnectpersonal*/globusconnectpersonal /usr/local/bin/globusconnectpersonal && \
    rm -v /usr/local/bin/globusconnectpersonal-latest.tgz && \
    rm -rf /tmp/*

# Activate base environment
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Set birdy as the default kernel
RUN echo "c.MultiKernelManager.default_kernel_name = 'birdy'" >> /etc/jupyter/jupyter_server_config.py

# For jupyter-panel-proxy launcher.
ENV BOKEH_ALLOW_WS_ORIGIN="*"

# To supply the location of the RavenHydroFramework binary
# FIXME: This location should be provided via the raven-hydro package which would help with the discovery logic in RavenPy
ENV RAVENPY_RAVEN_BINARY_PATH="${MAMBA_ROOT_PREFIX}/envs/birdy/bin/raven"

# For import xesmf since esmf-8.4.0, see: https://github.com/conda-forge/esmf-feedstock/issues/91
ENV ESMFMKFILE="${MAMBA_ROOT_PREFIX}/envs/birdy/lib/esmf.mk"

# To avoid error "PROJ: proj_create_from_database: Open of ${MAMBA_ROOT_PREFIX}/envs/birdy/share/proj failed"
# This simulates a real `conda activate birdy`.
ENV PROJ_DATA="${MAMBA_ROOT_PREFIX}/envs/birdy/share/proj"

# To expose conda-installed compilers so that users can make use of them
ENV gcc=x86_64-conda-linux-gnu-gcc
ENV g++=x86_64-conda-linux-gnu-g++
ENV gfortran=x86_64-conda-linux-gnu-gfortran

# JupyterLab cannot write to hidden folders by design
ENV XDG_CACHE_HOME="/home/${MAMBA_USER}/cache"

# Healthcheck - Requires NB_USER variable (copied from Docker-stacks)
HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 CMD /etc/jupyter/docker_healthcheck.py || exit 1

# Run the jupyterlab environment as the user
USER $MAMBA_USER
# Activate birdy environment
ENV ENV_NAME=birdy
# Set conda-forge as default channel for conda
RUN conda config --append channels conda-forge

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["/usr/local/bin/_entrypoint.sh", "run", "/usr/local/bin/start-notebook.sh"]
