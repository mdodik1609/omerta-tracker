# Omerta Score Tracker

A Flutter application for tracking scores in the card game Omerta. The app allows you to create game sessions, add players, track scores, and manage game history.

Current Version: v1.2.0

[View Changelog](CHANGELOG.md)

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd omerta_fresh
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Building the App

### Android
```bash
flutter build apk --release
```
The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
Then open the iOS project in Xcode and archive it.

## Using the App

### Creating a New Game
1. On the home screen, enter an optional game name
2. Add at least 2 players using the player name input field
3. Click "Start New Game" to begin

### During the Game
1. View the leaderboard showing current scores and won games
2. Add new round scores:
   - Click the + button
   - Enter scores for each player
   - Optionally select a winner from the dropdown
   - **NEW**: Winner must have a score of 0 (game rule enforcement)
   - Click "Done" to save the round

### Managing the Game
- **NEW**: Access game management options via the menu button (⋮) in the app bar
- **NEW**: Edit last round functionality - modify scores and winner of the most recent round
- Edit game name and manage players
- Remove players using the edit game dialog
- Delete the game when finished
- View round scores history below the leaderboard
- **NEW**: See total rounds played in the round scores section

### Game Features
- Track scores for multiple players
- Record winners for each round
- **NEW**: Edit last round functionality with validation
- **NEW**: Dropdown menu for game management
- **NEW**: Total rounds counter display
- **NEW**: Improved menu performance and design integration
- Game rule enforcement - winners must have 0 score
- Improved round score display with better formatting
- Enhanced player removal functionality
- Better UI responsiveness and text handling
- View game history
- Manage multiple game sessions
- Persistent storage of game data

## Development

### Project Structure
- `lib/models/` - Data models
- `lib/screens/` - UI screens
- `lib/services/` - Business logic and data management
- `lib/widgets/` - Reusable UI components

### Dependencies
- provider: State management
- shared_preferences: Local storage
- intl: Date formatting
- uuid: Unique ID generation

## License

MIT
