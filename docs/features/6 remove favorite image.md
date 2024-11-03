# 6. Remove the current image from favorites
## 6.1. Happy path
- Given the user is viewing a coffee image marked as a favorite
- When the user chooses to unfavorite the current coffee image
- Then the image should be removed locally, and the favorite icon should change to an unfilled state

## 6.2. Removing current image fails due to a write error
- Given the user is viewing a coffee image
- When the user attempts to unfavorite the current coffee image and a write error occurs
- Then the app should display an error message: "Failed to unfavorite the image. Please try again later."