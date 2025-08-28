# Technical Stack

## Core Technologies

- **Primary Language**: Bash scripting
- **Documentation Format**: Markdown
- **Configuration**: YAML
- **Version Control**: Git
- **Distribution**: GitHub repository

## Development Tools

- **Shell Environment**: Cross-platform bash (Linux, macOS, Windows WSL/PowerShell)
- **Text Processing**: grep, curl, sed, awk
- **File Operations**: Standard Unix utilities
- **Package Manager**: Git-based distribution

## Integration Platforms

- **Claude Code**: Direct integration via .claude/ directory
- **Cursor**: Integration via .cursor/rules/ directory  
- **GitHub Copilot**: Planned integration (similar to Cursor pattern)
- **Generic AI Tools**: Framework-agnostic instruction system

## Project Structure

- **Instructions**: Core workflow processes (.agent-os/instructions/)
- **Standards**: Development guidelines (.agent-os/standards/)
- **Commands**: High-level user commands (commands/)
- **Agents**: Specialized sub-agents (claude-code/agents/)
- **Setup**: Installation and configuration scripts (setup/)

## Installation & Distribution

- **Base Installation**: System-wide Agent OS installation
- **Project Installation**: Per-project .agent-os/ directory setup
- **Configuration Management**: YAML-based config with project type support
- **Update Mechanism**: Git-based updates from main repository

## File System Organization

```
.agent-os/
├── product/           # Product documentation
├── instructions/      # Workflow processes
├── standards/         # Development guidelines
└── config.yml         # Configuration

.claude/               # Claude Code integration
├── commands/          # Command files
└── agents/           # Specialized agents

.cursor/              # Cursor integration
└── rules/            # Cursor rule files

.copilot/             # GitHub Copilot integration (planned)
└── instructions/     # Copilot instruction files
```

## Deployment & Hosting

- **Repository Hosting**: GitHub
- **Distribution Method**: Direct repository cloning and script execution
- **Installation Sources**: GitHub raw content API
- **Configuration Storage**: Local file system (.agent-os/ directories)

## Architecture Principles

- **Modular Design**: Separate concerns across instructions, standards, and commands
- **Template-Driven**: Consistent file generation using templates
- **Tool-Agnostic Core**: Framework works with any AI coding assistant
- **Standards-First**: Capture and enforce project-specific conventions
