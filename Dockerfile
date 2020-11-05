FROM jenkins/jenkins:lts
MAINTAINER Behring Zhao <behring.zhao@gmail.com>

ARG ANDROID_SDK_TOOLS_ZIP=sdk-tools-linux-4333796.zip
ARG GRADLE_VERSION=4.10.1

# ENV http_proxy='http://username:password@proxy.xxx.com:8080'
# ENV http_proxys='https://username:password@proxy.xxx.com:8080'


ENV GRADLE_NAME gradle-$GRADLE_VERSION
ENV GRADLE_ZIP gradle-$GRADLE_VERSION-bin.zip

ENV ANDROID_DIR /opt/android
ENV ANDROID_HOME ${ANDROID_DIR}/sdk
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/$GRADLE_NAME/bin:$PATH

# https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_URL https://dl.google.com/android/repository/$ANDROID_SDK_TOOLS_ZIP
ENV GRADLE_URL https://services.gradle.org/distributions/$GRADLE_ZIP
ENV JENKINS_HOME /var/jenkins_home

USER root

RUN apt-get -y update && apt-get -y install vim

# Download Gradle and Android SDK Tools
RUN wget -P /opt/ $GRADLE_URL \
	&& wget -P /opt/ $ANDROID_SDK_TOOLS_URL

# Install Gradle and Android SDK Tools
RUN mkdir -p $ANDROID_HOME \
	&& unzip /opt/$ANDROID_SDK_TOOLS_ZIP -d $ANDROID_HOME/ \
	&& unzip /opt/$GRADLE_ZIP -d $ANDROID_HOME/ \
	&& rm /opt/$ANDROID_SDK_TOOLS_ZIP \
	&& rm /opt/$GRADLE_ZIP

#Set sdk licenses, install platform-tools and required sdk, build-tools, need '--proxy=http --proxy_host=proxy.xxx.com --proxy_port=8080' when use proxy
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --list  \
	&& yes | $ANDROID_HOME/tools/bin/sdkmanager 'platform-tools' 'platforms;android-28' 'build-tools;28.0.3'
RUN chown -R jenkins:jenkins $ANDROID_DIR
RUN chown -R jenkins:jenkins $JENKINS_HOME

#Install flask
RUN apt-get install lsof && apt-get -y install python-pip && pip install Flask

USER jenkins
# List desired Jenkins plugins here
ENV JENKINS_UC_DOWNLOAD http://ftp-nyc.osuosl.org/pub/jenkins
RUN /usr/local/bin/install-plugins.sh workflow-aggregator git android-lint htmlpublisher build-monitor-plugin sonar extended-choice-parameter blueocean pipeline-utility-steps
