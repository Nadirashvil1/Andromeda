# Andromeda — Godot Dev Session Summary

A running log of what was built and fixed in this conversation, so a new chat can pick up where this one left off.

## Project context
- Game: **Andromeda**, psychological horror, Godot 4.6, solo dev
- Models from Blender, imported as **.glb**
- Player setup: `CharacterBody3D` → `head` (Node3D, mouse look) → `Camera3D` + `RayCast3D`
- Scripts live under `res://player/` and `res://Levels/`
- Notion was hitting the free 1,000-block limit → mid-discussion about migrating docs to GitHub Wiki (not finished)

## Systems built

### 1. Collision / mesh basics
- GLB meshes are read-only — use **Make Local / Editable Children** to edit, or **Mesh → Create Trimesh Static Body** to auto-generate collision matching the mesh.
- For small pickup-style items, a simple shape (Box/Sphere) on the Area3D is more reliable than `ConcavePolygonShape` for raycasts.

### 2. Interact prompt + raycast detection
- `RayCast3D` lives under `player/head/RayCast3D`, target position `(0,0,-2)` (later increased), collision layer/mask both on layer 1.
- `player.gd` walks up the parent tree from whatever the ray hits until it finds a node in the `interactable` group (since `hit.owner` pointed to the whole level, not the item).
- Interact is **hold-to-trigger** (not just-pressed) using a timer (`hold_threshold`, currently short ~0.3s), showing a `% ` progress in the label text.
- `interact` input action = **E key**.
- UI: `CanvasLayer` → `Crosshair` (Label, "+", centered) and `InteractLabel` (Label, bottom-center, hidden by default).

### 3. Groups used
- `player` — on the CharacterBody3D root.
- `interactable` — on the **root item node** (e.g. `Sword`, `painting`, `note`), NOT on the StaticBody3D child. The raycast hits the StaticBody3D, then walks up to find the group.

### 4. Inspect Manager (Autoload singleton, `InspectManager` → `res://player/inspect_manager.gd`)
Handles all inspection logic centrally. Each inspectable item just needs:
```gdscript
extends Node3D
var item_name = "..."
var item_description = "..."
var is_readable = false
var readable_text = ""
var inspect_type = "move"   # or "pin"
var inspect_distance = 0.5  # tune per item size

func inspect():
    InspectManager.start_inspect(self)
```

**Two inspect types:**
- `"move"` — item flies toward the camera (sword, note). Player can click-drag (LMB) to rotate it. Mouse is visible.
- `"pin"` — camera/player stays exactly still, just frozen in place looking at the item (painting on a wall). Mouse stays captured, no rotation allowed.

**Key fixes along the way:**
- Player's `set_process_input(false)` only stops the CharacterBody3D's own `_input`, NOT child nodes like the camera script — `fp_cam.gd` needed its own check: `if InspectManager.is_inspecting: return`.
- Reparenting the item to the camera caused scale/rotation/teleport issues → switched to **tweening `global_position`/`rotation` in world space** instead of reparenting.
- After closing inspect, player camera felt "drunk" — fixed by **saving and restoring** `player_node.global_rotation` and `head_node.global_rotation` exactly on stop.
- All `InputEventMouseMotion` is marked `set_input_as_handled()` while inspecting so `fp_cam.gd` never sees it and can't drift the view.
- Removed an attempted dark-overlay "blur" (was just a transparent ColorRect, not real DOF). Real depth-of-field option discussed: `Camera3D.attributes = CameraAttributesPractical`, toggle `dof_blur_far_enabled` in script — not yet implemented.

### 5. Readable items (notes/letters) — Amazing Spider-Man style
- Added `is_readable` + `readable_text` per item.
- New input action **`read` = F key**.
- `CanvasLayer` → `ReadPanel` (PanelContainer, centered, hidden by default) → `VBoxContainer` → `ReadText` (Label, autowrap) + `ReadHints` (Label, "[ F ] Close").
- `InspectManager._toggle_read_panel()` shows/hides ReadPanel and swaps the `InteractLabel` text between `[ E ] Close  [ F ] Read` and hidden-while-reading.
- `stop_inspect()` checks if `ReadPanel` is visible first — pressing E while reading closes the text instead of exiting inspect mode entirely (must close text first, then E again to exit inspect).
- Multiple-page support flagged as a **future TODO**, not built yet.

### 6. Known hardcoded-path issue (in progress)
`get_node("/root/level/CanvasLayer/InteractLabel")`-style absolute paths break in any new scene that isn't named `level` (e.g. a new `scene_01` test scene). Fix identified but not fully applied everywhere yet:
```gdscript
@onready var interact_label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
```
This needs to be swapped in **player.gd** and **inspect_manager.gd** anywhere `/root/level/...` is hardcoded.

## Non-Godot fixes from this session

### Trackpad mouse-look on Arch + Hyprland
- Symptom: camera look-around stutters/locks when WASD is pressed on laptop trackpad (works fine with a real mouse, fine on Windows/Mac).
- Cause: Linux/Hyprland's "disable trackpad while typing" behavior, not a Godot bug.
- Fix: in `~/.config/hypr/hyprland.conf`:
```
input {
    touchpad {
        disable_while_typing = false
    }
}
```
Then `hyprctl reload`.

### Git branch cleanup
- Repo had `main` and `master`; project work continued on `master`.
- Set `master` as default branch: GitHub → repo **Settings → General → Default branch**.
- Delete old branch: `git push origin --delete main`.

### Notion hitting block limit
- Free Notion plan caps at 1,000 blocks per workspace (not unlimited as advertised for some tiers).
- Discussed migrating the Andromeda game bible (World & Lore, House, Characters, Story Map, etc.) to **GitHub Wiki** since the project already lives on GitHub. Pages were being read via Notion API but the transfer was not completed in this session.

## Open / next steps
1. Finish replacing all hardcoded `/root/level/...` paths with `get_tree().current_scene.get_node(...)`.
2. Build out `scene_01` as a prototype/testing level with all current assets (sword, note, painting, house).
3. Add a **lamp** + lighting setup (handheld vs static lamp — undecided when session ended).
4. Add an **inventory system**.
5. Optional: real depth-of-field via `CameraAttributesPractical` instead of the removed flat overlay.
6. Optional: multi-page support for readable notes.
7. Optional: finish Notion → GitHub Wiki migration.
