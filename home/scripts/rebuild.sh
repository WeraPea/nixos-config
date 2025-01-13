# shellcheck shell=bash
# A rebuild script that commits on a successful build
set -e

pushd ~/nixos-config/
nix fmt
sudo nixos-rebuild switch --flake .
while [ "$current" = "" ]; do
  current=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
done
if [[ -n $(git status --porcelain) ]]; then
  git commit -am "generation $current - $(hostname)"
else
  tag_name="generation-$current-$(hostname)"
  git tag -a "$tag_name" -m "Tagging generation $current on $(hostname)"
fi
popd
