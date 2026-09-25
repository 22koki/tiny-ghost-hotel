extends Control

@onready var night_label: Label = $NightLabel
@onready var message: Label = $Message
@onready var reveal: Label = $Reveal
@onready var clock: Label = $Clock
@onready var moon: Label = $Moon
@onready var lightning: ColorRect = $Lightning
@onready var fog_left: Label = $FogLeft
@onready var fog_right: Label = $FogRight
@onready var left_door: ColorRect = $Doors/Left
@onready var right_door: ColorRect = $Doors/Right
@onready var seam: ColorRect = $Doors/Seam
@onready var knob_left: Label = $Doors/KnobLeft
@onready var knob_right: Label = $Doors/KnobRight

func _ready() -> void:
	var night: int = GameState.current_night
	night_label.text = "NIGHT %d" % night
	message.text = _night_message(night)
	reveal.text = _unlock_reveal(night)
	night_label.modulate.a = 0.0
	message.modulate.a = 0.0
	reveal.modulate.a = 0.0
	clock.modulate.a = 0.0
	moon.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.tween_interval(0.25)
	tween.parallel().tween_property(left_door, "position:x", -650.0, 1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(right_door, "position:x", 650.0, 1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(seam, "modulate:a", 0.0, 0.35)
	tween.parallel().tween_property(knob_left, "position:x", -650.0, 1.05)
	tween.parallel().tween_property(knob_right, "position:x", 650.0, 1.05)
	tween.parallel().tween_property(fog_left, "position:x", 920.0, 4.2)
	tween.parallel().tween_property(fog_right, "position:x", -900.0, 4.6)
	tween.parallel().tween_property(moon, "modulate:a", 1.0, 1.0)
	tween.tween_interval(0.25)

	for strike in range(3):
		tween.tween_property(clock, "modulate:a", 1.0, 0.10)
		tween.tween_property(clock, "scale", Vector2(1.28, 1.28), 0.16).set_trans(Tween.TRANS_BACK)
		tween.tween_property(clock, "scale", Vector2.ONE, 0.20)
		tween.tween_property(lightning, "modulate:a", 0.20 if night >= 3 else 0.07, 0.05)
		tween.tween_property(lightning, "modulate:a", 0.0, 0.12)
		tween.tween_interval(0.18)

	tween.tween_property(night_label, "modulate:a", 1.0, 0.45)
	tween.parallel().tween_property(night_label, "scale", Vector2(1.10, 1.10), 0.45).set_trans(Tween.TRANS_BACK)
	tween.tween_property(night_label, "scale", Vector2.ONE, 0.20)
	tween.tween_property(message, "modulate:a", 1.0, 0.45)
	tween.tween_property(reveal, "modulate:a", 1.0, 0.55)

	if night >= 5:
		tween.tween_property(lightning, "modulate:a", 0.62, 0.05)
		tween.tween_property(lightning, "modulate:a", 0.0, 0.10)
		tween.tween_property(self, "position:x", 12.0, 0.05)
		tween.tween_property(self, "position:x", -10.0, 0.05)
		tween.tween_property(self, "position:x", 0.0, 0.05)
	if night >= 8:
		tween.tween_property(moon, "modulate", Color(0.45, 0.08, 0.09, 1.0), 0.55)
		tween.tween_property(lightning, "modulate:a", 0.85, 0.06)
		tween.tween_property(lightning, "modulate:a", 0.0, 0.16)

	tween.tween_interval(1.35)
	tween.tween_property(self, "modulate:a", 0.0, 0.65)
	tween.tween_callback(_enter_night)

func _night_message(night: int) -> String:
	match night:
		2: return "THE HOTEL STIRS..."
		3: return "A VIP BELL RINGS IN THE DISTANCE..."
		4: return "FOOTSTEPS ECHO THROUGH FORGOTTEN HALLS..."
		5: return "THE HOTEL GROWS BEYOND ITS OLD WALLS..."
		6: return "TWO LAUGHS ANSWER FROM THE CORRIDOR..."
		7: return "THE CLOCKS BEGIN TICKING BACKWARDS..."
		8: return "AN ECLIPSE FALLS OVER THE ROYAL HAUNT..."
		_: return "ANOTHER MIDNIGHT SHIFT BEGINS..."

func _unlock_reveal(night: int) -> String:
	var names: Array[String] = []
	for room_id in RoomCatalog.get_all_room_ids():
		var room: Dictionary = RoomCatalog.get_room(room_id)
		if int(room.get("unlock_night", 1)) == night:
			names.append(str(room.get("name", "Unknown Room")))
	if night == 8:
		names.append("LEGENDARY GUEST: MADAME UMBRA")
	if names.is_empty():
		return "The brass doors unlock for another night."
	return "NEW TONIGHT  •  " + "  •  ".join(names)

func _enter_night() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
