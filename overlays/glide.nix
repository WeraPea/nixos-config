final: prev: {
  glide-browser = final.lib.makeOverridable (
    {
      extraPrefs ? "",
      extraPrefsFiles ? [ ],

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

        # autoconfig hook
        prefsDir="$libDir/defaults/pref"
        mkdir -p "$prefsDir"

        cat > "$prefsDir/autoconfig.js" << 'EOF'
        pref("general.config.filename", "mozilla.cfg");
        pref("general.config.obscure_value", 0);
        EOF

        # main prefs file
        CFG_PATH="$libDir/mozilla.cfg"
        rm -f "$CFG_PATH"

        # first line must be a comment
        echo '// mozilla.cfg' > "$CFG_PATH"

        # inline prefs
        ${final.lib.optionalString (extraPrefs != "") ''
            cat >> "$CFG_PATH" << 'EOF'
          ${extraPrefs}
          EOF
        ''}

        # prefs files
        ${final.lib.concatMapStringsSep "\n" (file: ''
          cat "${file}" >> "$CFG_PATH"
        '') extraPrefsFiles}
      '';
    })
  ) { };
}
