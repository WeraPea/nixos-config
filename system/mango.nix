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
        # command = "mango";
        command = "mango -d 2>&1 | tee ~/logmango";
        user = config.user.username;
      };
      default_session = initial_session;
    };
  };
}
