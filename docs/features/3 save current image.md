# 3. Save the current image locally
## 3.1. Happy path
- Given the user is viewing a coffee image that is not marked as favorited
- When the user requests to save the current coffee image
- Then the image should be saved locally and the favorite icon should become enabled

## 3.2. Saving current image fails due to a write error
- Given the user is viewing a coffee image
- When the user requests to save the current coffee image and a write error occurs
- Then the app should display an error message: "Failed to save the image. Please try again later."