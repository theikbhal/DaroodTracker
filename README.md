# Darood Tracker

A macOS menu bar app for tracking daily darood counts with a target of 1100.

## Features

- **Menu Bar App**: Lives in your menu bar for quick access
- **Daily Target**: Track 1100 darood (11 batches of 100)
- **Visual Progress**: Beautiful circular progress indicator
- **Batch Tracking**: Easy buttons to add 100 at a time
- **Calendar Views**: Day, week, month, and year views
- **Streak Tracking**: Track current and longest streaks
- **Reminders**: Daily reminders to complete your target
- **Data Export**: Export your tracking data

## Installation

### Option 1: Build from Source

1. Clone the repository
2. Open Terminal and navigate to the project directory
3. Run: `swift build -c release`
4. The app will be in `.build/release/DaroodTracker`

### Option 2: Download Release

1. Go to the Releases page
2. Download the latest `DaroodTracker.app.zip`
3. Unzip and move to your Applications folder

## Usage

### Menu Bar
- Click the star icon in the menu bar to open the tracker
- Use the batch buttons to add 100 darood at a time
- View your progress and streaks

### Calendar Views
- Click "Calendar" to open the calendar view
- Switch between Day, Week, Month, and Year views
- Track your progress over time

### Settings
- Enable/disable daily reminders
- Choose reminder time
- Show/hide dock icon
- Export your data

## Daily Routine

1. **Morning**: Check your streak and remaining count
2. **Throughout the day**: Add batches as you complete them
3. **Evening**: Complete remaining batches before 6 PM
4. **Review**: Check your calendar to see your progress

## Keyboard Shortcuts

- `⌘ + 1-9`: Quick add 1-9 batches
- `⌘ + 0`: Add 10 batches
- `⌘ + R`: Reset today's count
- `⌘ + ,`: Open settings

## Data Storage

All data is stored locally in UserDefaults. You can export your data at any time from Settings.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you have any questions or issues, please open an issue on GitHub.
