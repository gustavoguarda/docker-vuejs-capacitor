FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV NODE_VERSION     18
ENV CORDOVA_VERSION  11.0.0
ENV GRADLE_VERSION   7.4.2
# ENV NPM_VERSION      9.8.1
ENV NPM_VERSION      10.0.0

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/32.0.0"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"
ENV PATH "${PATH}:/usr/local/gradle-${GRADLE_VERSION}/bin"

RUN dpkg --add-architecture i386 && \
    apt-get update -yqq && \
    apt-get install -y curl expect git libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 lib32z1 libbz2-1.0:i386 openjdk-17-jdk wget unzip vim && \
    apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest" && \
    /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;32.0.0" && \
    /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools" && \
    /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-31" && \
    /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-31;google_apis;x86_64"

CMD /opt/tools/entrypoint.sh built-in

# Install Node.js 16 and cordova
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Install Gradle
RUN wget "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
    unzip "gradle-$GRADLE_VERSION-bin.zip" -d /usr/local && \
    rm "gradle-$GRADLE_VERSION-bin.zip"

WORKDIR /app

RUN npm install -g npm@${NPM_VERSION}

# Install Capacitor
RUN npm install -g @capacitor/cli
RUN npm install @capacitor/android

# # Download and extract Android Studio
RUN mkdir /opt/android-studio

RUN wget -c https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.1.1.20/android-studio-2022.1.1.20-linux.tar.gz -O android-studio.tar.gz
RUN tar xf android-studio.tar.gz -C /opt/android-studio --strip-components=1
RUN rm -f android-studio.tar.gz

ENV CAPACITOR_ANDROID_STUDIO_PATH /opt/android-studio/bin/studio.sh

COPY entrypoint.sh /app

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]