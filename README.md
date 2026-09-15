# Darood Tracker

A macOS menu bar app for tracking daily darood counts with a target of 1100.

## Features

### Core
- **Menu Bar App**: Lives in your menu bar for quick access
- **Daily Target**: Track 1100 darood (11 batches of 100)
- **Visual Progress**: Beautiful circular progress indicator
- **Batch Tracking**: Easy buttons to add 100 at a time
- **Calendar Views**: Day, week, month, and year views
- **Streak Tracking**: Track current and longest streaks
- **Daily Reminders**: Never miss your daily target
- **Data Export**: Export your tracking data

### Experiments (Toggle in Settings)
- **Onboarding Flow**: Welcome screens on first launch
- **Multiple Themes**: 8 beautiful color themes
- **Sound Effects**: Audio feedback on actions
- **Haptic Feedback**: Vibration on interactions
- **Celebration Animations**: Confetti on achievements
- **User Profile**: Track levels and milestones
- **Subgoals**: Break 1100 into smaller goals
- **Help Section**: Tips and FAQ

## Installation

### Option 1: Download Release
1. Go to the Releases page
2. Download the latest `DaroodTracker.app.zip`
3. Unzip and move to your Applications folder

### Option 2: Build from Source
1. Clone the repository
2. Open Terminal and navigate to the project directory
3. Run: `./build.sh`
4. The app will be in `build/DaroodTracker.app`
5. Copy to `/Applications/`

## Usage

### Menu Bar
- Click the star icon in the menu bar to open the tracker
- Use the batch buttons to add 100 darood at a time
- View your progress and streaks

### Daily Routine
1. **Morning**: Check your streak and plan your sessions
2. **Session 1**: Complete 100 darood (Batch 1)
3. **5-minute break**: Take a short break
4. **Session 2**: Complete another 100 darood
5. **Repeat**: Continue until you reach 1100 (11 batches)
6. **Evening**: Complete remaining batches before 6 PM

### Calendar Views
- Click "Calendar" to open the calendar view
- Switch between Day, Week, Month, and Year views
- Track your progress over time

### Subgoals
- Break your daily target into smaller goals
- Track progress for each subgoal
- Customize names, targets, and colors

### Profile
- View your total stats and milestones
- Earn levels as you progress
- Change your avatar

### Settings
- Choose from 8 color themes
- Enable/disable daily reminders
- Toggle experiments on/off
- Export your data

## Themes

| Theme | Colors |
|-------|--------|
| System | Blue, Purple |
| Light | Blue, Cyan |
| Dark | Cyan, Blue |
| Ocean | Deep Blue, Light Blue |
| Forest | Dark Green, Light Green |
| Sunset | Red, Orange |
| Royal | Dark Purple, Light Purple |
| Minimal | Gray, Black |

## Experiments

All features can be toggled in Settings > Experiments:

| Feature | Description |
|---------|-------------|
| Onboarding | Welcome screens on first launch |
| Themes | Multiple color themes |
| Sounds | Audio feedback |
| Animations | Celebration effects |
| Profile | User stats and milestones |
| Subgoals | Break down daily target |
| Help | Tips and FAQ |
| Haptics | Vibration feedback |
| Streaks | Consecutive day tracking |
| Weekly Report | Weekly summary |

## Data Storage

All data is stored locally on your Mac using UserDefaults. You can export your data at any time from Settings > Data > Export.

## Keyboard Shortcuts

- `⌘ + 1-9`: Quick add 1-9 batches
- `⌘ + 0`: Add 10 batches
- `⌘ + R`: Reset today's count
- `⌘ + ,`: Open settings

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
