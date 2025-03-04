FROM node:latest as build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --prod

FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf

# COPY index.html /usr/share/nginx/html/index.html
COPY --from=build /app/dist/app /usr/share/nginx/html


EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

