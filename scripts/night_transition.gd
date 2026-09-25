extends Control

@onready var night_label: Label = $NightLabel
@onready var message: Label = $Message
@onready var reveal: Label = $Reveal
@onready var clock: Label = $Clock
@onready var moon: Label = $Moon

func _ready() -> void:
	modulate.a = 0.0
	var night: int = GameState.current_night
	night_label.text = "NIGHT %d" % night
	message.text = _night_message(night)
	reveal.text = _unlock_reveal(night)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.7)
	tween.tween_property(clock, "scale", Vector2(1.12, 1.12), 0.35).set_trans(Tween.TRANS_BACK)
	tween.tween_property(clock, "scale", Vector2.ONE, 0.25)
	tween.tween_interval(0.65)
	tween.tween_property(night_label, "modulate:a", 0.35, 0.18)
	tween.tween_property(night_label, "modulate:a", 1.0, 0.22)
	tween.tween_interval(1.35)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
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
