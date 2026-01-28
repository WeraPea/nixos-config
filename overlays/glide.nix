final: prev: {
  glide-browser = final.lib.makeOverridable (
    {
      extraPrefs ? "",
      extraPrefsFiles ? [ ],

      extraPolicies ? { },
      extraPoliciesFiles ? [ ],
      ...
    }:
    let
      policiesJson = final.writeText "policies.json" (
        builtins.toJSON {
          policies = {
            DisableAppUpdate = true;
          }
          // extraPolicies;
        }
      );

      mozillaCfg = ''
        // mozilla.cfg
      '';
    in
    prev.glide-browser.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.jq ];

      postInstall = (oldAttrs.postInstall or "") + ''
        libDir="$out/lib/glide-browser-bin-${oldAttrs.version}"
        mkdir -p "$libDir/distribution"

        POL_PATH="$libDir/distribution/policies.json"
        rm -f "$POL_PATH"
        cat ${policiesJson} > "$POL_PATH"

        extraPoliciesFiles=(${toString extraPoliciesFiles})
        for extraPoliciesFile in "''${extraPoliciesFiles[@]}"; do
          jq -s '.[0] * .[1]' $extraPoliciesFile "$POL_PATH" > .tmp.json
          mv .tmp.json "$POL_PATH"
        done

        # preparing for autoconfig
        prefsDir="$libDir/defaults/pref"
        mkdir -p "$prefsDir"

        echo 'pref("general.config.filename", "mozilla.cfg");' > "$prefsDir/autoconfig.js"
        echo 'pref("general.config.obscure_value", 0);' >> "$prefsDir/autoconfig.js"

        cat >> "$libDir/mozilla.cfg" << EOF
        ${extraPrefs}
        EOF

        cat > "$libDir/mozilla.cfg" << EOF
        ${mozillaCfg}
        EOF

        extraPrefsFiles=(${toString extraPrefsFiles})
        for extraPrefsFile in "''${extraPrefsFiles[@]}"; do
          cat "$extraPrefsFile" >> "$libDir/mozilla.cfg"
        done

        cat >> "$libDir/mozilla.cfg" << EOF
        ${extraPrefs}
        EOF
      '';
    })
  ) { };
}
