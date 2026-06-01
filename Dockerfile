# Build Flutter web release, then serve static files with nginx.
# Final image is small (~50MB); only the build stage needs the Flutter SDK.

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter config --enable-web \
  && flutter build web --release

FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
