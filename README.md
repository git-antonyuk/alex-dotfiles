# Developer dotfiles for macOS

A small, reusable setup for Python, JavaScript/TypeScript, Rust, and Go.
Based on [Jeff Geerling's Mac Development Ansible Playbook](https://github.com/geerlingguy/mac-dev-playbook).
This version uses a Homebrew Brewfile and shell installer in place of Ansible.
The original MIT license is preserved in `LICENSE`.

## What it installs

| Area | Tools |
| --- | --- |
| Source control | Git, GitHub CLI (installed only; no login or repository commands) |
| Python | Python 3 and pip3 |
| JavaScript/TypeScript | Node.js, npm, pnpm, and global TypeScript (`tsc`) |
| Rust | rustup, stable Rust, Cargo, rustfmt, and Clippy |
| Go | Go toolchain |
| Editors | Zed and Visual Studio Code |
| Productivity | Raycast |
| Terminal | Starship, zsh-autosuggestions, zsh-syntax-highlighting |

macOS supplies Zsh. The installer does not change your login shell.
CMake is not included; add `brew "cmake"` to `Brewfile` if needed.

## Preview and install locally

From the cloned repository:

```sh
cd ~/projects/dotfiles
bash install.sh --plan
```

The preview prints the plan without installing anything or touching dotfiles.
After reviewing it, apply the setup:

```sh
bash install.sh
```

The installer supports Apple Silicon and Intel Macs. It starts Apple's Command
Line Tools installer when necessary; finish that installer and rerun the script.
It installs Homebrew if missing (Homebrew may request your password), then the
listed packages and apps that are missing. It skips VS Code, Zed, and Raycast when their
app folders exist in `/Applications` or `~/Applications`, including manual installs.
It does not adopt those apps into Homebrew or change their permissions.

Available Git, GitHub CLI, Python (with pip3), Node.js (with npm), pnpm, Go, and Starship
commands are kept. Homebrew-managed packages are not explicitly upgraded or removed;
installing missing dependencies can still require changes. Homebrew output is verbose
so download and installation progress is visible. The skip lists use Homebrew's
[documented Bundle environment variables](https://docs.brew.sh/Manpage#bundle-subcommand).

If `tsc` is already on PATH, TypeScript is skipped; otherwise it is installed under
`~/.local/npm` without sudo. A working Rust compiler and Cargo are kept as-is,
including their existing default toolchain and components. When Rust is missing,
the installer sets up stable Rust with rustfmt and Clippy. Executables under
`~/.local/npm/bin`, `~/.cargo/bin`, and `~/go/bin` are included during detection.
Tools provided by a version manager must be on the calling terminal's PATH to be detected.

Only after package installation succeeds, the script links `~/.zshrc` to this
repository. Existing files or symlinks are moved into a unique
`~/.dotfiles-backup.*` directory. Repeated runs preserve the existing link.
Keep the repository in place after installation. Open a new Zsh terminal to
activate the configuration. If your default shell differs, launch `zsh` manually.

The script can be rerun after a partial failure. Package versions are not pinned;
Existing TypeScript and working Rust installations are skipped on reruns. It does not configure macOS preferences,
Git identity, editor settings, SSH keys, or GitHub authentication.

## Zsh settings

- A plain text Starship prompt shows folder, Git state, and relevant language context.
- Command suggestions appear as you type; right arrow accepts them.
- Syntax highlighting and Tab completion are enabled.
- History is shared across sessions, with consecutive duplicates suppressed.
- Up/down arrows search history using the beginning of the command you've typed.
- `ll` lists details, `..` moves up a folder, and `mkcd NAME` creates and enters one.
- User npm, Cargo, and Go executable directories are added to PATH.

Edit `dotfiles/.zshrc` and `dotfiles/starship.toml` to customize the shared setup.
Put machine-specific settings in `~/.zshrc.local`, outside the repository.
Existing `.zprofile` and `.zshenv` are left intact and can affect shell behavior.

## Check after installation

In a new Zsh terminal:

```sh
python3 --version
python3 -m pip --version
pip3 --version
node --version
npm --version
pnpm --version
tsc --version
rustc --version
cargo --version
rustup show
go version
starship --version
```

For each Python project, use an isolated environment:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install <package>
```

Projects can also install their own TypeScript version with
`npm install --save-dev typescript` and use `npx tsc`.

## Restore the previous shell configuration

Remove only the `~/.zshrc` symlink created by this installer, then move the
`.zshrc` from the backup directory printed during installation back into place.
This restores the shell file; installed packages remain installed.

## Public repository hygiene

No usernames, email addresses, machine paths, tokens, or private keys are included
in the setup files. All personal paths are derived from `$HOME`. `.gitignore`
excludes common secret files and local dependencies; review changes before committing.
The original project's author attribution remains in the license and link above.

## Installer regression checks

```sh
bash -n install.sh
bash tests/packages.sh
```

The regression checks mock command availability, app detection, npm, and rustup.
They do not inspect or install software on your Mac.
