# 5. View an specific favorite image
## 5.1. Happy path
- Given the user has previously saved images as favorites
- When the user selects a specific favorite image
- Then the app should open the coffee screen with the selected image displayed and the favorite icon should be enabled

## 5.2. Error during favorite image loading
- Given the user has previously saved images as favorites
- When the user selects a specific favorite image and an unexpected error occurs
- Then the app should return to the favorites screen and display an error message: "Failed to open your favorite image. Please try again later."