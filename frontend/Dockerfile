# ------------------- Stage 1: Build Stage ------------------------------
FROM node:21 AS frontend-builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# 🔥 Build the production version
RUN npm run build


# ------------------- Stage 2: Production Stage -------------------------
FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from builder
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Expose port 80 (IMPORTANT)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
