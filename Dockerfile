FROM node:16-alpine as build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build Angular application
RUN ng build --configuration production

# Nginx to serve the build
FROM nginx:1.21-alpine

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the build output to Nginx's public directory
COPY --from=build /app/dist/app /usr/share/nginx/html

# Expose the port that Nginx listens on
EXPOSE 8080

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
