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
| `cpu` CPU Usage | phone tile: CPU usage, with a chart |
| `memory` Memory Usage | phone tile: memory used, like Activity Monitor, with a chart |
| `network` Network Usage | phone tile: download/upload speed, with a chart |
| `boosteroid` Boosteroid Game | a profile per game streamed in Boosteroid (Mac) |
| `le-scanner` Last Epoch Scanner | runs [le-scanner](https://github.com/mike623/le-tool) actions; phone tile shows progress (Mac) |
| `le-character` Last Epoch Character | phone tiles with le-scanner's character stats: level, health, resistances... (Mac) |
| `satisfactory` Satisfactory | opens Satisfactory Calculator blueprints, interactive map, or one blueprint |

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
| `label` | deck / cheat sheet label with `{field}` placeholders; default is the first field's value. A filled-in field with id `name` wins over both |
| `run` | what a press does (below) |
| `live` | a long-running `exec` whose output lines show on a phone tile (`cpu`). A tile-only plugin whose first field is a `select` is added once per option, labelled by it (`le-character`) |
| `contextFor` | app ids; the `live` command prints what's on in that app (a game), or an empty line for nothing. While that app is in front, ConsoleDeck uses the profile `<app id>/<line>`, falling back to the app's own (`boosteroid`) |

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
the text of a tile on the Phone Companion, shown apart from the buttons (**Phone shows** in the Actions window). It runs
only while the companion is on. A plugin with `live` needs no `run`; without one it isn't offered for buttons. Print a
line and flush, e.g. `fflush()` in awk. Tab-separated numbers after the text (`26%<TAB>0.26`, with a dot) add a chart of the
last minute under it, one line per number (green, then red). Its top is 1, or the biggest number shown, so give 0 to 1
for a share, or raw values like bytes per second.

```json
"live": { "mac": { "exec": ["/bin/sh", "./cpu.sh"] }, "windows": { "exec": ["powershell", "-File", "./cpu.ps1"] } }
```

Plugins with commands run them as you, with no sandbox. ConsoleDeck shows every command before installing one,
and every plugin here is reviewed before merging.

## Checks

CI runs `python3 tools/build_index.py`, which checks every manifest and regenerates `index.json`
(id, name, version, platforms, files and commands of each plugin), the list the app installs from.
