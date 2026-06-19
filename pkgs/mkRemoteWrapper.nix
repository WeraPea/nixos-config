{
  lib,
  openssh,
  writeShellScriptBin,
}:
{
  hostname,
  targetHostname,
  targetSsh ? targetHostname,
  package ? null, # the derivation that we have to assume the target machine has in store
  name ?
    if (package != null) then
      package.meta.mainProgram or (lib.getName package)
    else
      lib.tail (lib.splitString "/" exe),
  exe ? lib.getExe' package name,
}:
writeShellScriptBin "${name}-remote-wrapped" (
  if hostname == targetHostname then # sh
    ''
      exec "${exe}" "$@"
    '' # sh
  else
    ''
      exe="${builtins.unsafeDiscardStringContext exe}"
      remote_cmd=$(printf '%q ' "$exe" "$@")
      ${lib.getExe openssh} ${targetSsh} "sh -c $(printf '%q ' "$remote_cmd")"
    ''
)
