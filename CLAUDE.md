# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Styr is a command-line tool for remote controlling applications without having to remember IP addresses or SSH commands. It provides a unified interface to execute commands on different deployment targets through pluggable backends.

## Running the CLI

The main executable is `./styr` which uses bundler/inline for dependency management:

```bash
./styr targets                    # List all configured targets
./styr run --target TARGET "cmd"  # Execute command on a target
./styr --help                     # Show help information
```

## Configuration

Styr reads configuration from `.config/styr.toml` in the current working directory (lib/styr/config.rb:12). The config file defines targets with their backend types and connection details.

Example configuration structure:
```toml
[targets.production]
backend = "heroku"
app = "myapp"

[targets.staging]
backend = "ssh"
user = "deploy"
host = "staging.example.com"
path = "/opt/app"
```

## Architecture

### Core Components

1. **Main entry point** (`styr` executable)
   - Uses bundler/inline to load dependencies (toml-rb, tty-command, tty-table)
   - Creates singleton Styr instance and processes commands

2. **Styr class** (lib/styr.rb)
   - Singleton pattern
   - Loads targets from config and instantiates them with appropriate backends
   - Delegates command processing to CLI

3. **CLI** (lib/styr/cli.rb)
   - Two main tasks: `RunTask` and `TargetsTask`
   - Uses OptionParser for argument parsing
   - Task system is extensible - new tasks can be added to the `tasks` array

4. **Backend system** (lib/styr/backend.rb)
   - Factory pattern: `Backend.from_config` creates appropriate backend instances
   - Currently supports two backends:
     - **HerokuBackend**: Uses `exec` to replace Ruby process with `heroku run` for full interactive session support
     - **SSHBackend**: Uses `exec` to replace Ruby process with `ssh -t` for full interactive session support (stdin/stdout/stderr forwarding, works with shells and interactive commands)

5. **Target system** (lib/styr/target.rb)
   - Base `Target` class represents a deployment target
   - Each backend defines its own `Target` subclass that implements `display` method
   - Targets store name, config, and create their backend lazily

### Key Design Patterns

- **Singleton**: Main Styr instance
- **Factory**: Backend creation from config
- **Strategy**: Different backends implement different execution strategies
- **Template Method**: Backend-specific Target classes override `display` method

### Backend Architecture

Each backend is defined in `lib/styr/backend/` and must:
1. Inherit from or be within the `Styr::Backend` namespace
2. Implement `initialize(config)` to accept configuration
3. Implement `execute(command)` to run commands on the target
4. Implement `to_s` for display name
5. Define a nested `Target` class that inherits from `Styr::Target` and implements `display`

The `display` method returns human-readable details specific to each backend type (e.g., Heroku app name, SSH connection string).

### Adding New Backends

To add a new backend:
1. Create `lib/styr/backend/your_backend.rb`
2. Define `YourBackend` class with `initialize`, `execute`, and `to_s` methods
3. Define nested `YourBackend::Target` class with `display` method
4. Add case to `Backend.from_config` factory method in lib/styr/backend.rb
5. Require the backend file in lib/styr/config.rb

### Code Organization

- `lib/styr.rb` - Main singleton class
- `lib/styr/cli.rb` - Command-line interface and tasks
- `lib/styr/config.rb` - Configuration loading from TOML
- `lib/styr/target.rb` - Base target class
- `lib/styr/backend.rb` - Backend factory
- `lib/styr/backend/` - Backend implementations

## Development

- Create tests using minitest. When fixing a bug start by reproducing the bug in a test case.
- Use standard to lint code syntax: `bundle exec rake standard`
