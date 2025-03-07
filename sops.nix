{ config, ... }:
{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${config.user.username}/.config/sops/age/keys.txt";
}
