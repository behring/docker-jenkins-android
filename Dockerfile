FROM jenkins/jenkins:lts
MAINTAINER Behring Zhao <behring.zhao@gmail.com>

ARG ANDROID_SDK_TOOLS_ZIP=sdk-tools-linux-4333796.zip
ARG GRADLE_ZIP=gradle-6.1.1-bin.zip
# config proxy(if password contain @, use %40 replace it.)
# ENV http_proxy http://username:password@host:port
# ENV https_proxy https://username:password@host:port
ENV SDK_TOOLS_ZIP_NAME sdk-tools.zip
ENV GRADLE_ZIP_NAME gradle.zip
ENV ANDROID_HOME /opt/android/sdk
ENV GRADLE_HOME /opt/gradle
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$GRADLE_HOME/bin:$PATH

# https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_URL https://dl.google.com/android/repository/$ANDROID_SDK_TOOLS_ZIP
ENV GRADLE_URL https://services.gradle.org/distributions/$GRADLE_ZIP

USER root
RUN mkdir -p $ANDROID_HOME \
	&& mkdir -p $GRADLE_HOME

# Download Gradle and Android SDK Tools
RUN wget $ANDROID_SDK_TOOLS_URL -O $ANDROID_HOME/$SDK_TOOLS_ZIP_NAME
RUN wget $GRADLE_URL -O $GRADLE_HOME/$GRADLE_ZIP_NAME
#COPY ./$GRADLE_ZIP_NAME $GRADLE_HOME

RUN ls -al 	$ANDROID_HOME
RUN ls -al 	$GRADLE_HOME

# Install Gradle and Android SDK Tools
RUN mkdir -p $ANDROID_HOME \
	&& unzip $ANDROID_HOME/$SDK_TOOLS_ZIP_NAME -d $ANDROID_HOME/ \
	&& unzip $GRADLE_HOME/$GRADLE_ZIP_NAME -d $GRADLE_HOME/ \
	&& rm $ANDROID_HOME/$SDK_TOOLS_ZIP_NAME \
	&& rm $GRADLE_HOME/$GRADLE_ZIP_NAME


#Set sdk licenses, install platform-tools and required sdk, build-tools
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses \
	&& yes | android update sdk --no-ui --all --filter platform-tools,android-28,build-tools-28.0.3

RUN apt-get -y update && apt-get -y install vim

USER jenkins
# List desired Jenkins plugins here
RUN /usr/local/bin/install-plugins.sh workflow-aggregator git android-lint build-monitor-plugin
