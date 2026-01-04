# 🌱 Smart Waste Collection App

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Smart Waste App Logo" width="120" height="120">
</p>

<p align="center">
  <strong>A comprehensive mobile application for smart waste management</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#installation">Installation</a> •
  <a href="#firebase-setup">Firebase Setup</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
</p>

---

## 📖 About The Project

**Smart Waste Collection App** is a full-featured mobile application designed to revolutionize waste management. It connects users who need waste pickup services with collectors, all managed through an admin dashboard. The app promotes eco-friendly practices through a reward system and provides real-time tracking of waste collection.

### 🎯 Problem It Solves

- **Inefficient Waste Collection**: Traditional waste collection lacks scheduling and tracking
- **No User Engagement**: Users have no incentive to properly dispose of waste
- **Poor Communication**: No direct communication between users and collectors
- **Lack of Transparency**: No visibility into pickup status or collector location

---

## ✨ Features

### 👤 For Users
- 📅 **Schedule Pickups** - Request waste collection at your convenience
- 📍 **Location Selection** - Choose pickup location with interactive map
- 📊 **Track Status** - Real-time pickup status tracking
- 🏆 **Eco Points** - Earn rewards for recycling
- 🎁 **Redeem Rewards** - Convert eco points to vouchers
- 🔔 **Notifications** - Get updates on pickup status
- 🤖 **EcoBot Assistant** - AI chatbot for instant support
- 🌙 **Dark Mode** - Eye-friendly dark theme

### 🚛 For Collectors
- 📋 **Pickup Management** - View and manage assigned pickups
- ✅ **Status Updates** - Update pickup status in real-time
- 🗺️ **Navigation** - Get directions to pickup locations
- 📈 **Performance Stats** - Track completed pickups
- 🔔 **Push Notifications** - Receive new pickup alerts

### 👨‍💼 For Admins
- 📊 **Dashboard** - Overview of all system activities
- 👥 **User Management** - Manage all users and collectors
- 🚚 **Pickup Oversight** - Monitor all pickup requests
- 📈 **Analytics** - View system statistics
- 🎁 **Reward Approvals** - Approve reward redemption requests
- ⚙️ **System Settings** - Configure app settings

---

## 📱 Screenshots

### 🎨 Authentication Screens

<div align="center">

| Splash Screen | Welcome Screen | Phone Login |
|:-------------:|:--------------:|:-----------:|
| <img src="screenshots/auth/splash.png" width="200"/> | <img src="screenshots/auth/login_options.png" width="200"/> | <img src="screenshots/auth/phone_login.png" width="200"/> |
| **Light Theme Splash** | **EcoCollect Landing** | **OTP Verification** |
| Green gradient background with Smart Waste branding and recycling icon. Shows app tagline "Collection & Scheduling" and eco-friendly message. | Dark theme welcome screen featuring two login options: Phone (fast & secure OTP) and Email. Includes quick access buttons for scheduling, tracking, and rewards. | Phone number input with country code selector (+91 India). Supports OTP-based authentication with option to switch to email login. |

</div>

<div align="center">

| Email Login | Sign Up - Step 1 | Sign Up - Step 2 |
|:-----------:|:----------------:|:----------------:|
| <img src="screenshots/auth/email_login.png" width="200"/> | <img src="screenshots/auth/signup_step1.png" width="200"/> | <img src="screenshots/auth/signup_step2.png" width="200"/> |
| **Traditional Login** | **Personal Information** | **Contact & Address** |
| Dark theme email login with password field, visibility toggle, and "Forgot Password?" link. Alternative to phone authentication. | First step of three-step registration: collect user's full name. Green theme with progress indicator. Option to use Phone OTP for quick signup. | Second step: gather email, phone number, and complete address details (house/apt number, street, city, zip code, state). Includes back button for navigation. |

</div>

<div align="center">

| Sign Up - Step 3 |
|:----------------:|
| <img src="screenshots/auth/signup_step3.png" width="200"/> |
| **Security Setup** |
| Final registration step: create password with confirmation field. Shows password requirements (minimum 6 characters with letters and numbers). Includes visibility toggles for both password fields. |

</div>

### 📋 Screen Descriptions

#### **Splash Screen** (`splash.png`)
- **Theme**: Light with vibrant green gradient (#00FF88)
- **Design**: Minimalist splash with rounded square icon containing recycling symbol
- **Branding**: "Smart Waste" title with "Collection & Scheduling" subtitle
- **Footer**: Eco-friendly message with recycling emoji

#### **Welcome Screen** (`login_options.png`)
- **Theme**: Dark mode (#1A2332 background)
- **Branding**: "EcoCollect" with "Smart Waste Management" tagline
- **Icon**: Circular glowing recycling symbol with gradient effect
- **Login Options**:
  - 🟢 **Phone** - Fast & secure OTP verification (green button)
  - 🟣 **Email** - Use email & password (purple/gradient button)
- **Quick Actions**: Schedule Pickups, Track Status, Earn Rewards (icon buttons)
- **Footer**: "Sign Up Free" CTA for new users

#### **Phone Login** (`phone_login.png`)
- **Theme**: Dark mode with consistent styling
- **Icon**: Glowing phone symbol
- **Title**: "Phone Login" in gradient green text
- **Features**:
  - Country code selector with flag (India +91)
  - Phone number input field with icon
  - "Send OTP" primary action button
  - "OR" divider
  - "Login with Email" alternative button
- **Description**: "Enter your phone number to receive a one-time password"

#### **Email Login** (`email_login.png`)
- **Theme**: Dark mode matching app theme
- **Form Fields**:
  - Email address input with envelope icon
  - Password input with lock icon and visibility toggle
- **Actions**:
  - "Sign In" primary button
  - "Forgot Password?" recovery link
- **Footer**: "Sign Up Free" for new user registration
- **Alternative**: Phone OTP signup option

#### **Sign Up - Personal Info** (`signup_step1.png`)
- **Theme**: Light mode with green (#4CAF50) background
- **Progress**: Step 1/3 indicator (Personal → Contact → Security)
- **Title**: "Personal Info" with person icon
- **Fields**: Full Name input (placeholder: "John Doe")
- **Navigation**:
  - "Continue" primary action
  - "Sign In" link for existing users
- **Alternative**: "Sign Up with Phone OTP" for quick registration

#### **Sign Up - Contact Details** (`signup_step2.png`)
- **Theme**: Light mode with green accent
- **Progress**: Step 2/3 (completed Personal, active Contact)
- **Title**: "Contact Details" with phone icon
- **Contact Section**:
  - Email Address field
  - Phone Number field with international format
- **Address Section**:
  - House/Apartment Number
  - Street Name
  - City (half width) | Zip Code (half width)
  - State/Province
- **Navigation**: "Back" and "Continue" buttons
- **Icons**: Green icons for each field type (email, phone, home, street, city, location, map)

#### **Sign Up - Security** (`signup_step3.png`)
- **Theme**: Light mode with green theme
- **Progress**: Step 3/3 (all previous steps completed)
- **Title**: "Secure Your Account" with lock icon
- **Form**:
  - Password field with visibility toggle
  - Confirm Password field with visibility toggle
  - Info box: Password requirements (6+ characters, letters + numbers)
- **Actions**:
  - "Back" button
  - "Create Account" primary button (with checkmark)
- **Footer**: Alternative login/signup options
- **Password Requirements**: Clear light green info box with validation rules

---

### 🎯 Key UI Features Demonstrated

- ✅ **Dual Theme Support**: Light (green) and Dark (navy) modes
- ✅ **Multi-Step Registration**: Progressive 3-step signup process
- ✅ **Flexible Authentication**: Phone OTP, Email/Password, Quick Signup
- ✅ **Consistent Design**: Gradient buttons, rounded corners, icon consistency
- ✅ **User Guidance**: Progress indicators, helpful descriptions, password requirements
- ✅ **Accessibility**: Visibility toggles, back navigation, alternative login methods
- ✅ **Professional Branding**: Dual identity (Smart Waste/EcoCollect)

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time database |
| **Firebase Messaging** | Push notifications |
| **Provider** | State management |
| **Google Maps** | Location services |
| **Base64 Encoding** | Profile image storage |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── l10n/                        # Localization files
│   ├── app_en.arb
│   └── generated/
├── models/                      # Data models
│   ├── user_model.dart
│   ├── pickup_request.dart
│   └── reward_request.dart
├── providers/                   # State management
│   ├── user_provider.dart
│   └── theme_provider.dart
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── user/                    # User screens
│   │   ├── user_home_screen.dart
│   │   ├── request_pickup_screen.dart
│   │   ├── pickup_history_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── chatbot_screen.dart
│   │   └── ...
│   ├── collector/               # Collector screens
│   │   ├── collector_home_screen.dart
│   │   ├── collector_pickup_detail_screen.dart
│   │   └── collector_settings_screen.dart
│   └── admin/                   # Admin screens
│       ├── admin_home_screen.dart
│       ├── manage_users_screen.dart
│       ├── manage_collectors_screen.dart
│       └── ...
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── pickup_service.dart
│   ├── notification_service.dart
│   └── reward_service.dart
├── utils/                       # Utilities
│   └── app_theme.dart
└── widgets/                     # Reusable widgets
    └── shimmer_loading.dart
```

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase account

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rajaswamysunder/smart-waste-app.git
   cd smart-waste-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (for iOS development)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔥 Firebase Setup

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com)
- Create a new project
- Enable Authentication (Email/Password)
- Create Firestore database

### 2. Configure Firebase
- Download `google-services.json` (Android) and place in `android/app/`
- Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

### 3. Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /pickups/{pickupId} {
      allow read, write: if request.auth != null;
    }
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Firestore Collections Structure

```
users/
  └── {userId}/
      ├── name: string
      ├── email: string
      ├── role: "user" | "collector" | "admin"
      ├── phone: string
      ├── address: string
      ├── ecoPoints: number
      └── photoBase64: string

pickups/
  └── {pickupId}/
      ├── userId: string
      ├── collectorId: string
      ├── status: "pending" | "assigned" | "confirmed" | "in_progress" | "completed"
      ├── wasteTypes: array
      ├── address: string
      ├── location: geopoint
      ├── scheduledDate: timestamp
      ├── timeSlot: string
      └── createdAt: timestamp

notifications/
  └── {notificationId}/
      ├── userId: string
      ├── title: string
      ├── message: string
      ├── type: string
      ├── read: boolean
      └── createdAt: timestamp
```

---

## 🎨 Color Themes

| Role | Primary Color | Gradient |
|------|---------------|----------|
| **User** | 🟢 Green (#4CAF50) | Green gradient |
| **Collector** | 🔵 Blue (#2196F3) | Blue gradient |
| **Admin** | 🟣 Purple (#9C27B0) | Purple gradient |

---

## 📊 App Statistics

- **195** Files
- **29,000+** Lines of Code
- **3** User Roles
- **15+** Screens
- **5** Core Services
- **Dark/Light** Theme Support

---

## 🤖 EcoBot - AI Assistant

The app includes an intelligent chatbot called **EcoBot** that helps users with:
- 📅 Scheduling pickups
- 📍 Tracking orders
- 🏆 Understanding eco points
- ♻️ Waste type information
- ❓ General FAQs

---

## 🔮 Future Enhancements

- [ ] Push notification improvements
- [ ] Multi-language support (Tamil, Hindi)
- [ ] Payment gateway integration
- [ ] Live collector tracking on map
- [ ] Carbon footprint calculator
- [ ] Community leaderboard
- [ ] Waste analytics dashboard

---

## 👨‍💻 Developer

**Rajaswamy S**
- GitHub: [@Rajaswamysunder](https://github.com/Rajaswamysunder)
- Email: rajaswamy2004@gmail.com

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Firebase for backend services
- All contributors and testers

---

<p align="center">
  Made with ❤️ and Flutter
</p>

<p align="center">
  ⭐ Star this repo if you find it helpful!
</p>
