FROM pavics/workflow-tests:210527.1-update20210705

USER root

COPY notebooks /notebooks

COPY default_build_params /notebooks
COPY downloadrepos /notebooks
COPY binder/reorg-notebooks /notebooks

WORKDIR /notebooks

RUN ./downloadrepos; DEPLOY_PAVICS_LANDING_NB=1 ./reorg-notebooks; rm -rfv downloadrepos default_build_params reorg-notebooks; chown -R jenkins:jenkins .

RUN pip install https://github.com/Ouranosinc/xclim/archive/master.tar.gz

USER jenkins
