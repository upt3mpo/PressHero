# Press Hero!

A World of Warcraft addon for coordinating Heroism/Bloodlust/Time Warp spells in Mythic+ dungeons and raids.

## Features

- **Group Coordination**: Request hero spells from your group members with a simple command
- **Multi-Class Support**: Works with all hero-type spells:
  - Shaman: Heroism/Bloodlust
  - Mage: Time Warp
  - Hunter: Primal Rage
  - Evoker: Fury of the Aspects
  - Drums: Drums of Fury
- **Smart Detection**: Automatically checks if players can cast hero spells (no cooldown, no debuffs)
- **Visual Alerts**: Screen flash and raid warning when hero is requested
- **Audio Feedback**: Plays raid warning sound for immediate attention
- **Debuff Awareness**: Checks for Sated, Temporal Displacement, and Exhaustion debuffs

## Installation

1. Download the addon files
2. Extract to your `World of Warcraft/_retail_/Interface/AddOns/` directory
3. Create a folder named `PressHero` in the AddOns directory
4. Place all addon files in the `PressHero` folder
5. Restart World of Warcraft or reload your UI (`/reload`)

## Usage

### Commands

- `/presshero` or `/hero` or `/lust` - Request hero from your group
- `/herostatus` - Check if you can cast hero and remaining cooldown
- `/presshero auto` - Automatically cast your hero spell when available

### How It Works

1. **Request Hero**: Use `/presshero` to send a request to your group
2. **Automatic Response**: Group members with available hero spells will receive an alert
3. **Visual Feedback**: Screen flashes and raid warning appears for immediate attention
4. **Smart Filtering**: Only players who can actually cast hero will be notified

### Supported Spells

- **Shaman**: Heroism (Alliance) / Bloodlust (Horde)
- **Mage**: Time Warp
- **Hunter**: Primal Rage
- **Evoker**: Fury of the Aspects
- **Profession**: Drums of Fury

## Requirements

- World of Warcraft Retail (Interface version 100207+)
- Must be in a group (party or raid)

## Version

Current Version: 0.2

## Author

Dan Manez

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Feel free to submit issues and enhancement requests!

## Localization

Currently supports:
- English

## Changelog

### Version 0.2
- Added support for Evoker: Fury of the Aspects
- Enhanced debuff detection
- Improved visual and audio feedback
- Added auto-cast functionality
- Added status checking command 