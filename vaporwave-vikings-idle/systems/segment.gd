## A hand-made piece of surface level. See docs/game-systems/level-builder.md.
## Origin is the bottom-left corner; rows count up from the bottom (row 0).
class_name Segment
extends Node2D

@export var segment_id: String = ""
@export var width_blocks: int = 48
@export var entry_row: int = 2
@export var exit_row: int = 2
