# DriveWise

## Overview
DriveWise is a mobile application built with Flutter that helps users manage their vehicles, track maintenance, monitor driving behavior, and provide helpful vehicle-related services.

## Features
- Vehicle management and registration
- Maintenance tracking and scheduling
- User authentication and profile management
- Vehicle specifications and details viewing
- Quick lookup functionality for vehicle information
- Driving statistics and speed monitoring
- Product recommendations for vehicle care
- Store locator for service centers
- Theme customization options


## Project Structure
```
DriveWise/
├── .dart_tool
├── .idea
├── android/            # Android platform-specific code
├── assets/             # Application assets
│   ├── animations/     # Animation files
│   └── images/         # Image resources
├── build/              # Build outputs
├── ios/                # iOS platform-specific code
├── lib/                # Main application code
│   ├── models/         # Data models
│   │   └── vehicle.dart
│   ├── pages/          # UI screens
│   │   ├── auth screens (login, register)
│   │   ├── vehicle screens
│   │   ├── settings screens
│   │   └── other application screens
│   ├── providers/      # State management
│   │   └── theme_provider.dart
│   ├── services/       # Business logic and API services
│   │   ├── api_service.dart
│   │   ├── notification_service.dart
│   │   ├── product_rec_service.dart
│   │   ├── token_service.dart
│   │   └── vehicle_service.dart
│   ├── widgets/        # Reusable UI components
│   │   ├── main.dart
│   │   └── MainPage.dart
│   └── main.dart       # Application entry point
├── test/               # Unit and widget tests
├── .flutter-plugins
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
└── pubspec.yaml        # Project dependencies
```


## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- iOS development tools (for iOS deployment)

### Installation
1. Clone the repository:
   
   git clone https://github.com/chaniruM/DriveWise.git
   

2. Navigate to the project directory:
   
   cd drivewise
   

3. Install dependencies:
   
   flutter pub get
   

4. Run the application:
   
   flutter run
   

### Configuration
- Update the API endpoints in lib/services/api_service.dart to match your backend configuration
- Configure Firebase services if used for authentication or analytics

## Development

### Architecture
The application follows a layered architecture:
- UI Layer: Pages and Widgets
- Business Logic: Services and Providers
- Data Layer: Models and API Services

### Key Components
- *Models*: Define data structures for vehicles and user information
- *Pages*: UI screens for different app features
- *Services*: Handle API communication and business logic
- *Providers*: Manage application state and theme

## Contributing
1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add some amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

## License
[Include appropriate license information here]

# Contact

## Official Channels
- *Website*: [www.drivewiselk.com](https://www.drivewiselk.com/)
- *Email*: [drivewise.care@gmail.com]

## Social Media
- *Instagram*: [@_drivewise_](https://www.instagram.com/__drivewise__)
- *Facebook*: [DriveWise](https://www.facebook.com/share/162b7jrFa2/?mibextid=wwXIfr)
- *LinkedIn*: [DriveWise LK](https://www.linkedin.com/company/drivewise-lk)

## GitHub Repository
Project Link: [https://github.com/dula089/DriveWise_Backend_NodeJs.git](https://github.com/dula089/DriveWise_Backend_NodeJs.git)

## Feedback
Users can provide feedback through our application or via any of the contact channels listed above.
