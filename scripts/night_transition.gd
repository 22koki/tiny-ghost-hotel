extends Control

@onready var night_label: Label = $NightLabel
@onready var message: Label = $Message
@onready var reveal: Label = $Reveal
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
@onready var old_clock_symbol: Label = $Clock

var grandfather_clock: Control
var pendulum: Label
var hotel_windows: Array[ColorRect] = []
var flying_spirits: Array[Label] = []
var walkers: Array[Label] = []
var spiders: Array[Label] = []
var scene_night: int = 1

func _ready() -> void:
	scene_night = GameState.current_night
	old_clock_symbol.visible = false
	night_label.text = "NIGHT %d" % scene_night
	message.text = _night_message(scene_night)
	reveal.text = _unlock_reveal(scene_night)
	_prepare_text()
	_build_world(scene_night)
	_play_ghost_howl()
	_play_cinematic(scene_night)

func _prepare_text() -> void:
	night_label.modulate.a = 0.0
	message.modulate.a = 0.0
	reveal.modulate.a = 0.0
	moon.modulate.a = 0.0

func _build_world(night: int) -> void:
	hotel_windows = _build_hotel()
	_build_grandfather_clock()
	_build_graveyard()
	_build_webs_and_spiders()
	_build_flying_creatures(night)
	_build_zombies(night)
	_build_atmosphere_details(night)

func _build_hotel() -> Array[ColorRect]:
	var windows: Array[ColorRect] = []

	var body: ColorRect = ColorRect.new()
	body.position = Vector2(120, 118)
	body.size = Vector2(540, 315)
	body.color = Color(0.055, 0.024, 0.022, 1.0)
	hotel_stage.add_child(body)

	var wing_left: ColorRect = ColorRect.new()
	wing_left.position = Vector2(42, 205)
	wing_left.size = Vector2(115, 225)
	wing_left.color = Color(0.047, 0.021, 0.021, 1.0)
	hotel_stage.add_child(wing_left)

	var wing_right: ColorRect = ColorRect.new()
	wing_right.position = Vector2(623, 205)
	wing_right.size = Vector2(115, 225)
	wing_right.color = Color(0.047, 0.021, 0.021, 1.0)
	hotel_stage.add_child(wing_right)

	var roof: Polygon2D = Polygon2D.new()
	roof.polygon = PackedVector2Array([
		Vector2(86, 132),
		Vector2(390, 2),
		Vector2(694, 132)
	])
	roof.color = Color(0.027, 0.012, 0.018, 1.0)
	hotel_stage.add_child(roof)

	for tower_x in [76.0, 632.0]:
		var tower_roof: Polygon2D = Polygon2D.new()
		tower_roof.polygon = PackedVector2Array([
			Vector2(tower_x - 32.0, 210.0),
			Vector2(tower_x + 24.0, 142.0),
			Vector2(tower_x + 80.0, 210.0)
		])
		tower_roof.color = Color(0.025, 0.011, 0.017, 1.0)
		hotel_stage.add_child(tower_roof)

	var sign: Label = Label.new()
	sign.text = "TINY GHOST HOTEL"
	sign.position = Vector2(225, 142)
	sign.size = Vector2(330, 45)
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign.add_theme_font_size_override("font_size", 21)
	sign.add_theme_color_override("font_color", Color(0.90, 0.63, 0.25, 1.0))
	hotel_stage.add_child(sign)

	for floor in range(3):
		for column in range(5):
			var window: ColorRect = ColorRect.new()
			window.position = Vector2(163 + column * 90, 205 + floor * 72)
			window.size = Vector2(47, 35)
			window.color = Color(0.07, 0.055, 0.045, 1.0)
			hotel_stage.add_child(window)
			windows.append(window)

	for side_x in [70.0, 655.0]:
		for floor in range(2):
			var side_window: ColorRect = ColorRect.new()
			side_window.position = Vector2(side_x, 250 + floor * 72)
			side_window.size = Vector2(44, 34)
			side_window.color = Color(0.07, 0.055, 0.045, 1.0)
			hotel_stage.add_child(side_window)
			windows.append(side_window)

	var doorway: ColorRect = ColorRect.new()
	doorway.position = Vector2(350, 360)
	doorway.size = Vector2(80, 73)
	doorway.color = Color(0.11, 0.045, 0.022, 1.0)
	hotel_stage.add_child(doorway)

	var door_glow: ColorRect = ColorRect.new()
	door_glow.position = Vector2(365, 380)
	door_glow.size = Vector2(50, 42)
	door_glow.color = Color(0.7, 0.34, 0.09, 0.28)
	doorway.add_child(door_glow)

	var chimney_smoke: Label = Label.new()
	chimney_smoke.text = "☁  ☁"
	chimney_smoke.position = Vector2(530, 20)
	chimney_smoke.size = Vector2(180, 80)
	chimney_smoke.add_theme_font_size_override("font_size", 28)
	chimney_smoke.add_theme_color_override("font_color", Color(0.55, 0.58, 0.62, 0.16))
	hotel_stage.add_child(chimney_smoke)
	var smoke_tween: Tween = create_tween()
	smoke_tween.set_loops()
	smoke_tween.tween_property(chimney_smoke, "position:y", -25.0, 2.4)
	smoke_tween.parallel().tween_property(chimney_smoke, "modulate:a", 0.0, 2.4)
	smoke_tween.tween_callback(func() -> void:
		chimney_smoke.position.y = 20.0
		chimney_smoke.modulate.a = 1.0
	)

	return windows

func _build_grandfather_clock() -> void:
	grandfather_clock = Control.new()
	grandfather_clock.position = Vector2(70, 170)
	grandfather_clock.size = Vector2(180, 430)
	grandfather_clock.modulate.a = 0.0
	add_child(grandfather_clock)

	var case: ColorRect = ColorRect.new()
	case.position = Vector2(35, 45)
	case.size = Vector2(110, 315)
	case.color = Color(0.12, 0.052, 0.025, 1.0)
	grandfather_clock.add_child(case)

	var crown: Polygon2D = Polygon2D.new()
	crown.polygon = PackedVector2Array([
		Vector2(28, 62),
		Vector2(90, 2),
		Vector2(152, 62)
	])
	crown.color = Color(0.10, 0.038, 0.018, 1.0)
	grandfather_clock.add_child(crown)

	var face: Label = Label.new()
	face.text = "◷"
	face.position = Vector2(49, 55)
	face.size = Vector2(82, 82)
	face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	face.add_theme_font_size_override("font_size", 58)
	face.add_theme_color_override("font_color", Color(0.92, 0.75, 0.42, 1.0))
	grandfather_clock.add_child(face)

	var glass: ColorRect = ColorRect.new()
	glass.position = Vector2(61, 145)
	glass.size = Vector2(58, 155)
	glass.color = Color(0.05, 0.035, 0.035, 0.72)
	grandfather_clock.add_child(glass)

	pendulum = Label.new()
	pendulum.text = "●"
	pendulum.position = Vector2(62, 170)
	pendulum.size = Vector2(56, 115)
	pendulum.pivot_offset = Vector2(28, 0)
	pendulum.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pendulum.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	pendulum.add_theme_font_size_override("font_size", 31)
	pendulum.add_theme_color_override("font_color", Color(0.87, 0.62, 0.25, 1.0))
	grandfather_clock.add_child(pendulum)

	var feet: Label = Label.new()
	feet.text = "╱╲        ╱╲"
	feet.position = Vector2(22, 345)
	feet.size = Vector2(140, 40)
	feet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feet.add_theme_color_override("font_color", Color(0.30, 0.14, 0.07, 1.0))
	grandfather_clock.add_child(feet)

	var swing: Tween = create_tween()
	swing.set_loops()
	swing.tween_property(pendulum, "rotation", 0.24, 0.55).set_trans(Tween.TRANS_SINE)
	swing.tween_property(pendulum, "rotation", -0.24, 1.10).set_trans(Tween.TRANS_SINE)
	swing.tween_property(pendulum, "rotation", 0.0, 0.55).set_trans(Tween.TRANS_SINE)

func _build_graveyard() -> void:
	var ground: ColorRect = ColorRect.new()
	ground.position = Vector2(0, 620)
	ground.size = Vector2(1280, 100)
	ground.color = Color(0.02, 0.018, 0.02, 1.0)
	add_child(ground)

	for i in range(8):
		var stone: Label = Label.new()
		stone.text = "▰"
		stone.position = Vector2(60 + i * 165, 585 + (i % 3) * 11)
		stone.size = Vector2(55, 55)
		stone.add_theme_font_size_override("font_size", 38)
		stone.add_theme_color_override("font_color", Color(0.20, 0.21, 0.22, 0.78))
		add_child(stone)

	for i in range(4):
		var branch: Label = Label.new()
		branch.text = "╱╲╱╲"
		branch.position = Vector2(30 + i * 350, 510)
		branch.size = Vector2(150, 120)
		branch.add_theme_font_size_override("font_size", 30)
		branch.add_theme_color_override("font_color", Color(0.10, 0.07, 0.07, 0.75))
		add_child(branch)

func _build_webs_and_spiders() -> void:
	var web_positions: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(1080, 5),
		Vector2(15, 410),
		Vector2(1110, 430)
	]
	for pos in web_positions:
		var web: Label = Label.new()
		web.text = "🕸"
		web.position = pos
		web.size = Vector2(190, 150)
		web.add_theme_font_size_override("font_size", 88)
		web.add_theme_color_override("font_color", Color(0.72, 0.72, 0.76, 0.35))
		add_child(web)

	for i in range(3):
		var spider: Label = Label.new()
		spider.text = "🕷"
		spider.position = Vector2(145 + i * 440, -60 - i * 30)
		spider.size = Vector2(80, 80)
		spider.add_theme_font_size_override("font_size", 36)
		add_child(spider)
		spiders.append(spider)
		var crawl: Tween = create_tween()
		crawl.set_loops()
		crawl.tween_property(spider, "position:y", 190.0 + i * 38, 2.5 + i * 0.5).set_trans(Tween.TRANS_SINE)
		crawl.tween_property(spider, "position:y", -60.0 - i * 30, 2.2 + i * 0.4).set_trans(Tween.TRANS_SINE)

func _build_flying_creatures(night: int) -> void:
	var count: int = mini(3 + night, 8)
	for i in range(count):
		var spirit: Label = Label.new()
		spirit.text = "👻" if i % 3 != 0 else "🦇"
		spirit.position = Vector2(-150 - i * 120, 70 + (i % 4) * 68)
		spirit.size = Vector2(90, 80)
		spirit.add_theme_font_size_override("font_size", 35 + (i % 2) * 8)
		spirit.modulate.a = 0.82
		add_child(spirit)
		flying_spirits.append(spirit)
		var flight: Tween = create_tween()
		flight.set_loops()
		flight.tween_property(spirit, "position", Vector2(1380, spirit.position.y - 30 + (i % 3) * 40), 4.0 + i * 0.42).set_trans(Tween.TRANS_SINE)
		flight.tween_callback(func() -> void:
			spirit.position.x = -150.0
		)

func _build_zombies(night: int) -> void:
	var count: int = 2 if night < 4 else 4
	for i in range(count):
		var zombie: Label = Label.new()
		zombie.text = "🧟"
		zombie.position = Vector2(-100 - i * 260, 555 + (i % 2) * 25)
		zombie.size = Vector2(90, 90)
		zombie.add_theme_font_size_override("font_size", 48)
		add_child(zombie)
		walkers.append(zombie)
		var walk: Tween = create_tween()
		walk.set_loops()
		walk.tween_property(zombie, "position:x", 1380.0, 9.0 + i * 1.1)
		walk.tween_callback(func() -> void:
			zombie.position.x = -100.0
		)

func _build_atmosphere_details(night: int) -> void:
	for i in range(18):
		var mote: Label = Label.new()
		mote.text = "·"
		mote.position = Vector2(40 + (i * 67) % 1180, 90 + (i * 97) % 500)
		mote.size = Vector2(20, 20)
		mote.add_theme_font_size_override("font_size", 20)
		mote.add_theme_color_override("font_color", Color(0.72, 0.66, 0.52, 0.22))
		add_child(mote)
		var drift: Tween = create_tween()
		drift.set_loops()
		drift.tween_property(mote, "position:y", mote.position.y - 45.0, 2.8 + float(i % 5) * 0.35)
		drift.tween_property(mote, "position:y", mote.position.y + 45.0, 2.8 + float(i % 5) * 0.35)

	if night >= 6:
		var eyes: Label = Label.new()
		eyes.text = "•       •"
		eyes.position = Vector2(1020, 520)
		eyes.size = Vector2(120, 50)
		eyes.add_theme_font_size_override("font_size", 28)
		eyes.add_theme_color_override("font_color", Color(0.78, 0.08, 0.08, 0.8))
		add_child(eyes)
		var blink: Tween = create_tween()
		blink.set_loops()
		blink.tween_interval(1.0)
		blink.tween_property(eyes, "modulate:a", 0.0, 0.08)
		blink.tween_interval(0.22)
		blink.tween_property(eyes, "modulate:a", 1.0, 0.08)

func _play_cinematic(night: int) -> void:
	hotel_stage.modulate.a = 0.0
	hotel_stage.position.y = 65.0

	var door_tween: Tween = create_tween()
	door_tween.tween_interval(0.15)
	door_tween.parallel().tween_property(left_door, "position:x", -650.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_tween.parallel().tween_property(right_door, "position:x", 650.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_tween.parallel().tween_property(seam, "modulate:a", 0.0, 0.25)
	door_tween.parallel().tween_property(knob_left, "position:x", -650.0, 0.9)
	door_tween.parallel().tween_property(knob_right, "position:x", 650.0, 0.9)

	var cinematic: Tween = create_tween()
	cinematic.tween_interval(0.55)
	cinematic.tween_property(grandfather_clock, "modulate:a", 1.0, 0.45)
	cinematic.parallel().tween_property(moon, "modulate:a", 1.0, 0.7)
	cinematic.tween_interval(0.30)

	for strike in range(3):
		cinematic.tween_property(grandfather_clock, "scale", Vector2(1.08, 1.08), 0.10).set_trans(Tween.TRANS_BACK)
		cinematic.tween_property(grandfather_clock, "scale", Vector2.ONE, 0.13)
		cinematic.tween_property(lightning, "modulate:a", 0.30 if night >= 3 else 0.10, 0.04)
		cinematic.tween_property(lightning, "modulate:a", 0.0, 0.09)
		cinematic.tween_interval(0.14)

	cinematic.tween_property(hotel_stage, "modulate:a", 1.0, 0.65)
	cinematic.parallel().tween_property(hotel_stage, "position:y", 0.0, 0.8).set_trans(Tween.TRANS_BACK)

	for i in range(hotel_windows.size()):
		var target: Color = Color(1.0, 0.67, 0.22, 1.0)
		if night >= 8 and i % 4 == 0:
			target = Color(0.68, 0.05, 0.08, 1.0)
		cinematic.tween_property(hotel_windows[i], "color", target, 0.045)
		if i % 4 == 3:
			cinematic.tween_property(lightning, "modulate:a", 0.10, 0.02)
			cinematic.tween_property(lightning, "modulate:a", 0.0, 0.04)

	cinematic.tween_property(night_label, "modulate:a", 1.0, 0.32)
	cinematic.parallel().tween_property(night_label, "scale", Vector2(1.12, 1.12), 0.32).set_trans(Tween.TRANS_BACK)
	cinematic.tween_property(night_label, "scale", Vector2.ONE, 0.18)
	cinematic.tween_property(message, "modulate:a", 1.0, 0.30)
	cinematic.tween_property(reveal, "modulate:a", 1.0, 0.38)

	if night >= 4:
		for j in range(6):
			cinematic.tween_property(hotel_stage, "position:x", 10.0 if j % 2 == 0 else -10.0, 0.045)
		cinematic.tween_property(hotel_stage, "position:x", 0.0, 0.07)

	if night >= 5:
		cinematic.tween_property(lightning, "modulate:a", 0.80, 0.05)
		cinematic.tween_property(lightning, "modulate:a", 0.0, 0.12)
		cinematic.tween_property(self, "position:x", 14.0, 0.045)
		cinematic.tween_property(self, "position:x", -12.0, 0.045)
		cinematic.tween_property(self, "position:x", 8.0, 0.045)
		cinematic.tween_property(self, "position:x", 0.0, 0.05)

	if night >= 8:
		cinematic.tween_property(moon, "modulate", Color(0.55, 0.05, 0.08, 1.0), 0.45)
		var boss: Label = Label.new()
		boss.text = "♛\n👻"
		boss.position = Vector2(510, 115)
		boss.size = Vector2(260, 300)
		boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		boss.add_theme_font_size_override("font_size", 78)
		boss.add_theme_color_override("font_color", Color(0.12, 0.04, 0.10, 0.0))
		add_child(boss)
		cinematic.tween_property(boss, "modulate", Color(0.95, 0.12, 0.22, 0.92), 0.65)
		cinematic.tween_property(lightning, "modulate:a", 1.0, 0.05)
		cinematic.tween_property(lightning, "modulate:a", 0.0, 0.18)

	cinematic.tween_interval(1.45)
	cinematic.tween_property(self, "modulate:a", 0.0, 0.65)
	cinematic.tween_callback(_enter_night)

	var fog_tween: Tween = create_tween()
	fog_tween.set_loops()
	fog_tween.tween_property(fog_left, "position:x", 1040.0, 4.0)
	fog_tween.tween_callback(func() -> void:
		fog_left.position.x = -600.0
	)
	var fog_tween_two: Tween = create_tween()
	fog_tween_two.set_loops()
	fog_tween_two.tween_property(fog_right, "position:x", -1040.0, 4.7)
	fog_tween_two.tween_callback(func() -> void:
		fog_right.position.x = 1280.0
	)

func _play_ghost_howl() -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 2.0
	player.stream = generator
	player.volume_db = -14.0
	add_child(player)
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var frames: int = int(generator.mix_rate * 1.8)
	for i in range(frames):
		var time_value: float = float(i) / generator.mix_rate
		var envelope: float = sin(PI * minf(time_value / 1.8, 1.0))
		var frequency: float = 155.0 - 45.0 * time_value + 9.0 * sin(time_value * 5.0)
		var sample: float = sin(TAU * frequency * time_value) * envelope * 0.20
		sample += sin(TAU * frequency * 0.47 * time_value) * envelope * 0.07
		playback.push_frame(Vector2(sample, sample))

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
