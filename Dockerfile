FROM jenkins/jenkins:lts
MAINTAINER Behring Zhao <behring.zhao@gmail.com>

ARG ANDROID_SDK_TOOLS_ZIP=sdk-tools-linux-4333796.zip
ARG JAVA_ZIP=jdk-8u271-linux-x64.tar.gz
ARG JAVA_VERSION=1.8.0_271

# ENV http_proxy='http://username:password@proxy.xxx.com:8080'
# ENV https_proxy='https://username:password@proxy.xxx.com:8080'

ENV ANDROID_DIR /opt/android
ENV JAVA_DIR /usr/lib/jvm
ENV ANDROID_HOME ${ANDROID_DIR}/sdk
ENV JAVA_HOME ${JAVA_DIR}/jdk${JAVA_VERSION}
ENV PATH $JAVA_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

# https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_URL https://dl.google.com/android/repository/$ANDROID_SDK_TOOLS_ZIP
ENV JENKINS_HOME /var/jenkins_home

USER root

# Download Android SDK Tools
RUN wget -P /opt/ $ANDROID_SDK_TOOLS_URL
# Download Android SDK Tools
COPY ./jdk $JAVA_DIR

# Install Android SDK Tools
RUN mkdir -p $ANDROID_HOME \
	&& unzip /opt/$ANDROID_SDK_TOOLS_ZIP -d $ANDROID_HOME/ \
	&& mkdir -p $JAVA_DIR \
	&& tar zxvf $JAVA_DIR/$JAVA_ZIP -C $JAVA_DIR \
	&& rm /opt/$ANDROID_SDK_TOOLS_ZIP \
	&& rm $JAVA_DIR/$JAVA_ZIP

#Set sdk licenses, install platform-tools and required sdk, build-tools, need '--proxy=http --proxy_host=proxy.xxx.com --proxy_port=8080' when use proxy
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager 'platform-tools' 'platforms;android-29' 'build-tools;29.0.3'
RUN chown -R jenkins:jenkins $ANDROID_DIR
RUN chown -R jenkins:jenkins $JENKINS_HOME

RUN apt-get -y update && apt-get -y install vim python2.7 python-pip
# 直接apt install nodejs后没有npm被安装，因此只有nodejs -v命令，没有node -v命令，导致sonar运行失败。
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 
RUN apt-get install -y nodejs

#Install flask
RUN pip install Flask Pillow

USER jenkins
# List desired Jenkins plugins here
ENV JENKINS_UC_DOWNLOAD http://ftp-nyc.osuosl.org/pub/jenkins
RUN /usr/local/bin/install-plugins.sh workflow-aggregator git android-lint htmlpublisher build-monitor-plugin sonar extended-choice-parameter blueocean pipeline-utility-steps
