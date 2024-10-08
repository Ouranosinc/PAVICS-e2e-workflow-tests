FROM pavics/workflow-tests:py311-241008

USER root

COPY notebooks /notebooks

COPY default_build_params /notebooks
COPY downloadrepos /notebooks
COPY binder/reorg-notebooks /notebooks

WORKDIR /notebooks

RUN ./downloadrepos; DEPLOY_PAVICS_LANDING_NB=1 ./reorg-notebooks; rm -rfv downloadrepos default_build_params reorg-notebooks; chown -R jenkins:jenkins .

#COPY binder/test-notebooks /notebooks

#RUN mkdir -p subdir1/subdir2; cp TEST-panel-servable.ipynb subdir1/servable1.ipynb; cp TEST-panel-servable.ipynb subdir1/subdir2/servable2.ipynb; cp TEST-panel-servable.ipynb TEST-panel-servable-Copy.ipynb

#RUN chown jenkins:jenkins -R .

# RUN pip install https://github.com/Ouranosinc/xclim/archive/master.tar.gz

USER jenkins
