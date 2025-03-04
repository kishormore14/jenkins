#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

echo "Checking if Docker is installed..."

if ! command_exists docker; then
    echo "Docker not found! Installing Docker..."

    # Update package list and install dependencies
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installation complete!"
else
    echo "Docker is already installed."
fi

# Define Docker image and container names
IMAGE_NAME="my_docker_app"
CONTAINER_NAME="my_docker_container"
DOCKERFILE_DIR="."  # Change this if your Dockerfile is in another directory

echo "Building Docker image..."
sudo docker build -t $IMAGE_NAME $DOCKERFILE_DIR

echo "Removing any existing container with the same name..."
sudo docker stop $CONTAINER_NAME &> /dev/null
sudo docker rm $CONTAINER_NAME &> /dev/null

echo "Running Docker container..."
sudo docker run -d --name $CONTAINER_NAME -p 8080:8080 $IMAGE_NAME  # Change ports if needed

echo "Docker container is running."
