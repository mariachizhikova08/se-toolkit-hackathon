# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.27.3 AS build

WORKDIR /app
COPY . .

# Fix pubspec and get deps
RUN flutter pub get \
    && flutter build web --release --base-href /

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
