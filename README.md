# styr
Remote control your application without having to remember IP addresses or SSH commands


## Getting started

### 1. Install styr into your application

Personally, I prefer to have it checked out somewhere and link it there:

```bash
$ ln -s ~/path/to/styr bin/styr
```

### 2. Add a config file

Styr looks for a config file at `.config/styr.toml` relative to your current working directory. So if you're at `~/projects/foo`, running `bin/styr`, the config file should be at `~/projects/foo/.config/styr.toml`.

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

## Anatomy of a styr session

    script/styr --target=production run rails console
    |_________| |_________________| |_| |___________|
    |              |                |   |
    `- styr binary |                |   |
                   `- The target to run a task against
                                    |   |
                                    `- The task to run
                                        |
                                        `- Arguments to the task
