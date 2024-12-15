# Use the official Ubuntu base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Copy your files into the container
COPY . /app/

# Install any dependencies (optional)
RUN apt-get update && apt-get install -y \
    curl \
    vim \
    && apt-get clean

# Command to run when the container starts (optional)
CMD ["bash"]

