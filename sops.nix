{ username }:
{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
}
