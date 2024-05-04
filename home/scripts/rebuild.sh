# A rebuild script that commits on a successful build
set -e

pushd ~/nixos-config/
nix fmt
sudo nixos-rebuild switch --flake .
while [ -z "$current" ]; do
    current=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
done
git commit -am "generation $current"
popd
