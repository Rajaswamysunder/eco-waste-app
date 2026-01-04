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

### 🔐 Authentication

| Login Screen | Sign Up Screen | Email Verification |
|:---:|:---:|:---:|
| <img src="screenshots/auth/login.png" width="200"> | <img src="screenshots/auth/signup.png" width="200"> | <img src="screenshots/auth/verification.png" width="200"> |

---

### 👤 User Screens

| Home Dashboard | Request Pickup | Location Picker |
|:---:|:---:|:---:|
| <img src="screenshots/user/home.png" width="200"> | <img src="screenshots/user/request_pickup.png" width="200"> | <img src="screenshots/user/location_picker.png" width="200"> |

| Pickup History | Pickup Details | Track Pickup |
|:---:|:---:|:---:|
| <img src="screenshots/user/history.png" width="200"> | <img src="screenshots/user/pickup_detail.png" width="200"> | <img src="screenshots/user/track.png" width="200"> |

| Profile | Settings | Notifications |
|:---:|:---:|:---:|
| <img src="screenshots/user/profile.png" width="200"> | <img src="screenshots/user/settings.png" width="200"> | <img src="screenshots/user/notifications.png" width="200"> |

| Help & Support | EcoBot Chat | About |
|:---:|:---:|:---:|
| <img src="screenshots/user/help.png" width="200"> | <img src="screenshots/user/chatbot.png" width="200"> | <img src="screenshots/user/about.png" width="200"> |

---

### 🚛 Collector Screens

| Collector Dashboard | Pickup Management | Pickup Details |
|:---:|:---:|:---:|
| <img src="screenshots/collector/home.png" width="200"> | <img src="screenshots/collector/pickups.png" width="200"> | <img src="screenshots/collector/detail.png" width="200"> |

| Navigation Map | Notifications | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/collector/map.png" width="200"> | <img src="screenshots/collector/notifications.png" width="200"> | <img src="screenshots/collector/settings.png" width="200"> |

---

### 👨‍💼 Admin Screens

| Admin Dashboard | All Pickups | Manage Users |
|:---:|:---:|:---:|
| <img src="screenshots/admin/home.png" width="200"> | <img src="screenshots/admin/pickups.png" width="200"> | <img src="screenshots/admin/users.png" width="200"> |

| Manage Collectors | Reward Requests | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/admin/collectors.png" width="200"> | <img src="screenshots/admin/rewards.png" width="200"> | <img src="screenshots/admin/settings.png" width="200"> |

---

### 🌙 Dark Mode

| User Dark | Collector Dark | Admin Dark |
|:---:|:---:|:---:|
| <img src="screenshots/dark/user.png" width="200"> | <img src="screenshots/dark/collector.png" width="200"> | <img src="screenshots/dark/admin.png" width="200"> |

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
