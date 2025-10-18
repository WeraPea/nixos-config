{
  config,
  ...
}:
{
  programs.mango.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "mango";
        user = config.user.username;
      };
      default_session = initial_session;
    };
  };
}
