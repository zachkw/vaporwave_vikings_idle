#!/usr/bin/env python3
"""Generate the five proof segments (scenes + metadata).

Run from the Godot project folder:  python3 tools/gen_proof_segments.py
Edit SEGMENTS below, re-run, and commit the outputs.
"""
import json
import os

BLOCK = 32          # pixels per block (must match content/viking.json physics.block_px)
FLOOR_ROW = 2       # floor surface row for every proof segment
WIDTH = 48          # blocks
PLATFORM_THICKNESS = 0.5  # blocks

GROUND_COLOR = "Color(0.18, 0.55, 0.45, 1)"
PLATFORM_COLOR = "Color(0.85, 0.35, 0.9, 1)"

# pits: [start_block, end_block)   platforms: (start_block, end_block, top_row)
SEGMENTS = [
    {"id": "proof_flat",        "roles": ["start", "run"],      "pits": [],                  "platforms": []},
    {"id": "proof_pit",         "roles": ["jump"],              "pits": [[22, 25]],          "platforms": []},
    {"id": "proof_platform",    "roles": ["run", "platform"],   "pits": [],                  "platforms": [[21, 27, 5]]},
    {"id": "proof_platforms_2", "roles": ["run", "platform"],   "pits": [],                  "platforms": [[12, 18, 5], [30, 36, 5]]},
    {"id": "proof_pits_2",      "roles": ["jump"],              "pits": [[14, 17], [31, 34]], "platforms": []},
]


def ground_spans(pits):
    spans, x = [], 0
    for a, b in sorted(pits):
        if a > x:
            spans.append((x, a))
        x = b
    if x < WIDTH:
        spans.append((x, WIDTH))
    return spans


def scene_text(seg):
    subs, nodes = [], []
    floor_y = -FLOOR_ROW * BLOCK
    for i, (a, b) in enumerate(ground_spans(seg["pits"])):
        w = (b - a) * BLOCK
        h = FLOOR_ROW * BLOCK
        sid = f"ground_{i}"
        subs.append(f'[sub_resource type="RectangleShape2D" id="{sid}"]\nsize = Vector2({w}, {h})\n')
        cx, cy = a * BLOCK + w / 2, -h / 2
        nodes.append(
            f'[node name="Ground{i}" type="StaticBody2D" parent="Terrain"]\nposition = Vector2({cx}, {cy})\n\n'
            f'[node name="Shape" type="CollisionShape2D" parent="Terrain/Ground{i}"]\nshape = SubResource("{sid}")\n\n'
            f'[node name="Visual" type="ColorRect" parent="Terrain/Ground{i}"]\n'
            f'offset_left = {-w / 2}\noffset_top = {-h / 2}\noffset_right = {w / 2}\noffset_bottom = {h / 2}\n'
            f'mouse_filter = 2\ncolor = {GROUND_COLOR}\n'
        )
    for i, (a, b, row) in enumerate(seg["platforms"]):
        w = (b - a) * BLOCK
        h = PLATFORM_THICKNESS * BLOCK
        sid = f"platform_{i}"
        subs.append(f'[sub_resource type="RectangleShape2D" id="{sid}"]\nsize = Vector2({w}, {h})\n')
        cx, cy = a * BLOCK + w / 2, -row * BLOCK + h / 2
        nodes.append(
            f'[node name="Platform{i}" type="StaticBody2D" parent="Terrain"]\nposition = Vector2({cx}, {cy})\n\n'
            f'[node name="Shape" type="CollisionShape2D" parent="Terrain/Platform{i}"]\nshape = SubResource("{sid}")\none_way_collision = true\n\n'
            f'[node name="Visual" type="ColorRect" parent="Terrain/Platform{i}"]\n'
            f'offset_left = {-w / 2}\noffset_top = {-h / 2}\noffset_right = {w / 2}\noffset_bottom = {h / 2}\n'
            f'mouse_filter = 2\ncolor = {PLATFORM_COLOR}\n'
        )
    head = (
        f'[gd_scene load_steps={len(subs) + 2} format=3]\n\n'
        f'[ext_resource type="Script" path="res://systems/segment.gd" id="1_segment"]\n\n'
        + "\n".join(subs) + "\n"
        f'[node name="{seg["id"]}" type="Node2D"]\nscript = ExtResource("1_segment")\n'
        f'segment_id = "{seg["id"]}"\nwidth_blocks = {WIDTH}\nentry_row = {FLOOR_ROW}\nexit_row = {FLOOR_ROW}\n\n'
        f'[node name="Entry" type="Marker2D" parent="."]\nposition = Vector2(0, {floor_y})\n\n'
        f'[node name="Exit" type="Marker2D" parent="."]\nposition = Vector2({WIDTH * BLOCK}, {floor_y})\n\n'
        f'[node name="Terrain" type="Node2D" parent="."]\n\n'
    )
    return head + "\n".join(nodes)


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    scene_dir = os.path.join(root, "scenes", "segments", "proof")
    os.makedirs(scene_dir, exist_ok=True)
    meta = []
    for seg in SEGMENTS:
        path = os.path.join(scene_dir, seg["id"] + ".tscn")
        with open(path, "w", newline="\n") as f:
            f.write(scene_text(seg))
        meta.append({
            "id": seg["id"],
            "scene": f"res://scenes/segments/proof/{seg['id']}.tscn",
            "biomes": ["proof"],
            "width": WIDTH,
            "entry_row": FLOOR_ROW,
            "exit_row": FLOOR_ROW,
            "roles": seg["roles"],
            "difficulty": 1,
            "weight": 1.0,
            "cooldown": 1,
            "pits": seg["pits"],
            "platforms": [{"from": a, "to": b, "top_row": r} for a, b, r in seg["platforms"]],
            "slots": [],
            "flags": [],
        })
    out = os.path.join(root, "content", "segments", "proof.json")
    with open(out, "w", newline="\n") as f:
        json.dump(meta, f, indent=2)
        f.write("\n")
    print(f"wrote {len(SEGMENTS)} scenes and {out}")


if __name__ == "__main__":
    main()
