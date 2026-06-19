{
  lib,
  openssh,
  writeShellScriptBin,
}:
{
  hostname,
  targetHostname,
  targetSsh ? targetHostname,
  package, # the derivation that we have to assume the target machine has in store
}:
writeShellScriptBin "${package.name}-remote-wrapped" (
  if hostname == targetHostname then # sh
    ''
      exec "${lib.getExe package}" "$@"
    '' # sh
  else
    ''
      exe="${builtins.unsafeDiscardStringContext (lib.getExe package)}"
      remote_cmd=$(printf '%q ' "$exe" "$@")
      ${lib.getExe openssh} ${targetSsh} "sh -c $(printf '%q ' "$remote_cmd")"
    ''
)
