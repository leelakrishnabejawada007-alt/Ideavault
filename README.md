# Student Innovation Idea Vault
Flutter Web app. Mock API by default; pass --dart-define=API_BASE_URL=https://host to use a real REST backend.

    flutter create . --platforms web --project-name idea_vault
    rm -f test/widget_test.dart
    flutter pub get
    flutter analyze
    flutter test
    flutter run -d chrome
    flutter build web
