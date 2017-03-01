FROM funasoul/libsbml
MAINTAINER Akira Funahashi "funa@bio.keio.ac.jp"

RUN apt-get -y update && apt-get install -y \
      libopencv-calib3d2.4 \
      libopencv-contrib2.4 \
      libopencv-core2.4 \
      libopencv-features2d2.4 \
      libopencv-flann2.4 \
      libopencv-gpu2.4 \
      libopencv-highgui2.4 \
      libopencv-imgproc2.4 \
      libopencv-legacy2.4 \
      libopencv-ml2.4 \
      libopencv-objdetect2.4 \
      libopencv-ocl2.4 \
      libopencv-photo2.4 \
      libopencv-stitching2.4 \
      libopencv-superres2.4 \
      libopencv-ts2.4 \
      libopencv-video2.4 \
      libopencv-videostab2.4 \
      libhdf5-cpp-8 \
      && rm -rf /var/lib/apt/lists/*

COPY lib/libspatialsim-docker.tar.gz /tmp/

RUN tar -C / -xzf /tmp/libspatialsim-docker.tar.gz
RUN rm /tmp/libspatialsim-docker.tar.gz
ENTRYPOINT ["spatialsimulator"]
