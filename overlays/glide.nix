final: prev: {
  glide-browser = final.lib.makeOverridable (
    {
      extraPolicies ? { },
      extraPoliciesFiles ? [ ],
      ...
    }:
    prev.glide-browser.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.jq ];

      postInstall = (oldAttrs.postInstall or "") + ''
        libDir="$out/lib/glide-browser-bin-${oldAttrs.version}"
        mkdir -p "$libDir/distribution"
        POL_PATH="$libDir/distribution/policies.json"

        cat > "$POL_PATH" << 'EOF'
        {
          "policies": {
            "DisableAppUpdate": true
          }
        }
        EOF

        ${final.lib.optionalString (extraPolicies != { }) ''
          cat > .extra-policies.json << 'EXTRAPOL'
          ${builtins.toJSON { policies = extraPolicies; }}
          EXTRAPOL

          jq -s '.[0].policies * .[1].policies | {policies: .}' "$POL_PATH" .extra-policies.json > .tmp.json
          mv .tmp.json "$POL_PATH"
          rm .extra-policies.json
        ''}

        ${final.lib.concatMapStringsSep "\n" (file: ''
          jq -s '.[0] * .[1]' "$POL_PATH" "${file}" > .tmp.json
          mv .tmp.json "$POL_PATH"
        '') extraPoliciesFiles}
      '';
    })
  ) { };
}
