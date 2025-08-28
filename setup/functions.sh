#!/bin/bash

# Agent OS Shared Functions
# Used by both base.sh and project.sh

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Function to copy files from source to destination
copy_file() {
    local source="$1"
    local dest="$2"
    local overwrite="$3"
    local desc="$4"

    if [ -f "$dest" ] && [ "$overwrite" = false ]; then
        echo "  ⚠️  $desc already exists - skipping"
        return 0
    else
        if [ -f "$source" ]; then
            cp "$source" "$dest"
            if [ -f "$dest" ] && [ "$overwrite" = true ]; then
                echo "  ✓ $desc (overwritten)"
            else
                echo "  ✓ $desc"
            fi
            return 0
        else
            return 1
        fi
    fi
}

# Function to download file from GitHub
download_file() {
    local url="$1"
    local dest="$2"
    local overwrite="$3"
    local desc="$4"

    if [ -f "$dest" ] && [ "$overwrite" = false ]; then
        echo "  ⚠️  $desc already exists - skipping"
        return 0
    else
        curl -s -o "$dest" "$url"
        if [ -f "$dest" ] && [ "$overwrite" = true ]; then
            echo "  ✓ $desc (overwritten)"
        else
            echo "  ✓ $desc"
        fi
        return 0
    fi
}

# Function to copy directory recursively
copy_directory() {
    local source="$1"
    local dest="$2"
    local overwrite="$3"

    if [ ! -d "$source" ]; then
        return 1
    fi

    mkdir -p "$dest"

    # Copy all files and subdirectories
    find "$source" -type f | while read -r file; do
        relative_path="${file#$source/}"
        dest_file="$dest/$relative_path"
        dest_dir=$(dirname "$dest_file")
        mkdir -p "$dest_dir"

        if [ -f "$dest_file" ] && [ "$overwrite" = false ]; then
            echo "  ⚠️  $relative_path already exists - skipping"
        else
            cp "$file" "$dest_file"
            if [ "$overwrite" = true ] && [ -f "$dest_file" ]; then
                echo "  ✓ $relative_path (overwritten)"
            else
                echo "  ✓ $relative_path"
            fi
        fi
    done
}

# Function to convert command file to Cursor .mdc format
convert_to_cursor_rule() {
    local source="$1"
    local dest="$2"

    if [ -f "$dest" ]; then
        echo "  ⚠️  $(basename $dest) already exists - skipping"
    else
        # Create the front-matter and append original content
        cat > "$dest" << EOF
---
alwaysApply: false
---

EOF
        cat "$source" >> "$dest"
        echo "  ✓ $(basename $dest)"
    fi
}

# Function to convert command file to GitHub Copilot .instructions.md format
convert_to_copilot_instruction() {
    local source="$1"
    local dest="$2"

    if [ -f "$dest" ]; then
        echo "  ⚠️  $(basename $dest) already exists - skipping"
    else
        # Determine applyTo pattern based on command type
        local filename=$(basename "$source" .md)
        local apply_pattern="**"
        
        case "$filename" in
            "plan-product"|"analyze-product")
                apply_pattern="**"  # Global application for product planning
                ;;
            "create-spec")
                apply_pattern="**/*.md"  # Apply to markdown files for documentation
                ;;
            "create-tasks"|"execute-tasks")
                apply_pattern="**"  # Global application for task management
                ;;
            *)
                apply_pattern="**"  # Default to global
                ;;
        esac

        # Create the front-matter with appropriate applyTo pattern
        cat > "$dest" << EOF
---
applyTo: "$apply_pattern"
---

EOF
        # Process the source content to remove Agent OS-specific XML tags and convert to natural language
        sed -e 's/<[^>]*>//g' \
            -e '/^---$/,/^---$/d' \
            -e '/^description:/d' \
            -e '/^globs:/d' \
            -e '/^alwaysApply:/d' \
            -e '/^version:/d' \
            -e '/^encoding:/d' \
            "$source" >> "$dest"
        echo "  ✓ $(basename $dest)"
    fi
}

# Function to generate consolidated copilot-instructions.md file
generate_copilot_instructions() {
    local target_dir="$1"
    local commands_dir="$2"
    local dest="$target_dir/.github/copilot-instructions.md"

    if [ -f "$dest" ]; then
        echo "  ⚠️  copilot-instructions.md already exists - skipping"
        return 0
    fi

    # Create consolidated instructions file
    cat > "$dest" << 'EOF'
# Agent OS - GitHub Copilot Instructions

This file contains structured workflows and development standards for Agent OS projects. These instructions help GitHub Copilot understand your project context and provide consistent, high-quality code generation.

## Core Workflows

### Product Planning
Use structured product planning to define mission, roadmap, and technical specifications before development begins.

### Spec-Driven Development
Create detailed specifications for features before implementation, including user stories, technical requirements, and task breakdowns.

### Task Execution
Follow test-driven development (TDD) approach with systematic task execution and verification.

### Standards Enforcement
Apply consistent coding standards, best practices, and architectural patterns across all generated code.

## Development Principles

- **Keep It Simple**: Implement code in the fewest lines possible, avoid over-engineering
- **Optimize for Readability**: Prioritize code clarity over micro-optimizations
- **DRY (Don't Repeat Yourself)**: Extract repeated logic to reusable components
- **Test-First Development**: Write tests before implementation
- **Standards Compliance**: Follow project-specific coding standards and conventions

## File Organization

- Use consistent naming conventions across the project
- Group related functionality together
- Maintain single responsibility principle for files and functions
- Follow established project structure patterns

## Code Quality

- Write self-documenting code with clear variable names
- Add comments for "why" not "what"
- Ensure all functions have clear inputs and outputs
- Maintain consistent indentation and formatting
- Handle errors gracefully with appropriate error messages

EOF

    echo "  ✓ copilot-instructions.md"
}

# Function to generate individual instructions files
generate_individual_instructions() {
    local target_dir="$1"
    local commands_dir="$2"

    # Create instructions directory
    mkdir -p "$target_dir/.github/instructions"

    # Convert each command file to individual instruction file
    for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
        if [ -f "$commands_dir/${cmd}.md" ]; then
            convert_to_copilot_instruction "$commands_dir/${cmd}.md" "$target_dir/.github/instructions/${cmd}.instructions.md"
        else
            echo "  ⚠️  Warning: ${cmd}.md not found in $commands_dir"
        fi
    done
}

# Function to install from GitHub
install_from_github() {
    local target_dir="$1"
    local overwrite_inst="$2"
    local overwrite_std="$3"
    local include_commands="${4:-true}"  # Default to true for base installations

    # Create directories
    mkdir -p "$target_dir/standards"
    mkdir -p "$target_dir/standards/code-style"
    mkdir -p "$target_dir/instructions"
    mkdir -p "$target_dir/instructions/core"
    mkdir -p "$target_dir/instructions/meta"

    # Download instructions
    echo ""
    echo "📥 Downloading instruction files to $target_dir/instructions/"

    # Core instructions
    echo "  📂 Core instructions:"
    for file in plan-product post-execution-tasks create-spec create-tasks execute-tasks execute-task analyze-product; do
        download_file "${BASE_URL}/instructions/core/${file}.md" \
            "$target_dir/instructions/core/${file}.md" \
            "$overwrite_inst" \
            "instructions/core/${file}.md"
    done

    # Meta instructions
    echo ""
    echo "  📂 Meta instructions:"
    for file in pre-flight post-flight; do
        download_file "${BASE_URL}/instructions/meta/${file}.md" \
            "$target_dir/instructions/meta/${file}.md" \
            "$overwrite_inst" \
            "instructions/meta/${file}.md"
    done

    # Download standards
    echo ""
    echo "📥 Downloading standards files to $target_dir/standards/"

    download_file "${BASE_URL}/standards/tech-stack.md" \
        "$target_dir/standards/tech-stack.md" \
        "$overwrite_std" \
        "standards/tech-stack.md"

    download_file "${BASE_URL}/standards/code-style.md" \
        "$target_dir/standards/code-style.md" \
        "$overwrite_std" \
        "standards/code-style.md"

    download_file "${BASE_URL}/standards/best-practices.md" \
        "$target_dir/standards/best-practices.md" \
        "$overwrite_std" \
        "standards/best-practices.md"

    # Download code-style subdirectory
    echo ""
    echo "📥 Downloading code style files to $target_dir/standards/code-style/"

    for file in css-style html-style javascript-style; do
        download_file "${BASE_URL}/standards/code-style/${file}.md" \
            "$target_dir/standards/code-style/${file}.md" \
            "$overwrite_std" \
            "standards/code-style/${file}.md"
    done

    # Download commands (only if requested)
    if [ "$include_commands" = true ]; then
        echo ""
        echo "📥 Downloading command files to $target_dir/commands/"
        mkdir -p "$target_dir/commands"

        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            download_file "${BASE_URL}/commands/${cmd}.md" \
                "$target_dir/commands/${cmd}.md" \
                "$overwrite_std" \
                "commands/${cmd}.md"
        done
    fi
}
