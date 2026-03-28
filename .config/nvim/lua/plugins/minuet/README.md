# Minuet: LLM Inline Completions

Ghost-text code suggestions powered by an LLM, shown as virtual text in insert mode.

## Setup

Minuet needs an OpenAI-compatible API key at `~/.local/keys/openai.key` (one line, no
trailing newline). The default provider is `gpt-4.1-mini` via the OpenAI chat endpoint.

To switch providers, edit `settings.lua` under `provider_options`. Any
OpenAI-compatible endpoint works (OpenRouter, Ollama, etc.).

## Keybindings

All keybindings are defined in `lua/config.lua` under the `minuet` key. Override them
there, not in the plugin files.

| Key          | Mode   | Action                                     |
| ------------ | ------ | ------------------------------------------ |
| `<leader>ai` | normal | Toggle auto-suggest on/off for the session |
| `<A-o>`      | insert | Next suggestion (or trigger if none shown) |
| `<A-i>`      | insert | Previous suggestion                        |
| `<A-y>`      | insert | Accept the current suggestion              |
| `<A-n>`      | insert | Dismiss the current suggestion             |

Auto-suggest starts **disabled** by default so nothing fires until you toggle it on.
This prevents accidental API calls when editing sensitive documents.

`<A-o>` doubles as a manual trigger: press it with no suggestion showing and minuet
requests one on the spot, regardless of whether auto-suggest is enabled.

## Loading indicator

A `...` animation appears at the end of the cursor line while a request is in flight.
It uses minuet's `MinuetRequestStarted` / `MinuetRequestFinished` autocmd events and
clears itself when the response arrives or the request is cancelled.

## Files

| File             | Purpose                                               |
| ---------------- | ----------------------------------------------------- |
| `init.lua`       | Plugin spec for lazy.nvim                             |
| `settings.lua`   | Provider config, spinner, keybinding registration     |
| `lua/config.lua` | Keybinding overrides (shared config, not in this dir) |

## Potential issues

**"Provide at most 1 completion items"**: if cycling does nothing, check
`:messages` for this string in the system prompt. It means `n_completions` resolved
to 1. Restart Neovim after changing the config file; minuet reads it once at setup.

**Single suggestion despite n_completions=3**: chat-based models (gpt-4.1-mini) encode
the count as a prompt hint. The model may still return fewer. FIM-capable endpoints
(Codestral, DeepSeek) make N separate requests and reliably produce N suggestions.

**API key not found**: minuet reads `~/.local/keys/openai.key` via `io.open`. If the
file is missing or empty, completions silently fail. Check `:messages` for errors.

**Auto-suggest fires on personal documents**: toggle it off with `<leader>ai`. The
default is disabled; you must opt in each session.
