# martinlog_web

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Deploy
2
curl -sL https://firebase.tools | bash &&  firebase experiments:enable webframeworks &&  firebase init &&  firebase deploy


1
curl -sL https://firebase.tools | bash &&  firebase loggout && firebase login && firebase experiments:enable webframeworks &&  firebase deploy


server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;

    # Configurações adicionais...

    location / {
        try_files $uri $uri/ =404;
    }
}




Deploy: flutter clean && flutter build web --p lib/main_web.dart --dart-define URL_BASE=https://api.martinlog.com.br --dart-define APP_NAME="Plataforma Martin log" --dart-define PLATFORM=web && cd build/web && npx surge --project . --domain martinlog.surge.sh



flutter clean && flutter build apk --split-per-abi --dart-define URL_BASE=https://api.martinlog.com.br --dart-define PLATFORM=mobile --dart-define APP_NAME="Plataforma Martin log"