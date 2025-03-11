# User Stories for SensFusion App

## Overview
SensFusion is a mobile application designed to allow users to register, log in, view dynamic content from a server, and customize their notification preferences. The following user stories describe the key features and functionalities of the app.

---

## 1. Registration and Login

### User Story 1: Account Registration
**As a** new user  
**I want to** register an account by providing my email and password  
**So that** I can securely access the app.

**Acceptance Criteria:**
- A registration form is available with email and password fields.
- The form dismisses the keyboard after the registration button is tapped.
- The app saves the user’s credentials and displays a confirmation message upon successful registration.

### User Story 2: User Login
**As a** registered user  
**I want to** log in using my email and password  
**So that** I can access personalized content on the home screen.

**Acceptance Criteria:**
- The login view contains email and password fields.
- The app validates the entered credentials against the saved registration data.
- If the credentials are incorrect, an error alert is displayed.
- Successful login navigates the user to the Home view.

---

## 2. Home View and Dynamic Content

### User Story 3: Display Dynamic Server Content
**As a** user  
**I want to** see updated server content (image and text) on the home screen  
**So that** I can be informed with the latest information.

**Acceptance Criteria:**
- The home view loads an image asynchronously from a server URL.
- A loading indicator is shown while the image is being fetched.
- If the image fails to load, an error message is displayed.
- Server text is fetched asynchronously and displayed below the image.

### User Story 4: Visually Engaging Background
**As a** user  
**I want to** have an attractive background image on the home screen  
**So that** the app provides an immersive visual experience.

**Acceptance Criteria:**
- The home view includes a full-screen background image that scales appropriately for all devices.
- The background image does not interfere with the readability of the server content.

---

## 3. Notification Preferences

### User Story 5: Customize Notification Settings
**As a** user  
**I want to** choose which notifications I receive from the server  
**So that** I only get alerts that are relevant to me.

**Acceptance Criteria:**
- Tapping on the server image or server text opens a pop-up (sheet) with notification options.
- The pop-up provides toggles for different types of notifications (e.g., new messages, updates, promotions).
- The user's notification preferences are saved and used to filter future notifications.

---

## 4. Keyboard Handling and User Interface Adjustments

### User Story 6: Stable UI with Keyboard Interaction
**As a** user  
**I want the** app's form to maintain a clear view even when the keyboard is active  
**So that** I can complete registration without UI elements shifting undesirably.

**Acceptance Criteria:**
- The registration form is dynamically offset to remain visible when the keyboard appears.
- A fixed upward shift is applied to position the form higher on the screen.
- Tapping the registration button dismisses the keyboard so that the confirmation message is not obscured.

---

## 5. Navigation and Overall Usability

### User Story 7: Seamless Navigation Between Screens
**As a** user  
**I want to** navigate effortlessly between login, registration, and home screens  
**So that** I can access all app features with ease.

**Acceptance Criteria:**
- The app utilizes clear navigation links to move between screens.
- Each screen includes a descriptive navigation title.
- The overall layout is intuitive and responsive across different device sizes.

---
