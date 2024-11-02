# 1. Load the first image on app launch
## 1.1. Happy path
- Given the user opens the app
- When the app starts
- Then a new random coffee image should start loading automatically

## 1.2. Failure when loading the first image on app launch
- Given the user opens the app
- When the app tries to load the first image and a server error occurs
- Then the app should display an error message: "Unable to load a random image. A server error occurred, please try again later."