# config.nu
#
# Installed by:
# version = "0.110.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# ─────────────────────────────────────────────────────────────────────────────
# External Completions using Fish
# ─────────────────────────────────────────────────────────────────────────────

# Fish completer - leverages Fish shell's excellent built-in completions
let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str replace --all "'" "\\'" | str join " ")"'
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
        let value = $row.value
        # Characters that require quoting in Nushell
        let need_quote = ['\ ' ' ' '[' ']' '(' ')' ' ' "\t" "'" '"' '`'] | any {$in in $value}
        if ($need_quote and ($value | path exists)) {
            # Expand ~ and quote the path for Nushell compatibility
            let expanded_path = if ($value starts-with '~') {
                $value | path expand --no-symlink
            } else {
                $value
            }
            $'"($expanded_path | str replace --all `"` `\"`)"'
        } else {
            $value
        }
    }
}

# Carapace completer (optional fallback if you have carapace installed)
let carapace_completer = {|spans: list<string>|
    # Check if carapace is available
    let has_carapace = (which carapace | is-not-empty)
    if $has_carapace {
        carapace $spans.0 nushell ...$spans
        | from json
        | if ($in | default [] | where { $in.value? != null } | any {|it| ($it.value | str starts-with "ERR") }) {
            null
        } else {
            $in
        }
    } else {
        null
    }
}

# Combined external completer with alias expansion
let external_completer = {|spans|
    # Expand aliases to get the actual command
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    # Use fish for everything - it has excellent completions out of the box
    # You can customize this match block if you prefer carapace for certain commands
    match $spans.0 {
        _ => $fish_completer
    } | do $in $spans
}

# Apply completion configuration
$env.config.completions = {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "prefix"  # or "fuzzy" for fuzzy matching
    sort: "smart"
    external: {
        enable: true
        max_results: 100
        completer: $external_completer
    }
    use_ls_colors: true
}
