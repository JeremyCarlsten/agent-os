# Spec Tasks

## Tasks

- [x] 1. **Setup Installation Script Infrastructure**
  - [x] 1.1 Write tests for Copilot flag parsing in base.sh and project.sh
  - [x] 1.2 Add `--copilot` flag parsing to setup/base.sh argument processing
  - [x] 1.3 Add `--copilot` flag parsing to setup/project.sh argument processing
  - [x] 1.4 Add Copilot configuration updates to config.yml in base.sh
  - [x] 1.5 Update help text in both scripts to document `--copilot` flag
  - [x] 1.6 Verify all installation script tests pass

- [x] 2. **Create Copilot File Conversion Functions**
  - [x] 2.1 Write tests for `convert_to_copilot_instruction()` function
  - [x] 2.2 Implement `convert_to_copilot_instruction()` function in setup/functions.sh
  - [x] 2.3 Create logic to generate `.github/copilot-instructions.md` from command files
  - [x] 2.4 Create logic to generate individual `.instructions.md` files with frontmatter
  - [x] 2.5 Add proper `applyTo` pattern configuration for different instruction types
  - [x] 2.6 Verify all conversion function tests pass

- [x] 3. **Implement Copilot Integration in Project Installation**
  - [x] 3.1 Write tests for Copilot directory creation and file generation
  - [x] 3.2 Add `.github/` directory creation logic to project.sh
  - [x] 3.3 Add `.github/instructions/` subdirectory creation
  - [x] 3.4 Implement command file conversion and placement for Copilot format
  - [x] 3.5 Add consolidated `.github/copilot-instructions.md` generation
  - [x] 3.6 Add individual `.instructions.md` files with appropriate frontmatter
  - [x] 3.7 Verify all Copilot integration tests pass

- [x] 4. **Configuration Management and Auto-Enable Logic**
  - [x] 4.1 Write tests for Copilot configuration management
  - [x] 4.2 Add Copilot section to default config.yml template
  - [x] 4.3 Implement auto-enable logic when `--copilot` flag is used
  - [x] 4.4 Add Copilot config propagation from base to project installations
  - [x] 4.5 Update installation success messages to include Copilot file locations
  - [x] 4.6 Verify all configuration management tests pass

- [x] 5. **Integration Testing and Documentation Updates**
  - [x] 5.1 Write end-to-end tests for complete Copilot installation workflow
  - [x] 5.2 Test base installation with `--copilot` flag
  - [x] 5.3 Test project installation with `--copilot` flag and verify file structure
  - [x] 5.4 Test auto-enable functionality and config.yml updates
  - [x] 5.5 Update setup script help documentation and README
  - [x] 5.6 Add Copilot usage examples to installation success messages
  - [x] 5.7 Verify all integration tests pass and installation works end-to-end
