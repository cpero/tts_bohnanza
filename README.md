# Bohnanza

A Tabletop Simulator mod for Bohnanza using [TTS Editor](https://sebaestschjin.github.io/tts-tools/editor/latest/).

## Setup

### Prerequisites

- Install the following VSCode extensions:
  - **TTS Editor** (`sebaestschjin.tts-editor`) - [Documentation](https://sebaestschjin.github.io/tts-tools/editor/latest/)
  - **Prettier** (`esbenp.prettier-vscode`) - For code formatting
  - **XML** (`redhat.vscode-xml`) - For XML UI files
  - **Run on Save** (optional) - For auto-formatting

### Linking to Your Existing TTS Save

1. **Open the workspace file:**
   - Open `tts_bohnanza.code-workspace` in VSCode
   - This ensures the TTS Editor settings are loaded

2. **Start Tabletop Simulator** and load your existing Bohnanza save

3. **Get the scripts from TTS:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Run command: **`TTS Editor: Get Objects`**
   - This downloads all scripts from your save to `.tts/objects/`

4. **Make your changes** in the `src/` directory

5. **Bundle and send back to TTS:**
   - Press `Ctrl+Shift+P`
   - Run command: **`TTS Editor: Save and Play`**
   - The extension will bundle your code and reload the game with your changes

### Project Structure

```
tts_bohnanza/
├── src/                    # Source code (edit here)
│   ├── global.lua         # Main global script entry point
│   ├── components/        # Game components
│   │   ├── field.lua      # Field component
│   │   ├── field.xml      # Field UI
│   │   ├── centerChecker.lua
│   │   └── centerChecker.xml
│   └── util/              # Utility modules
│       ├── array.lua
│       ├── constants.lua
│       ├── functions.lua
│       └── guidList.lua
├── .tts/                  # TTS Editor working directory (auto-generated)
│   ├── bundled/           # Bundled scripts ready for TTS
│   └── objects/           # Raw scripts from TTS
├── .ttsbundler.json       # Bundler configuration
├── Bohnanza.lua           # Entry point for bundler
└── tts_bohnanza.code-workspace  # VSCode workspace config
```

### Development Workflow

1. **Edit code** in the `src/` directory using modular Lua files
2. **Test changes:**
   - Run **`TTS Editor: Save and Play`** to bundle and reload in TTS
   - The bundler automatically combines all `require()` statements
3. **The workspace is configured with:**
   - Source directory: `src/`
   - Bundling enabled via `.ttsbundler.json`
   - TTS API globals for Lua language server

### Key TTS Editor Commands

- **`TTS Editor: Get Objects`** - Download scripts from TTS
- **`TTS Editor: Save and Play`** - Upload scripts and reload game
- **`TTS Editor: Update Object`** - Update single object without full reload
- **`TTS Editor: Execute`** - Run code snippet in TTS

### Configuration

The workspace file (`tts_bohnanza.code-workspace`) is already configured with:
- Source directory: `src/`
- Bundling enabled with `.ttsbundler.json`
- Lua 5.2 runtime (TTS uses Lua 5.2)
- TTS API globals for auto-completion
