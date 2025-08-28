# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-28-github-copilot-integration/spec.md

## Technical Requirements

### Installation Script Modifications

- **Base Installation Script (`setup/base.sh`)**: Add `--copilot` flag parsing and configuration updates to enable Copilot support in config.yml
- **Project Installation Script (`setup/project.sh`)**: Add `--copilot` flag support with directory creation and file conversion logic
- **Shared Functions (`setup/functions.sh`)**: Create `convert_to_copilot_instruction()` function following the pattern of `convert_to_cursor_rule()`

### File Structure and Directory Creation

- **Primary Instructions File**: Create `.github/copilot-instructions.md` containing consolidated Agent OS workflow instructions
- **Specific Instructions Directory**: Create `.github/instructions/` folder with individual `.instructions.md` files for each command
- **Frontmatter Format**: Use YAML frontmatter with `applyTo` patterns (e.g., `applyTo: "**"` for global, specific patterns for targeted instructions)

### Command Template Conversion Logic

- **Source Files**: Convert existing command files from `commands/` directory (plan-product.md, create-spec.md, create-tasks.md, execute-tasks.md, analyze-product.md)
- **Target Format**: GitHub Copilot instruction format with proper markdown structure and frontmatter
- **Consolidation Strategy**: Main workflows in `.github/copilot-instructions.md`, specific task instructions in separate `.instructions.md` files
- **Content Processing**: Strip Agent OS-specific XML tags and formatting, convert to natural language instructions

### Configuration Integration

- **Config File Updates**: Add `copilot:` section to `config.yml` with `enabled: false/true` flag matching Claude Code and Cursor patterns
- **Auto-Enable Logic**: When `--copilot` flag is used, automatically set `enabled: true` in configuration
- **Base Installation**: Support enabling Copilot in base config that propagates to project installations

### File Naming and Organization

- **Instruction Files**: Use descriptive names like `plan-product.instructions.md`, `create-spec.instructions.md`
- **ApplyTo Patterns**: Configure appropriate glob patterns for automatic application (e.g., `**` for general workflows, `**/*.md` for documentation tasks)
- **Directory Structure**: Follow VS Code Copilot documentation standards for `.github/instructions/` folder organization

### Error Handling and Validation

- **File Existence Checks**: Verify source command files exist before conversion
- **Directory Permissions**: Handle cases where `.github/` directory creation fails
- **Overwrite Protection**: Skip existing files unless explicit overwrite flag provided
- **Validation Messages**: Provide clear success/warning messages following existing script patterns

### Integration with Existing Patterns

- **Function Reuse**: Leverage existing `copy_file()` and `download_file()` functions from `setup/functions.sh`
- **Message Formatting**: Use consistent emoji and formatting patterns (📥, ✓, ⚠️) matching existing installation output
- **Flag Processing**: Follow same argument parsing patterns as `--claude-code` and `--cursor` flags

## External Dependencies

No new external dependencies required. The implementation will use:

- **Existing Bash Utilities**: grep, sed, curl for text processing and file operations
- **Standard File Operations**: mkdir, cp, rm for directory and file management
- **YAML Processing**: Existing sed-based config.yml modification patterns
