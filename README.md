# Little Big Adventure 2 (Twinsen's Odyssey) Autosplitter

This is a dynamic autosplitter script (`.asl`) for **Little Big Adventure 2**, designed for use with [LiveSplit](https://livesplit.org/). It supports both the **Classic** Windows executable and the **DOSBox** emulated version.

## 🚀 Features

### 🖥️ Auto-Detection
The script automatically detects which version of the game is running:
- **Classic**: `tlba2c.exe` (uses module base address)
- **DOSBox**: `dosbox.exe` (automatically calculates the emulated RAM pointer)

### 🎬 Scene Splits
Automatically splits when entering specific scenes.
- **Standard Scene Splits**: Splits when entering a target scene (e.g., "Otringal - Upper City").
- **Transition Splits** 🔀: Supports splitting only when moving between specific scenes.
    - *Example*: `sc80:sc91` (Entering Emperor Palace *only* from the Final Boss Room).
    - These are indicated by a 🔀 symbol in the settings menu.

### 🎒 Item Splits
Splits immediately upon acquiring items or upgrades:
- **Inventory Items**: Holomap, Magic Ball, Dart, Sendell Ball, Tunic, Pearl, etc.
- **Key Items**: Pyramid Key, Wheel, Keys (Knarta, Sup, Mosqui, Blafard, Queen, Burgomaster).
- **Upgrades**: Laser Pistol (and Completed Pistolaser), Super Jetpack, Wizard Tunic, Blowtron.

### 🏆 Miscellaneous & Achievements
Splits on specific in-game events, side-quests, or tricks:
- **Quests**: Heal Dinofly, Heal Clam Joe, Heal Bowler.
- **Events**: Clear Weather, Mine Crane, Kiss Frog.
- **Economy**: "Kash Cow" (Collecting 500+ Kashes).
- **Speedrun Tricks**: Dog Hop, Kill Time Commando, "On Track".

## ⚙️ Configuration
You can enable or disable specific splits in the LiveSplit **Layout Settings** -> **Scriptable Auto Splitter** -> **Settings**.

### Categories
- **Scenes**: Major location changes (Emerald Moon, Zeelish Surface, Undergas).
- **Items**: Individual item pickups.
- **MISC**: Specific challenges and side objectives.

## 🛠️ Technical Info
- **Language**: C# (ASL)
- **Memory Watchers**:
    - `scene`: Current Scene ID
    - `kashes`: Current Money count
    - `in_ending_cutscene`: Flag for the game ending
    - `items_base`: Array of memory flags for inventory items
    - Various state-specific offsets for upgrades and side-quests.

## 📝 Customizing Splits
To add new splits, you can edit the `settingsTable` in the `.asl` script.
- **Format**: `new[] { "ParentID", "UniqueID", "Description", "OptionalOldSceneID" }`
- **Transition Split**: To create a transition split, use the format `scOld:scNew` for the ID (e.g., `"sc88:sc91"`).
