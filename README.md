# sts installer

Installs [`sts`](https://github.com/Blitzscale-19/syncToStage), the one-command stage deploy CLI.

```sh
curl -fsSL https://raw.githubusercontent.com/pankajyadav-blitz/sts-install/main/install.sh | sh
```

The script itself is public, but it downloads `sts` from the private `Blitzscale-19/syncToStage`
repo with `git clone` over SSH, so it only works for people with access to that repo.
Update later with `sts -U`, remove with `sts --uninstall`.
