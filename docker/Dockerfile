# Use micromamba for improved speed and reduced image size
FROM mambaorg/micromamba
# No interactive apt calls
ENV DEBIAN_FRONTEND=noninteractive

# Install all jupyter and docker build dependencies in base
COPY environment-base.yml /tmp/environment-base.yml
RUN micromamba install --yes --name base --file /tmp/environment-base.yml && \
    micromamba clean --all --yes

# Rename mambauser to jenkins for our Jenkins e2e notebooks test suite.
ARG NEW_MAMBA_USER=jenkins
ARG NEW_MAMBA_USER_ID=1000
ARG NEW_MAMBA_USER_GID=1000

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

# Copy environment file
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml

# Add additional fonts for matplotlib and widgets
RUN apt-get update && \
    apt-get install --yes fonts-humor-sans && \
    apt-get clean

# create env "birdy"
# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
#
# Perform two-stage install because one single 'conda env create -f /environment.yml'
# was taking forever to complete, same with mamba.
# Previously, one single 'conda env create -f /environment.yml' took forever because we
# removed all direct dependencies of xclim and ravenpy in /environment.yml for
# dependencies pinning by xclim and ravenpy to take effect.
# This resulted in conda having a lot more packages to "solve" and it seems the solver
# performance dropped exponentially with the number of packages to solve.
#
# Conda was stuck at this step:
# DEBUG conda.common._logic:_run_sat(607): Invoking SAT with clause count: 2500273
#
# As of March 2026, the new image uses mambaorg/micromamba and the libmamba solver by default. 

# Create birdy environment
RUN umask 0000 && \
    micromamba create --name birdy --file /tmp/environment.yml "python>=3.12,<3.13" --yes && \
    micromamba clean --all --yes

# Notebooks are hardcoded to lookup for kernel named 'birdy' created in the previous code block
RUN umask 0000 && \
    micromamba run --name birdy python -m ipykernel install --name birdy && \
    micromamba env export --name birdy | tee /conda-env-export-final.yml && \
    du -sh /opt/conda | tee /conda-envs-size-final.txt

# This should be "master" but commit
# https://github.com/jupyter/docker-stacks/commit/c772e98ac794173d6ed83a08ec249038b27ca3be
# is breaking with us since we do not have user jovyan.
ENV DOCKER_STACKS_COMMIT=709206ac8788475728cc9c992c25fb5f1501bc29

# Activate base environment
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# /notebook_dir for Pavics-landing notebooks to re-create Jupyter env layout:
# /notebook_dir/writable-workspace, /notebook_dir/pavics-homepage.
#
# Path to the /notebook_dir/pavics-homepage/tutorial_data/*.geojson files are
# hardcoded so users can copy the nb to writable-workspace/ dir and still be able
# to run them seemlessly from the Jupyter env (without having to also copy
# those *.geojson files with the notebooks).
RUN wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/base-notebook/start.sh --output-document /usr/local/bin/start.sh && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/base-notebook/start-singleuser.sh --output-document /usr/local/bin/start-singleuser.sh && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/base-notebook/start-notebook.sh --output-document /usr/local/bin/start-notebook.sh && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/base-notebook/fix-permissions --output-document /usr/local/bin/fix-permissions && \
    mkdir /etc/jupyter && \
    wget https://raw.githubusercontent.com/jupyter/docker-stacks/$DOCKER_STACKS_COMMIT/base-notebook/jupyter_notebook_config.py --output-document /etc/jupyter/jupyter_notebook_config.py && \
    chmod a+rx /usr/local/bin/start.sh /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.sh /usr/local/bin/fix-permissions && \
    chmod a+r /etc/jupyter/jupyter_notebook_config.py && \
    mkdir -p /notebook_dir/writable-workspace && \
    chown "${MAMBA_USER}" /notebook_dir/writable-workspace && \
    mkdir -p /notebook_dir/pavics-homepage && \
    chown "${MAMBA_USER}" /notebook_dir/pavics-homepage && \
    chown root:root /notebook_dir && \
    chmod a-w /notebook_dir && \
    mkdir -p /opt/conda/envs/birdy/fonts && \
    chmod a+rwX -R /opt/conda/envs/birdy/fonts && \
    mkdir -p /opt/conda/pkgs/cache && \
    chown "${MAMBA_USER}":"${MAMBA_USER}" -R /opt/conda/pkgs/cache && \
    touch /opt/conda/pkgs/pkgs.lock && \
    chown "${MAMBA_USER}":"${MAMBA_USER}" /opt/conda/pkgs/pkgs.lock && \
    mkdir -p /usr/local/bin && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz -O /usr/local/bin/globusconnectpersonal-latest.tgz && \
    tar xzf /usr/local/bin/globusconnectpersonal-latest.tgz -C /usr/local/bin/ && \
    ln -vs /usr/local/bin/globusconnectpersonal*/globusconnectpersonal /usr/local/bin/globusconnectpersonal && \
    rm -v /usr/local/bin/globusconnectpersonal-latest.tgz

# For jupyter-panel-proxy launcher.
ENV BOKEH_ALLOW_WS_ORIGIN="*"

# To supply the location of the RavenHydroFramework binary
# FIXME: This location should be provided via the raven-hydro package which would help with the discovery logic in RavenPy
ENV RAVENPY_RAVEN_BINARY_PATH="/opt/conda/envs/birdy/bin/raven"

# For import xesmf since esmf-8.4.0, see: https://github.com/conda-forge/esmf-feedstock/issues/91
ENV ESMFMKFILE="/opt/conda/envs/birdy/lib/esmf.mk"

# To avoid error "PROJ: proj_create_from_database: Open of /opt/conda/envs/birdy/share/proj failed"
# This simulates a real `conda activate birdy`.
ENV PROJ_DATA="/opt/conda/envs/birdy/share/proj"

# To expose conda-installed compilers so that users can make use of them
ENV gcc=x86_64-conda-linux-gnu-gcc
ENV g++=x86_64-conda-linux-gnu-g++
ENV gfortran=x86_64-conda-linux-gnu-gfortran

# JupyterLab cannot write to hidden folders by design
ENV XDG_CACHE_HOME="/home/${MAMBA_USER}/cache"

# problem running start-notebook.sh when being root
# the jupyter/base-notebook image also do not default to root user so we do the same here
USER $MAMBA_USER
# set entrypoint for jenkins to root
WORKDIR /

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["/usr/local/bin/_entrypoint.sh", "run", "/usr/local/bin/start-notebook.sh"]
