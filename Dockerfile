FROM ubuntu:14.04
RUN sudo apt-get install python

EXPOSE 8080
CMD ["python", "./main.py"]