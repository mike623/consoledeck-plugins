# ConsoleDeck Plugins

Every action a [ConsoleDeck](https://github.com/mike623/consoledeck) button can do is a plugin from this repo.
Install, update and remove them in ConsoleDeck's **Plugins…** window (tray menu). The core ones also ship
inside the app, so a fresh install works offline.

| Plugin | Does |
|---|---|
| `url` Open URL | opens a web page or app link |
| `app` Open App | opens or brings forward an app |
| `script` Run Script | runs a command line you type |
| `key` Press Keys | presses a key combo in the app in front |
| `type` Type Text | types text into the app in front |
| `password` Type Password | types a stored, encrypted password |
| `input` Input Language | switches keyboard layout |
| `system` System | lock, sleep, volume, log out, restart, shut down |
| `vpn` Toggle VPN | connects / disconnects a Tunnelblick VPN (Mac) |
| `cpu` CPU Usage | shows CPU usage live on the Phone Companion (display only) |
| `memory` Memory Usage | shows RAM in use live on the Phone Companion (display only) |
| `network` Network Usage | shows download/upload speed live on the Phone Companion (display only) |

Repeat Keys, Open Editor and Show Cheat Sheet are built into ConsoleDeck itself.

## Writing a plugin

A plugin is a folder `plugins/<id>/` with a `plugin.json` and any scripts it needs. The folder name is the id;
buttons store it as their `"type"` in deck.json.

```json
{
  "id": "vpn",
  "name": "Toggle VPN",
  "version": "1.0.0",
  "description": "Connects a Tunnelblick configuration, or disconnects it when it's up.",
  "platforms": ["mac"],
  "fields": [{ "id": "config", "label": "Tunnelblick VPN", "type": "select", "optionsFrom": ["/bin/bash", "./configs.sh"],
    "button": { "label": "Import .ovpn…", "pickFile": ["ovpn"], "exec": ["/bin/bash", "./import.sh", "{file}"] } }],
  "note": "Shown under the fields in the editor.",
  "label": "VPN {config}",
  "run": { "exec": ["/bin/bash", "./toggle.sh", "{config}"] }
}
```

| Key | |
|---|---|
| `id` | `a-z`, `0-9`, `-`; same as the folder |
| `version` | `1.2.3`; bump it for ConsoleDeck to offer the update |
| `platforms` | `mac`, `windows`; leave out for both |
| `fields` | what the editor asks for (below). The first field's value is stored as the button's `value`, others in `values` |
| `label` | deck / cheat sheet label with `{field}` placeholders; default is the first field's value |
| `run` | what a press does (below) |

### Fields

`id`, `label`, `type`, optional `placeholder`, `monospace` (text areas). Types:

- `text`, `textarea`, `url`
- `app`: text plus a **Choose…** app picker
- `keys`: records a key combo like `shift+cmd+t`
- `password`: stored encrypted, shown masked
- `select`: `options` (`value`, `label`, optional `platforms`, `note`, `run`), or `optionsFrom`: a command printing one
  `value` or `value<TAB>label` per line, run each time the editor shows it (`["inputSources"]` lists the enabled input languages)

A field may have a `button` (`label`, optional `pickFile` extensions, `exec`): the picked file's path is `{file}`
and the command's last output line becomes the field's value.

### Run

Exactly one of these, or per-OS variants under `mac` / `windows`. Strings take `{field}` placeholders.
A select option's own `run` wins over the plugin's.

| | |
|---|---|
| `exec` | `["program", "arg", "{field}"]`, no shell, so values can't inject commands. `./x` is a file in the plugin folder. Runs in the plugin folder with `CONSOLEDECK_DIR` set to the folder deck.json is in |
| `shell` | a command line the user typed (bash on Mac, cmd on Windows) |
| `url`, `app` | open a link / app |
| `keys`, `type`, `password` | press a combo / type text / type a sealed password into the app in front (needs Accessibility on Mac) |
| `input` | switch to an input source id, or `next` |
| `media` | `mute`, `volumeup`, `volumedown` |

### Live

`live` is a command that keeps running (`exec`, or per-OS `exec` under `mac` / `windows`). Each line it prints becomes
the button's text on the Phone Companion, like a Stream Deck key title. It runs only while the companion is on and the
button is in the profile in front. A plugin with `live` needs no `run`. Print a line and flush, e.g. `fflush()` in awk.

```json
"live": { "mac": { "exec": ["/bin/sh", "./cpu.sh"] }, "windows": { "exec": ["powershell", "-File", "./cpu.ps1"] } }
```

Plugins with commands run them as you, with no sandbox. ConsoleDeck shows every command before installing one,
and every plugin here is reviewed before merging.

## Checks

CI runs `python3 tools/build_index.py`, which checks every manifest and regenerates `index.json`
(id, name, version, platforms, files and commands of each plugin), the list the app installs from.
