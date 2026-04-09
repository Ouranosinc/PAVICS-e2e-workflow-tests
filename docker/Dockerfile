# FIXME: This base needs to change to something closer to conda-forge
FROM continuumio/miniconda3
# No interactive apt calls
ENV DEBIAN_FRONTEND=noninteractive

# Use mamba for much improved performance over conda.
# The 'channel_priority strict' did help conda but it was not enough.
RUN chmod -R a+rwX /opt/conda && \
    conda config --prepend channels nodefaults || true && \
    conda config --remove channels defaults || true && \
    conda config --set channel_priority strict && \
    conda update --name base --channel conda-forge conda && \
    conda install --name base --channel conda-forge mamba && \
    mamba clean --all --yes

# To checkout other notebooks and to run pip install
# NOTE: All of these dependencies can be migrated to conda except for fonts-humor-sans and x11-utils
RUN apt-get update && \
    apt-get install -y git mercurial gcc unzip patch fonts-humor-sans firefox-esr x11-utils && \
    apt-get clean

# Create user jenkins for our Jenkins e2e notebooks test suite.
RUN groupadd --gid 1000 jenkins && \
    useradd --uid 1000 --gid jenkins --shell /bin/bash --create-home jenkins

# INFO: Outdated information - Consider removing
#
# Perform 2 stages install because one single 'conda env create -f
# /environment.yml' was taking forever to complete, same with mamba.
# Had to do this 2 stages install.  2 stages install was also taking forever
# with conda so had to switch to mamba.
#
# One single 'conda env create -f /environment.yml' takes forever because we
# removed all direct dependencies of xclim and ravenpy in /environment.yml for
# dependencies pinning by xclim and ravenpy to take effect.  This results in
# conda having a lot more packages to "solve" and it seems the solver
# performance dropped exponentially with the number of packages to solve.
#
# Conda was stuck at this step:
# DEBUG conda.common._logic:_run_sat(607): Invoking SAT with clause count: 2500273

# Copy birdy environment configuration
COPY environment.yml /environment.yml

# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
RUN umask 0000 && \
    mamba create --name birdy --file /environment.yml "python>=3.12,<3.13" --yes && \
    mamba env export --name birdy | tee /conda-env-export-final.yml && \
    mamba clean --all --yes && \
    du -sh /opt/conda 2>&1 | tee /conda-envs-size-final.txt

# Add birdy environment to the PATH
ENV PATH="/opt/conda/envs/birdy/bin:$PATH"

# Ensure that a default ipython kernel (python3) is available 
RUN python -m ipykernel install --name python3

# This should be "master" but commit
# https://github.com/jupyter/docker-stacks/commit/c772e98ac794173d6ed83a08ec249038b27ca3be
# is breaking with us since we do not have user jovyan.
ENV DOCKER_STACKS_COMMIT=709206ac8788475728cc9c992c25fb5f1501bc29

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
    chown jenkins /notebook_dir/writable-workspace && \
    mkdir -p /notebook_dir/pavics-homepage && \
    chown jenkins /notebook_dir/pavics-homepage && \
    chown root:root /notebook_dir && \
    chmod a-w /notebook_dir && \
    chmod a+rwX -R /opt/conda/envs/birdy/fonts && \
    mkdir -p /opt/conda/pkgs/cache && \
    chown jenkins:jenkins -R /opt/conda/pkgs/cache && \
    mkdir -p /usr/local/bin && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz -O /usr/local/bin/globusconnectpersonal-latest.tgz && \
    tar xzf /usr/local/bin/globusconnectpersonal-latest.tgz -C /usr/local/bin/ && \
    ln -vs /usr/local/bin/globusconnectpersonal*/globusconnectpersonal /usr/local/bin/globusconnectpersonal && \
    rm -v /usr/local/bin/globusconnectpersonal-latest.tgz

# For jupyter-panel-proxy launcher.
ENV BOKEH_ALLOW_WS_ORIGIN="*"

# For import xesmf since esmf-8.4.0, see: https://github.com/conda-forge/esmf-feedstock/issues/91
ENV ESMFMKFILE="/opt/conda/envs/birdy/lib/esmf.mk"

# For pyproj, to avoid error "PROJ: proj_create_from_database: Open of /opt/conda/envs/birdy/share/proj failed"
ENV PROJ_DATA="/opt/conda/envs/birdy/share/proj"

# To expose conda-installed compilers so that users can make use of them
ENV gcc=x86_64-conda-linux-gnu-gcc
ENV g++=x86_64-conda-linux-gnu-g++
ENV gfortran=x86_64-conda-linux-gnu-gfortran

# problem running start-notebook.sh when being root
# the jupyter/base-notebook image also do not default to root user so we do the same here
USER jenkins

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["conda", "run", "-n", "birdy", "/usr/local/bin/start-notebook.sh"]
