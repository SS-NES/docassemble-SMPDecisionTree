## Versioning

To progress version numbers e.g. upon a new release, we use `bump-my-version`.

### Installation
This Python tool can be installed via either `pip` or `pipx`:

```bash
# Create desired environment first
pip install bump-my-version

# Have pipx installed in a global/tooling environment
pipx install bump-my-version
```

### Tracking which files to update
`bump-my-version` will only search in files indicated in the `.bumpversion.toml` file.
If the version number needs to be tracked and updated in a new file, you have to add
the following entry in the configuration file:

```toml
[[tool.bumpversion.files]]
filename = "path/to/file.txt"
```

Doing a dry run (see next section) is recommended to confirm your addition has been
successful.

### Bumping version
Using the `show-bump` command, you can see which common bump options are available:

```bash
$ bump-my-version show-bump
0.0.4 ── bump ─┬─ major ─ 1.0.0
               ├─ minor ─ 0.1.0
               ╰─ patch ─ 0.0.5
```

To see which entries in which files would be updated, you can do a dry run:
```bash
$ bump-my-version --dry-run --verbose patch
```

If you are satisfied with the result, you can omit the `--dry-run` and `--verbose` options.
You will still have to stage and commit the resulting changes to the repository.
