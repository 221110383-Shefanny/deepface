# Stage 1: Build React app
FROM node:18 AS build
WORKDIR /app

# Copy package files first
COPY package.json package-lock.json ./

# Install dependencies with verbose logging
RUN npm ci --verbose || npm install --verbose

# Copy source code
COPY src ./src
COPY public ./public

# Inject backend URL at build time
ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL

# Build React app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
