# Flutter Shop App

## An online shopping application built with Flutter
This is a basic e-shop app that demonstrates the following features:
- User authentication/authorization using Firebase
- User-added products
- The ability to mark products as favorite
- The ability to add products to a cart and make orders
- Animations and transitions
- Connecting to a Firebase backend via HTTP

## Getting Started

To run the application, you need a Google account to set up a Firebase project for the app. In that project, set up a Realtime database instance and enable email/password authentication.
The app requires two environment variables:
- `FIREBASE_BASE_URL`: The url of the Realtime database (e.g. `https://<some-string>.firebasedatabase.app`)
- `GOOGLE_API_KEY`: The Firebase web API key used for Authentication

If not set, the app will default these environment variables to `''` and all backend requests will fail.
