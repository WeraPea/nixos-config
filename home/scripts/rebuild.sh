# A rebuild script that commits on a successful build
set -e

pushd ~/nixos/
nix fmt . &>/dev/null
sudo nixos-rebuild switch --flake $(pwd)#nixos
while [ -z "$current" ]; do
    current=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
done
git commit -am "generation $current"
popd
