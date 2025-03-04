#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to stop script execution on failure
handle_error() {
    echo "Error: $1"
    exit 1
}

echo "Checking if Docker is installed..."

if ! command_exists docker; then
    echo "Docker not found! Installing Docker..."

    # Update package list and install dependencies
    sudo apt update || handle_error "Failed to update package list."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common || handle_error "Failed to install dependencies."

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || handle_error "Failed to add Docker’s GPG key."

    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || handle_error "Failed to add Docker repository."

    # Install Docker
    sudo apt update || handle_error "Failed to update package list after adding Docker repository."
    sudo apt install -y docker-ce docker-ce-cli containerd.io || handle_error "Failed to install Docker."

    # Enable and start Docker service
    sudo systemctl enable docker || handle_error "Failed to enable Docker service."
    sudo systemctl start docker || handle_error "Failed to start Docker service."

    echo "Docker installation complete!"
else
    echo "Docker is already installed."
fi

# Wait until Docker is fully started
echo "Waiting for Docker daemon to start..."
for i in {1..10}; do
    if sudo systemctl is-active --quiet docker; then
        echo "Docker is running!"
        break
    fi
    echo "Docker is not running yet. Retrying in 2 seconds..."
    sleep 2
    if [ "$i" -eq 10 ]; then
        handle_error "Docker failed to start after multiple attempts."
    fi
done

# Define Docker image and container names
IMAGE_NAME="my_docker_app"
CONTAINER_NAME="my_docker_container"
DOCKERFILE_DIR="."  # Change this if your Dockerfile is in another directory

echo "Building Docker image..."
sudo docker build -t $IMAGE_NAME $DOCKERFILE_DIR || handle_error "Failed to build Docker image."

echo "Removing any existing container with the same name..."
sudo docker stop $CONTAINER_NAME &> /dev/null || echo "No existing container to stop."
sudo docker rm $CONTAINER_NAME &> /dev/null || echo "No existing container to remove."

echo "Running Docker container..."
sudo docker run -d --name $CONTAINER_NAME -p 8081:8080 $IMAGE_NAME || handle_error "Failed to run Docker container."

echo "Docker container is running successfully!"
