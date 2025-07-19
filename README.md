# RedCore

**RedCore** is the shared code and assets hub for Unity projects at Red Studios. The `Core/` folder contains common scripts, shaders, assets, and libraries that each project must reference via a directory junction (Windows) or symbolic link (macOS/Linux).

---

## 📁 Folder Structure

```
<workspace>/
├─ red-core/
│  ├─ Core/                # Shared source code and resources
│  └─ Junction Tool/       # Scripts to create junctions/symlinks
│     ├─ windows.bat       # Windows batch script
│     └─ macos.sh          # Bash script for macOS
│     └─ linux.sh          # Bash script for Linux
├─ vmonsters-forgotten-link/
│  └─ Assets/              # Unity Assets folder for project
└─ another-unity-project/
   └─ Assets/
```

> **Note:** All Unity projects must reside at the same hierarchy level as `red-core`.

---

## ⚙️ Prerequisites

* **Windows**: Run Command Prompt **as Administrator**.
* **macOS/Linux**: Bash (#!/usr/bin/env bash) available.

---

## ▶️ Setup Instructions

Run the appropriate script in `red-core/Junction Tool/` and follow the prompt to link `red-core/Core` into the target project’s `Assets/Core` folder.

### Windows

1. Open **Command Prompt** as **Administrator**.
2. Navigate to the Junction Tool folder:

   ```bat
   cd /d C:\GitHub\red-core\Junction Tool
   ```
3. Execute:

   ```bat
   windows.bat
   ```
4. Enter the number corresponding to your target project.

The script will:

* Remove any existing junction at `...\<project>\Assets\Core`.
* Create a new junction so that `C:\GitHub\<project>\Assets\Core` points to `C:\GitHub\red-core\Core`.

### macOS & Linux

1. Open **Terminal**.
2. Navigate to the Junction Tool folder:

   ```bash
   cd ~/GitHub/red-core/Junction\ Tool
   ```
3. Make the script executable (first time only):

   ```bash
   chmod +x macos.sh
   ```
4. Run:

   ```bash
   ./macos.sh
   ```
5. Enter the number corresponding to your target project.

The script will:

* Remove any existing `Assets/Core` link or directory in the target project.
* Create a new symbolic link so that `~/GitHub/<project>/Assets/Core` → `~/GitHub/red-core/Core`.

---

## 🔍 How It Works

* **Project Listing:** Both scripts scan the parent directory of `red-core` and number each sibling folder (excluding `red-core`).
* **User Selection:** You select the project by number.
* **Link Creation:**

  * **Windows:** uses `mklink /J <dest> <source>` for directory junctions.
  * **macOS/Linux:** uses `ln -s <source> <dest>` for symbolic links.

---

## 🛠️ Troubleshooting

* **Windows “Access denied”**: Ensure Command Prompt is running as Administrator.
* **macOS/Linux “Permission denied”**: Verify the script has execute permissions (`chmod +x macos.sh`).
* **Project Missing:** Confirm folder hierarchy and that the `red-core` directory name hasn’t been changed.

---

## 📄 License

This repository is licensed under the MIT License. See `LICENSE` for details.
