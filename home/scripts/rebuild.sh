# A rebuild script that commits on a successful build
set -e

pushd ~/nixos/
nix fmt . &>/dev/null
git diff -U0 **.nix --staged
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake $(pwd)#nixos &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
current=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
git commit -am "generation $current"
popd
# notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
