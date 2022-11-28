# we are starting to build our docker container based on the 
# python:3.9-alpine image.
FROM python:3.9-alpine

# make working directory 'code'
WORKDIR /code

RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev

# copy everything from the current folder (the one where this 
# Dockerfile lives) into the folder we created above. 
COPY requirements.txt requirements.txt

# use pip (the python package manager) to install in the container 
# whatever packages are listed in the requirements.txt file 
RUN pip install -r requirements.txt

# make port 5000 of the container available to the host machine
# port 5000 is the default port that a Flask app listens on. 
EXPOSE 4000

# execute the file app.py 
CMD ["python", "app.py"]