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

### 🎒 Item & Variable Splits
The script treats most game progress as changes in **Game Variables (VARs)**. It simplifies splitting by unifying everything into a variable-based system:
- **Items (VARs 0-39)**: All inventory items (Holomap, Magic Ball, etc.) are the first 40 variables.
- **Progress Variables**: Side-quests (Heal Dinofly, Joe), weather changes, and achievements.
- **Specific Flags**: A few internal flags (Blowtron, Super Jetpack) remain as specific states.

## ⚙️ Configuration
You can enable or disable specific splits in the LiveSplit **Layout Settings** -> **Scriptable Auto Splitter** -> **Settings**.

### Categories
- **Scenes**: Major location changes and transitions.
- **Items**: The first 40 variables representing your inventory.
- **MISC**: Specific challenges and side objectives.
- **Variables**: Dynamic game variables (VARs).

## 📝 Customizing Splits

### 1. Internal Settings
You can edit the `settingsTable` directly in the `.asl` script.
- **Format**: `new[] { "ParentID", "UniqueID", "Description" }`

### 2. External Configurations (.xml)
The script automatically loads all `.xml` files located in the **same directory** as the `.asl` file. This allows you to create custom split packs without modifying the script.

#### XML Structure
```xml
<Splits>
    <!-- Scene Split: Entry into Scene 138 -->
    <Split id="sc138" name="Otringal" />

    <!-- Transition Split: Scene 80 to 91 -->
    <Split id="sc80:sc91" name="Boss to Palace" />

    <!-- Variable Split (Default > 0): VAR 166 -->
    <Split id="var_166" name="Clear Weather" />

    <!-- Variable Split (Specific Value): VAR 40 equals 2 -->
    <Split id="var_40=2" name="Zoe Stage 2" />
</Splits>
```

#### VARs Naming Rules
- **Scenes**: `sc` + `SceneID` (e.g., `sc42`).
- **Transitions**: `scOld` + `:` + `scNew` (e.g., `sc10:sc11`).
- **Variables (VARs)**: 
    - `var_X`: Splits if Variable X > 0.
    - `var_X=Y`: Splits if Variable X is exactly Y.
    - *Note*: IDs are direct memory indices. `var_0` is the first variable. `var_169` is collecting the Incandescent Pearl.

### 🔍 Finding VAR Indices
You can find the game variable indices using these community tools:
- **[LBA2 Remake Editor](https://lba2remake.net/#editor=true)**: Web-based, very fast but can crash on certain scenes. Use the **"scripts"** tab to find all game variable changes / usage.
- **[LBArchitect v1.2](https://moonbase.kaziq.net/d.php?n=LBArchitect_1.2.zip)**: More reliable desktop tool for advanced exploration.

## 🛠️ Technical Info
- **Language**: ASL
- **Memory Address (VARs Base)**: `0x481E60` (Classic) / `0x269C10` (DOSBox)
- **Data Type**: All variables are read as 2-byte unsigned integers (`ushort`).
