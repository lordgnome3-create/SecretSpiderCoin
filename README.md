# SecretSpiderCoin - WoW Addon

**Note:** The majority of this code was written by Claude (Anthropic's AI assistant) based on user requirements and iterative development during a conversation session.

## Description

SecretSpiderCoin is a World of Warcraft addon for Turtle WoW (vanilla 1.12) that allows you to track and manage a custom currency called "Secret Spider Coin" for players. It provides an intuitive interface for adding/removing coins, announcing transactions, and viewing leaderboards.

## Installation

1. Download the addon files
2. Create a folder named `SecretSpiderCoin` in your `Interface\AddOns\` directory
3. Place both `SecretSpiderCoin.lua` and `SecretSpiderCoin.toc` files in the folder
4. Restart WoW or reload UI (`/reload`)

## Features

### Core Functionality
- **Add/Remove Coins**: Silently add or remove coins from selected players
- **Add/Remove with Announcements**: Publicly announce coin transactions to selected chat channels
- **Persistent Storage**: All coin data is saved between sessions

### Player Selection
- **Scrollable Player List**: Select from:
  - All players who have received coins
  - Friends list
  - Guild members
  - Raid/Party members
- **Alphabetically Sorted**: Easy to find players

### Leaderboard
- **Top Holders List**: Scrollable list showing all coin holders ranked by amount
- **Real-time Updates**: List updates automatically when coins are added/removed

### Chat Integration
- **Multiple Chat Channels**: GUILD, PARTY, RAID, SAY, WHISPER
- **Whisper Tracking**: Automatically remembers the last person you whispered
- **Say Top 10**: Announce the top 10 coin holders to chat
- **Say Balance**: Announce a specific player's coin balance to chat

### User Interface
- **Minimap Button**: Click to open/close the main window
  - Tooltip: "SecretSpiderCoin - The only accepted coin of the village springdu"
- **Draggable Window**: Move the interface anywhere on screen
- **Status Messages**: Real-time feedback on all actions

## Commands

- `/ssc show` - Opens the addon window
- Click the minimap icon to toggle the window

## Usage Examples

### Adding Coins Silently
1. Click "Select" to choose a player from the dropdown
2. Enter amount in the Amount field
3. Click "Add"

### Adding Coins with Announcement
1. Select a player
2. Enter amount
3. Select desired chat channel (click "Change" to cycle through options)
4. Click "Add/Announce"
   - Announces: "[Player] has gained [X] Secret Spider Coin ([Total] total)"

### Removing Coins with Announcement
1. Select a player
2. Enter amount
3. Select chat channel
4. Click "Remove/Announce"
   - Announces: "[Player] has lost [X] Secret Spider Coin ([Total] total)"

### Announcing Leaderboard
1. Select chat channel
2. Click "Say Top 10"
   - Sends top 10 holders to selected channel

### Announcing Player Balance
1. Select a player
2. Select chat channel
3. Click "Say Balance"
   - Announces: "[Player] has [X] Secret Spider Coin"

## Technical Details

### File Structure
```
SecretSpiderCoin/
├── SecretSpiderCoin.toc
└── SecretSpiderCoin.lua
```

### Saved Variables
- `SecretSpiderCoinDB` - Stores all coin data persistently

### Data Format
```lua
SecretSpiderCoinDB = {
    ["PlayerName1"] = 100,
    ["PlayerName2"] = 50,
    -- etc.
}
```

### Events Handled
- `ADDON_LOADED` - Loads saved data
- `PLAYER_LOGOUT` - Saves data on logout
- `PLAYER_LEAVING_WORLD` - Saves data when leaving world
- `PLAYER_QUITING` - Saves data when quitting
- `CHAT_MSG_WHISPER` - Tracks incoming whispers
- `CHAT_MSG_WHISPER_INFORM` - Tracks outgoing whispers

## Interface Components

### Main Window
- **Title**: "Secret Spider Coin"
- **Size**: 420x550 pixels
- **Position**: Center of screen (draggable)

### Left Panel
- Player selection dropdown with scroll
- Amount input box
- Add/Remove buttons
- Add/Announce/Remove/Announce buttons
- Status text display

### Right Panel
- "Top Holders" leaderboard
- Scrollable list of all coin holders
- Ranked by coin amount (highest to lowest)

### Bottom Panel
- Chat channel selector
- "Say Top 10" button
- "Say Balance" button

### Minimap
- Coin icon button
- Hover tooltip with description

## Compatibility

- **Game Version**: World of Warcraft 1.12 (Vanilla)
- **Server**: Turtle WoW
- **Interface Version**: 11200

## Troubleshooting

### Data not saving
- Ensure the .toc file includes: `## SavedVariables: SecretSpiderCoinDB`
- Check that WoW has write permissions to the WTF folder

### Whisper not working
- Send or receive a whisper before using WHISPER chat mode
- The addon tracks the last whisper automatically

### Player list empty
- Make sure you're in a guild, have friends, or are in a party/raid
- Players with coins will always appear in the list

## Credits

**Development**: Primarily coded by Claude (Anthropic AI)  
**Concept & Requirements**: User-driven iterative design  
**Platform**: Turtle WoW (Vanilla 1.12)

## Version History

**v1.0** - Initial Release
- Core coin management system
- Scrollable player selection
- Scrollable leaderboard
- Multiple chat channel support
- Persistent data storage
- Minimap integration
- Announcement features
