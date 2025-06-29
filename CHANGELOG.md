# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 22/06/2025

### Added
- **Edit Last Round functionality**: Modify scores and winner of the most recent round
- **Firefox-style dropdown menu**: Replaced separate action buttons with a unified menu system
- **Total rounds counter**: Display total rounds played in the round scores section
- **Improved menu performance**: Faster response times and better user experience
- **Enhanced menu design**: Integrated with game's visual aesthetic and color scheme

### Changed
- **UI Layout**: Replaced three separate action buttons (edit, edit last round, delete) with a single menu button (⋮)
- **Menu positioning**: Menu opens below the app bar header for better accessibility
- **Menu styling**: Matches game's design with proper colors, borders, and typography
- **Performance optimization**: Reduced widget rebuilding and improved responsiveness

### Fixed
- **Async gap warnings**: Resolved BuildContext usage across async operations
- **Menu positioning**: Fixed menu placement to open correctly below the app bar
- **Context safety**: Added proper mounted checks for async operations

### Technical Improvements
- **Code organization**: Extracted inline dialog code into separate methods
- **Type safety**: Improved function calls and error handling
- **Memory efficiency**: Better resource management and cleanup

## [1.1.0] - 22/06/2025

### Added
- Game rule enforcement: Winners must have a score of 0
- Enhanced player removal functionality with proper data cleanup
- Improved round score display with better formatting
- Better UI responsiveness and text handling
- Enhanced error handling for game operations

### Fixed
- Player removal now properly removes players from the game and cleans up their data
- Fixed score input clearing when changing winner selection in new round dialog
- Improved AppBar title display to prevent text trimming
- Enhanced validation messages with better user feedback
- Fixed game name editing functionality

### Changed
- Updated round score display to show all rounds with improved formatting
- Enhanced dialog layouts and user experience
- Improved error handling and validation feedback
- Better text overflow handling in UI components

## [1.0.0] - 07/06/2025

### Added
- Initial release of Omerta Score Tracker
- Game session management with customizable game names
- Player management system
- Score tracking for multiple players
- Round history tracking
- Winner selection for each round
- Persistent storage of game data
- Custom Omerta font integration
- Android and iOS platform support
- Modern UI with intuitive controls

### Features
- Create and manage multiple game sessions
- Add/remove players during the game
- Track scores and round history
- Select winners for each round
- Edit game names and player information
- Delete games when finished
- View comprehensive game statistics 