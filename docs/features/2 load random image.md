# 2. Load a new random coffee image
## 2.1. Happy path
- Given the user is viewing a coffee image
- When the user requests a new random coffee image
- Then a new coffee image should load and replace the current one

## 2.2. Failure when loading a new coffee image
- Given the user is viewing a coffee image
- When the user requests a new random coffee image and a server error occurs
- Then the app should display an error message: "Unable to load a new random image. A server error occurred, please try again later."