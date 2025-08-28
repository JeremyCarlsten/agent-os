# Spec Requirements Document

> Spec: GitHub Copilot Integration
> Created: 2025-08-28

## Overview

Implement GitHub Copilot integration for Agent OS following the same successful pattern as Cursor integration, enabling Copilot users to access Agent OS structured workflows and standards. This feature will complete the major AI coding tool integrations and provide consistent Agent OS experience across Claude Code, Cursor, and GitHub Copilot platforms.

## User Stories

### GitHub Copilot User Onboarding

As a GitHub Copilot user, I want to install Agent OS with Copilot support, so that I can access structured workflows and development standards through my preferred AI coding assistant.

When a developer runs the Agent OS installation with the `--copilot` flag, the system should automatically set up the appropriate directory structure (`.github/copilot-instructions.md` and `.github/instructions/` folder), convert command templates to Copilot instruction format, and enable Copilot support in the configuration file.

### Seamless Workflow Access

As a GitHub Copilot user, I want to access Agent OS commands using the same patterns as other tools, so that I can maintain consistent development workflows regardless of my AI assistant choice.

Users should be able to reference Agent OS workflows through Copilot's instruction system, with commands automatically available through the `.github/copilot-instructions.md` file and specific task instructions available in `.github/instructions/` directory with appropriate `applyTo` patterns.

### Team Standardization

As a development team lead, I want to provide Agent OS standards to all team members using GitHub Copilot, so that our AI-assisted development maintains consistent quality and follows our established patterns.

The Copilot integration should automatically include project standards, tech stack preferences, and coding guidelines in the instruction files, ensuring that Copilot responses align with team conventions and Agent OS best practices.

## Spec Scope

1. **Installation Script Integration** - Add `--copilot` flag support to both base.sh and project.sh installation scripts
2. **Copilot Instruction File Generation** - Convert Agent OS commands to `.github/copilot-instructions.md` format and create specific `.instructions.md` files
3. **Configuration Management** - Add Copilot enable/disable support to config.yml with same pattern as Claude Code and Cursor
4. **Directory Structure Setup** - Create appropriate `.github/` directory structure following VS Code Copilot documentation standards
5. **Command Template Conversion** - Convert existing command markdown files to Copilot instruction format with proper frontmatter and applyTo patterns

## Out of Scope

- Custom GitHub Copilot extensions or VS Code extension development
- Integration with GitHub Copilot's web interface or GitHub.com features
- Copilot-specific agent templates (will use existing agent system)
- Changes to core Agent OS instruction templates or standards
- Support for GitHub Copilot Enterprise features beyond basic instruction files

## Expected Deliverable

1. Users can run `./setup/project.sh --copilot` and receive a fully configured Agent OS installation with GitHub Copilot support
2. GitHub Copilot users can access Agent OS workflows through `.github/copilot-instructions.md` and specific `.instructions.md` files with appropriate `applyTo` patterns
3. Installation creates proper directory structure (`.github/instructions/`) and converts all Agent OS commands to Copilot-compatible instruction format
