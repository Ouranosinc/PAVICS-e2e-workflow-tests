FROM continuumio/miniconda3

# Use mamba for much improved performance over conda.
# The 'channel_priority strict' did help conda but it was not enough.
RUN conda update conda -n base && \
    conda install mamba conda-pack -n base -c conda-forge -c defaults && \
    conda clean --all --yes && \
    conda config --set channel_priority strict && \
    wget -qO- https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -C /usr/local -xvj bin/micromamba

# Default for micromamba is $HOME/micromamba which is wrong.
ENV MAMBA_ROOT_PREFIX="/opt/conda"

# to checkout other notebooks and to run pip install
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git mercurial gcc unzip patch fonts-humor-sans \
    firefox-esr x11-utils && \
    apt-get clean

# Create user jenkins for our Jenkins e2e notebooks test suite.
# Change /opt/conda folder permissions for jupyter-conda extension.
RUN groupadd --gid 1000 jenkins \
    && useradd --uid 1000 --gid jenkins --shell /bin/bash --create-home jenkins && \
    chmod -R a+rwX /opt/conda

COPY environment.yml /environment.yml

# create env "birdy"
# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
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
#
RUN umask 0000 && \
    mamba create --name birdy --channel conda-forge --channel defaults xclim ravenpy xscen python=3.11 --yes && \
    (conda env export --name birdy 2>&1 | tee /conda-env-export-phase1.yml) && \
    (du -sh /opt/conda 2>&1 | tee /conda-envs-size-phase1.txt) && \
    mamba env update --name birdy --file /environment.yml && \
    mamba clean --all --yes

# alternate way to 'source activate birdy'
ENV PATH="/opt/conda/envs/birdy/bin:$PATH"

# our notebooks are hardcoded to lookup for kernel named 'birdy'
# this python is from the birdy env above
RUN python -m ipykernel install --name birdy && \
    (conda env export --name birdy 2>&1 | tee /conda-env-export-final.yml) && \
    (diff --unified /conda-env-export-phase1.yml /conda-env-export-final.yml 2>&1 | tee /conda-env-export.diff) && \
    (du -sh /opt/conda 2>&1 | tee /conda-envs-size-final.txt)

# install using same channel preferences as birdy original env to not downgrade
# anything accidentally
# this is for debug only, all dependencies should be specified in
# environment.yml above
# RUN mamba install -c conda-forge -c cdat -c bokeh -c plotly -c defaults -n birdy nbdime

# build jupyterlab extensions installed by conda, see `jupyter labextension list`
# Supposedly not needed with jupyterlab v3 anymore but see
# https://github.com/jupyterlab/jupyterlab/issues/11726#issuecomment-998901247
# TODO: remove 'jupyter lab build' step once all extensions move to prebuilt extensions,
# see comment https://github.com/jupyterlab/jupyterlab/issues/11726#issuecomment-998917305
# Currently jupyter-dash is holding back this step, see
# https://github.com/plotly/jupyter-dash/issues/49
RUN jupyter lab build

RUN jupyter serverextension enable voila --sys-prefix \
    && jupyter serverextension enable panel.io.jupyter_server_extension --sys-prefix \
    && jupyter serverextension list
#    && jupyter labextension install jupyterlab-clipboard

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
    mkdir -p /notebook_dir/writable-workspace && chown jenkins /notebook_dir/writable-workspace && \
    mkdir -p /notebook_dir/pavics-homepage && chown jenkins /notebook_dir/pavics-homepage && \
    chown root:root /notebook_dir && chmod a-w /notebook_dir && \
    chmod a+rwX -R /opt/conda/envs/birdy/fonts && \
    mkdir /opt/conda/pkgs/cache && \
    chown jenkins:jenkins -R /opt/conda/pkgs/cache && \
    mkdir -p /usr/local/bin && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz -O /usr/local/bin/globusconnectpersonal-latest.tgz && \
    tar xzf /usr/local/bin/globusconnectpersonal-latest.tgz -C /usr/local/bin/ && \
    ln -vs /usr/local/bin/globusconnectpersonal*/globusconnectpersonal /usr/local/bin/globusconnectpersonal && \
    rm -v /usr/local/bin/globusconnectpersonal-latest.tgz

# For jupyter-panel-proxy launcher.
ENV BOKEH_ALLOW_WS_ORIGIN "*"

# For import xesmf since esmf-8.4.0, see
# https://github.com/conda-forge/esmf-feedstock/issues/91
ENV ESMFMKFILE="/opt/conda/envs/birdy/lib/esmf.mk"

# To avoid error "PROJ: proj_create_from_database: Open of
# /opt/conda/envs/birdy/share/proj failed"
# This simulates a real `conda activate birdy`.
ENV PROJ_DATA="/opt/conda/envs/birdy/share/proj"

# problem running start-notebook.sh when being root
# the jupyter/base-notebook image also do not default to root user so we do the same here
USER jenkins

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["conda", "run", "-n", "birdy", "/usr/local/bin/start-notebook.sh"]
