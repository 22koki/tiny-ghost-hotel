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
@onready var hotel_stage: Control = $HotelStage

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

	var windows: Array[ColorRect] = _build_hotel_stage(night)
	_animate_hotel(windows, night)

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


func _build_hotel_stage(night: int) -> Array[ColorRect]:
	var windows: Array[ColorRect] = []
	var body: ColorRect = ColorRect.new()
	body.position = Vector2(120, 120)
	body.size = Vector2(540, 310)
	body.color = Color(0.07, 0.03, 0.025, 1.0)
	hotel_stage.add_child(body)

	var roof: Polygon2D = Polygon2D.new()
	roof.polygon = PackedVector2Array([Vector2(90, 130), Vector2(390, 10), Vector2(690, 130)])
	roof.color = Color(0.04, 0.018, 0.018, 1.0)
	hotel_stage.add_child(roof)

	var sign: Label = Label.new()
	sign.text = "TINY GHOST HOTEL"
	sign.position = Vector2(230, 145)
	sign.size = Vector2(320, 45)
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign.add_theme_font_size_override("font_size", 20)
	sign.add_theme_color_override("font_color", Color(0.85, 0.63, 0.28, 1.0))
	hotel_stage.add_child(sign)

	for floor in range(3):
		for column in range(5):
			var window: ColorRect = ColorRect.new()
			window.position = Vector2(165 + column * 88, 205 + floor * 72)
			window.size = Vector2(46, 34)
			window.color = Color(0.12, 0.08, 0.05, 1.0)
			hotel_stage.add_child(window)
			windows.append(window)

	var doorway: ColorRect = ColorRect.new()
	doorway.position = Vector2(350, 360)
	doorway.size = Vector2(80, 70)
	doorway.color = Color(0.12, 0.05, 0.025, 1.0)
	hotel_stage.add_child(doorway)

	for i in range(min(night, 5)):
		var ghost: Label = Label.new()
		ghost.text = "👻"
		ghost.position = Vector2(-120 - i * 110, 70 + (i % 2) * 70)
		ghost.size = Vector2(80, 80)
		ghost.add_theme_font_size_override("font_size", 42)
		hotel_stage.add_child(ghost)
		var flight: Tween = create_tween()
		flight.set_loops()
		flight.tween_property(ghost, "position:x", 820.0, 4.5 + float(i) * 0.35)
		flight.tween_callback(func() -> void: ghost.position.x = -120.0)

	return windows

func _animate_hotel(windows: Array[ColorRect], night: int) -> void:
	hotel_stage.modulate.a = 0.0
	hotel_stage.position.y = 90.0
	var hotel_tween: Tween = create_tween()
	hotel_tween.tween_property(hotel_stage, "modulate:a", 1.0, 0.8)
	hotel_tween.parallel().tween_property(hotel_stage, "position:y", 0.0, 1.0).set_trans(Tween.TRANS_BACK)
	for i in range(windows.size()):
		var target: Color = Color(1.0, 0.68, 0.24, 1.0)
		if night >= 8 and i % 4 == 0:
			target = Color(0.55, 0.08, 0.10, 1.0)
		hotel_tween.tween_property(windows[i], "color", target, 0.07)
	if night >= 4:
		var shake: Tween = create_tween()
		for j in range(7):
			shake.tween_property(hotel_stage, "position:x", 8.0 if j % 2 == 0 else -8.0, 0.045)
		shake.tween_property(hotel_stage, "position:x", 0.0, 0.06)

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
