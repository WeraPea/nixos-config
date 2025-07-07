{ username }:
{
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = "/etc/sops/secrets.yaml";
    validateSopsFiles = false;
  };
}
