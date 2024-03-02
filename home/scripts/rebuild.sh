# A rebuild script that commits on a successful build
set -e

pushd ~/nixos/
nix fmt . &>/dev/null
git diff -U0 --staged **.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake $(pwd)#nixos
current=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
git commit -am "generation $current"
popd
