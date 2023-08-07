{
  lib,
  pkgs,
  config,
  ...
}: let
  cloudflare = config.modules.services.cloudflare;
in {
  users.groups.cloudflared = lib.mkIf (cloudflare.enable) {};
  systemd = with lib; {
    # Systemd OOMd
    # Fedora enables these options by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
    oomd = {
      enableRootSlice = true;
      enableUserServices = true;
      enableSystemSlice = true;
    };

    services = {
      tunnel = mkIf (cloudflare.enable) {
        wantedBy = ["multi-user.target"];
        after = ["network.target" "network-online.target" "systemd-resolved.service"];
        serviceConfig = {
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloudflare.token}";
          Restart = "always";
          User = "${config.modules.system.username}";
          Group = "cloudflared";
        };
      };

      # clean audit log if it's more than 524,288,000 bytes, which is roughly 500 megabytes
      # it can grow MASSIVE in size if left unchecked
      "clean-audit-log" = mkIf (config.security.auditd.enable) {
        script = ''
            set -eu
            if [[ $(stat -c "%s" /var/log/audit/audit.log) -gt 524288000 ]]; then
              echo "Clearing Audit Log";
          rm -rvf /var/log/audit/audit.log;
          echo "Done!"
            fi
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };

    # a systemd timer to clean /var/log/audit.log daily
    # this can probably be weekly, but daily means we get to clean it every 2-3 days instead of once a week
    timers."clean-audit-log" = mkIf (config.security.auditd.enable) {
      description = "Periodically clean audit log";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
