# Suggested Commands

## Development Setup

### Install Mise (Version Manager)
```bash
brew install mise
```

### Install Tuist
```bash
mise install tuist
# Tuist version 4.38.2 will be installed as specified in .mise.toml
```

## Tuist Workflow

### Install Dependencies
```bash
mise x -- tuist install
```
Fetches all Swift Package Manager dependencies defined in Project.swift files.

### Generate Xcode Project
```bash
mise x -- tuist generate
```
Generates the Xcode workspace and projects from Tuist manifests.

### Build Project
```bash
mise x -- tuist build
```
Builds the project using Tuist's build system.

### Clean Generated Files
```bash
mise x -- tuist clean
```
Removes generated Xcode projects and derived data.

## Building with Xcode

### Open Workspace
```bash
open letscheers.xcworkspace
```

### Build with xcodebuild
```bash
xcodebuild \
  -workspace letscheers.xcworkspace \
  -scheme App \
  -configuration Debug \
  build
```

### Archive for Distribution
```bash
xcodebuild \
  -workspace letscheers.xcworkspace \
  -scheme App \
  -configuration Release \
  -archivePath ./build/App.xcarchive \
  archive
```

## Fastlane Deployment

### Deploy to TestFlight
```bash
fastlane ios release description:"Version changes" isReleasing:false
```

### Deploy to App Store (Submit for Review)
```bash
fastlane ios release description:"Version changes" isReleasing:true
```

## Git Operations

### Standard Git Commands
```bash
git status
git add <files>
git commit -m "message"
git push
git pull
```

### Git Secret (Encrypted Files)
```bash
# Install git-secret
brew install git-secret

# Reveal encrypted files (requires GPG key)
git secret reveal -p <password>

# Hide files again
git secret hide
```

## Version Management

### Update App Version
Edit `Projects/App/Configs/debug.xcconfig` and `release.xcconfig`:
```
MARKETING_VERSION=1.1.18
```

### Build Number
Build number is automatically incremented by fastlane during deployment.

## Debugging & Testing

### Run in Simulator
1. Open workspace: `open letscheers.xcworkspace`
2. Select scheme: `App`
3. Select simulator device
4. Press Cmd+R to build and run

### View Logs
Use Xcode console or device logs in Console.app on macOS.

## Darwin/macOS Specific Commands

### System Commands
```bash
# List files
ls -la

# Find files
find . -name "*.swift"

# Search in files (use grep or ripgrep)
grep -r "pattern" .
rg "pattern"

# Change directory
cd path/to/directory

# Copy files
cp source destination

# Move files
mv source destination

# Remove files (be careful!)
rm file
rm -rf directory
```

### Xcode Selection
```bash
# List installed Xcode versions
ls /Applications/ | grep Xcode

# Select specific Xcode
sudo xcode-select -s /Applications/Xcode_16.2.app

# Print current Xcode path
xcode-select -p
```

## Package Management

### Homebrew
```bash
# Install package
brew install <package>

# Update Homebrew
brew update

# Upgrade packages
brew upgrade
```

## Useful Shortcuts

### Xcode
- `Cmd+R`: Build and run
- `Cmd+B`: Build
- `Cmd+.`: Stop running
- `Cmd+Shift+K`: Clean build folder
- `Cmd+U`: Run tests

### Terminal
- `Ctrl+C`: Cancel running command
- `Ctrl+Z`: Suspend command
- `!!`: Repeat last command
- `!$`: Last argument of previous command
