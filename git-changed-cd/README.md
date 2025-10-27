# 🎯 git-changed-cd (gcd)
Navigate to directories with Git changes, fast.

`git-changed-cd` (aliased as `gcd`) is a Bash function that scans your Git repositories for changes. It finds staged, unstaged, and untracked files, then presents an interactive menu of just the directories that contain those changes, letting you `cd` to them instantly.

It supports scanning your current repository or managing a list of registered "favorite" repositories to scan all at once.

## ✨ Features
-   **Interactive Navigation**: Presents a simple numbered menu of changed directories.
-   **Multi-Repository Support**: Register multiple repositories (`gcd-add`) and scan them all (`gcdj`, `gcda`).
-   **Smart Ordering**: In multi-repo mode, repositories are sorted by proximity to your current directory.
-   **Full Change Detection**: Finds staged, unstaged, and untracked files.
-   **Clean UI**: Shows repository names `[repo-name]` in multi-repo mode for clarity.
-   **Lightweight**: A simple set of Bash functions with no heavy dependencies.

## 🚀 Installation

1.  Place the `git-changed-cd-loader` file and the `src` directory in a permanent location (e.g., `~/.config/git-changed-cd/`).
2.  Add the following line to your `~/.bashrc` to load the functions into your shell:

    ```bash
    # Adjust the path to where you placed the loader
    source ~/.config/git-changed-cd/git-changed-cd-loader
    ```

3.  Restart your shell or run `source ~/.bashrc` to activate the commands.

---

## 🏁 Quick Start

### 1. Navigate in your Current Repository
This is the default behavior.

```bash
# You are in /path/to/my-project
# You've made changes in src/utils/ and tests/
$ gcd
Directories with changes:
1: <repo root>
2: src/utils
3: tests
Enter the number of the directory to cd into (or 0 to cancel): 2

Changing directory to: /path/to/my-project/src/utils
````

### 2\. Navigate Across Multiple Repositories

First, register your "favorite" repositories.

```bash
# Register a project you work on often
$ gcd-add /path/to/other-project
Added repository: /path/to/other-project

# Register another one
$ gcd-add /path/to/docs-repo
Added repository: /path/to/docs-repo
```

Now, from *anywhere*, you can scan *only* your registered repositories.

```bash
# You are in /home/user (not in a git repo)
# Both registered repos have changes
$ gcdj
Directories with changes:
1: [other-project] <repo root>
2: [other-project] lib
3: [docs-repo] <repo root>
4: [docs-repo] content/posts
Enter the number of the directory to cd into (or 0 to cancel): 4

Changing directory to: /path/to/docs-repo/content/posts
```

You can also scan your **c**urrent repo + **a**ll registered repos using `gcda`.

-----

## 📚 Command Reference

### Core Navigation

| Command | Alias | Description |
|---|---|---|
| `git-changed-cd` | `gcd` | Scan **current** repository only. |
| `git-changed-cd --justRegisteredDirectories` | `gcdj` | Scan **just registered** repositories. |
| `git-changed-cd --all` | `gcda` | Scan **current + all** registered repositories. |

### Repository Management

| Command | Alias | Description |
|---|---|---|
| `git-changed-cd-add-repo <path>` | `gcd-add` | Add a repository to the in-memory registry. |
| `git-changed-cd-remove-repo <path>` | `gcd-remove` | Remove a repository from the registry. |
| `git-changed-cd-list-repos` | `gcd-list` | List all currently registered repositories. |

-----

## ⚙️ How It Works

### Change Detection

`gcd` runs three `git` commands to find all changes:

1.  **Unstaged**: `git diff --name-only HEAD`
2.  **Staged**: `git diff --name-only --cached`
3.  **Untracked**: `git ls-files --others --exclude-standard`

It then collects the parent directories of all modified files and presents them as a unique, sorted list.

### Multi-Repo Modes & Distance Ordering

When you use `gcdj` (registered only) or `gcda` (all), `gcd` calculates the "distance" to each repository from your current working directory (`$PWD`).

Distance is the number of `cd ..` (up) and `cd <dir>` (down) commands needed to get from one path to the other.

This ensures that the repositories physically "closest" to you in the filesystem (e.g., sibling directories) appear first in the list, followed by more "distant" ones.

## ⚠️ Limitations

  - **No Persistence**: The repository registry is stored in an environment variable (`$GIT_CHANGED_CD_REGISTERED_REPOS`) and is **not** persistent. It will be empty when you start a new shell session.
  - **No Submodules**: Git submodules are not supported.
  - **No Nested Repos**: Nested Git repositories are not supported.
