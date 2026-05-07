# Skinning Beast Tracker

`Skinning Beast Tracker` is a World of Warcraft addon that helps you track skinning beast world quests and quickly see which targets are still unfinished.

## Features

- Tracks progress for these quests:
  - `88545` — Gloomclaw
  - `88526` — Silverscale
  - `88531` — Lumenfin
  - `88532` — Umbrafang
  - `88524` — Netherscythe
- Stores quest completion per character (`Character - Realm`).
- Resets tracked daily data after the 15:00 UTC quest reset window.
- Includes a minimap icon and addon UI toggle command.

## Requirements

- World of Warcraft interface version `120000+` (as defined in `SkinningBeastTracker.toc`).
- Bundled libraries:
  - `LibStub`
  - `LibDataBroker-1.1`
  - `LibDBIcon-1.0`

## Installation

1. Download or clone this repository.
2. Place the `SkinningBeastTracker` folder into:
   - `World of Warcraft/_retail_/Interface/AddOns/`
3. Launch World of Warcraft and ensure **Skinning Beast Tracker** is enabled in the AddOns list.

## Usage

- Use `/sbt` to open or toggle the addon UI.
- Use the minimap icon for quick access.
- Data is saved in the `SBT_Storage` saved variable.

## Project Files

- `Utils.lua` — helper functions for reset checks and character data updates.
- `SBT_Main.lua` — core addon setup, quest list, slash command, and shared contexts.
- `SBT_Unkilled.lua` — uncompleted quest handling/UI.
- `SBT_All_Character_Table.lua` — all-character progress display.
- `SBT_MinimapIcon.lua` — minimap icon and main frame integration.

## Author

- Jin
