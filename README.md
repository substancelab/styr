# styr

Remote control your application without having to remember where it is hosted.

styr is a command line tool that remembers IP addresses, usernames, Heroku dyno names, and all those other details you need to access whatever hosting provider your application is running on.

## Sample usage

Run an uptime check on your Heroku production application:

    styr --target=production run uptime

Open a rails console on your background jobs processing server to investigate failing jobs:

    styr --target=worker run bundle exec rails console

## Getting started

### Requirements

* Ruby

### 1. Install styr

Clone the repository to somewhere on your machine.

```bash
$ git clone https://github.com/substancelab/styr.git
```

You can now run styr from that location by providing the full path to it

```bash
$ /path/to/install/bin/styr
```

or add that installation directory to your `PATH` or symlink the binary into a
directory already in your `PATH`.

### 2. Add a config file to your application

Styr looks for a config file at `.config/styr.toml` relative to your current working directory. So if you're running `styr` at `~/projects/foo` the config file should be at `~/projects/foo/.config/styr.toml`.

### 3. Add your application targets

Tell styr where your application servers are hosted. This for example adds a target called backend, which is hosted on a SSH-capable server somewhere, and a target called frontend, which is hosted on Heroku:

```toml
[targets.backend]
backend = "ssh"
host = "111.222.333.444"
path = "/home/deploy/application/root"
user = "deploy"

[targets.frontend]
backend = "heroku"
app = "simply-dingo"
```

## Supported backends

Each target has a specified backend. styr currently support SSH and Heroku backends.

### Heroku (`backend = "heroku"`)

The Heroku backend basically just wraps `npx heroku`, so you need npm installed for it to work.

#### Configuration

- `app`: Name of the application on Heroku.

## SSH (`backend = "ssh"`)

The SSH backend uses ssh behind the scenes, thus relies on your existing ssh config options and keys. If you can manually ssh into your server, you should be able to use styr for it.

### Configuration

- `host`: The host to connect to, usually an IP address or a hostname.
- `path`: The path to your application on the target server. Styr `cd`s to this directory before running your task.
- `user`: SSH username to use for the connection.

## Anatomy of a styr session

    script/styr --target=production run rails console
    |_________| |_________________| |_| |___________|
    |              |                |   |
    `- Path to styr binary          |   |
                   |                |   |
                   `- The target to run a task against
                                    |   |
                                    `- The task to run
                                        |
                                        `- Arguments to the task
