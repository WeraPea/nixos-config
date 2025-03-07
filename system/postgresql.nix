{
  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };
    # optional backup for postgresql db
    postgresqlBackup = {
      enable = true;
      location = "/data/backup/nextclouddb";
      databases = [ "nextcloud" ];
      # time to start backup in systemd.time format
      startAt = "*-*-* 23:15:00";
    };
  };

  # ensure postgresql db is started with nextcloud
  systemd = {
    services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
