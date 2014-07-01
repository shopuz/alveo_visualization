FROM ubuntu:14.04
RUN sudo apt-get install -y python
RUN sudo apt-get update
RUN sudo apt-get install -y git

RUN git clone https://github.com/shopuz/alveo_visualization.git
WORKDIR /alveo_visualization
EXPOSE 8080
CMD ["python", "main.py"]