# PressHero

Our shaman never presses hero so here is a minimal World of Warcraft addon for group coordination of heroism/bloodlust/time warp effects in dungeons and raids.

## What does it do?

- Shows a huge, unmistakable alert in the center of your screen when you or a group member requests a heroism effect.
- The alert displays the correct spell name and icon for your class, spec, and faction (e.g., Time Warp for mages, Heroism/Bloodlust for shamans, Primal Rage/Harrier's Cry for hunters, Fury of the Aspects for evokers).

## Supported Classes & Spells

- **Shaman (Alliance):** Heroism
- **Shaman (Horde):** Bloodlust
- **Mage:** Time Warp
- **Evoker:** Fury of the Aspects
- **Hunter (Marksmanship):** Harrier's Cry
- **Hunter (Beast Mastery/Survival):** Primal Rage

## Usage

- `/presshero` — Request heroism from your group. Triggers the alert for all group members with the addon.
- `/herotestrecv` — Simulate receiving a heroism request (for testing the alert on yourself).
- `/herodebug` — Print debug info about your detected hero spell.

## Installation

1. Download the addon files.
2. Extract to your `World of Warcraft/_retail_/Interface/AddOns/` directory.
3. Create a folder named `PressHero` in the AddOns directory.
4. Place all addon files in the `PressHero` folder.
5. Restart World of Warcraft or reload your UI (`/reload`).

## Version

1.0

## Author

Dan Manez

## License

MIT License - see [LICENSE](LICENSE) file for details. 