# ============================================
# Stage 1: Build React application
# ============================================
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

ARG VITE_API_URL=/api
ENV VITE_API_URL=${VITE_API_URL}

RUN npm run build


# ============================================
# Stage 2: Secure Apache runtime
# ============================================
FROM httpd:2.4-alpine

# Upgrade all Alpine packages to patched versions
RUN apk update && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

# Remove default Apache content
RUN rm -rf /usr/local/apache2/htdocs/*

# Copy React production build
COPY --from=builder /app/dist/ /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]
