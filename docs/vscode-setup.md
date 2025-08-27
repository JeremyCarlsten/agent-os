# VSCode Setup Guide

## Overview

Agent OS now supports VSCode with GitHub Copilot, providing the same powerful spec-driven development workflows available in Claude Code and Cursor.

## Installation

### Option 1: Automatic Detection

If your project already has a `.vscode` directory or `.code-workspace` file, Agent OS will automatically detect and configure VSCode support when you run the setup script.

### Option 2: Explicit VSCode Flag

```bash
# Install Agent OS with VSCode support
./setup/project.sh --vscode
```

## What Gets Installed

When VSCode support is enabled, Agent OS creates:

### .vscode/settings.json
- Excludes Agent OS research findings from file explorer
- Configures markdown file associations
- Optimizes search patterns for Agent OS workflows

### .vscode/tasks.json
- **Agent OS: Plan Product** - Set the mission & roadmap for a new product
- **Agent OS: Analyze Product** - Set up mission and roadmap for existing product  
- **Agent OS: Create Spec** - Create a spec for a new feature
- **Agent OS: Create Tasks** - Generate task breakdown from spec
- **Agent OS: Execute Tasks** - Build and ship code for new feature

### .vscode/extensions.json
Recommended extensions:
- GitHub Copilot
- GitHub Copilot Chat
- VSCode JSON support
- Markdown All in One
- Markdown Linting

## Using Agent OS in VSCode

### Running Workflows

1. Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Type "Tasks: Run Task"
3. Select the Agent OS workflow you want to run
4. Follow the workflow instructions in the terminal

### Workflow Examples

**Starting a New Feature:**
1. Run "Agent OS: Create Spec" task
2. Describe your feature requirements
3. Review generated specification
4. Run "Agent OS: Create Tasks" to break down implementation
5. Run "Agent OS: Execute Tasks" to implement the feature

**Analyzing Existing Project:**
1. Run "Agent OS: Analyze Product" task
2. Provide project context when prompted
3. Review generated product documentation
4. Use other workflows to add new features

## Multi-Root Workspace Support

Agent OS supports VSCode multi-root workspaces:

1. Create a `.code-workspace` file
2. Agent OS will automatically detect the workspace
3. All workflows work across the entire workspace
4. Configuration is shared across all workspace folders

## Troubleshooting

### VSCode Not Auto-Detected
- Ensure you have a `.vscode` directory or `.code-workspace` file
- Run setup with explicit `--vscode` flag
- Check that setup script completed successfully

### Tasks Not Appearing
- Reload VSCode window (`Ctrl+Shift+P` → "Developer: Reload Window")
- Check that `.vscode/tasks.json` was created
- Verify tasks.json contains Agent OS task definitions

### GitHub Copilot Integration
- Install GitHub Copilot extension
- Sign in to GitHub account
- Agent OS workflows provide context that improves Copilot suggestions

## Compatibility

VSCode integration works alongside:
- Existing Cursor installations
- Claude Code setups
- Standard VSCode configurations

All Agent OS files and workflows remain identical across tools - only the interface adapts to each environment.
