extends Control

@onready var counter: Label = $Counter
@onready var message: Label = $Message
@onready var retry_button: Button = $RetryButton
@onready var flash: ColorRect = $Flash

const RELICS: Array[Dictionary] = [
	{"name":"Cursed Key","icon":"🗝","pos":Vector2(160, 245)},
	{"name":"Raven Feather","icon":"🪶","pos":Vector2(1010, 210)},
	{"name":"Cracked Doll","icon":"🪆","pos":Vector2(610, 505)},
	{"name":"Silver Bell","icon":"🔔","pos":Vector2(835, 360)},
	{"name":"Bone Candle","icon":"🕯","pos":Vector2(315, 425)},
	{"name":"Spider Amulet","icon":"🕷","pos":Vector2(1125, 500)},
	{"name":"Ghost Coin","icon":"◉","pos":Vector2(525, 300)},
	{"name":"Potion Vial","icon":"⚗","pos":Vector2(720, 210)},
	{"name":"Broken Watch","icon":"⌚","pos":Vector2(930, 520)},
	{"name":"Skull Flower","icon":"☠","pos":Vector2(430, 555)}
]

var found_count: int = 0
var found_names: Array[String] = []

func _ready() -> void:
	retry_button.pressed.connect(_on_retry)
	_build_graveyard()
	_spawn_relics()
	_start_fog()
	_play_ghost_howl()

func _build_graveyard() -> void:
	var ground: ColorRect = ColorRect.new()
	ground.position = Vector2(0, 540)
	ground.size = Vector2(1280, 180)
	ground.color = Color(0.025, 0.028, 0.027, 1)
	add_child(ground)
	move_child(ground, 2)

	for i in range(12):
		var stone: Label = Label.new()
		stone.text = "▰"
		stone.position = Vector2(45 + i * 103, 420 + (i % 4) * 34)
		stone.size = Vector2(70, 90)
		stone.add_theme_font_size_override("font_size", 54)
		stone.add_theme_color_override("font_color", Color(0.23, 0.25, 0.26, 0.92))
		add_child(stone)

	for i in range(5):
		var tree: Label = Label.new()
		tree.text = "╱╲╱╲\n ╲│╱\n  │"
		tree.position = Vector2(30 + i * 270, 230 + (i % 2) * 55)
		tree.size = Vector2(130, 220)
		tree.add_theme_font_size_override("font_size", 28)
		tree.add_theme_color_override("font_color", Color(0.08, 0.07, 0.08, 0.88))
		add_child(tree)

	for pos in [Vector2(0,120), Vector2(1070,100), Vector2(45,480)]:
		var web: Label = Label.new()
		web.text = "🕸"
		web.position = pos
		web.size = Vector2(180,140)
		web.add_theme_font_size_override("font_size", 74)
		web.modulate.a = 0.35
		add_child(web)

	for i in range(3):
		var ghost: Label = Label.new()
		ghost.text = "👻"
		ghost.position = Vector2(-120 - i * 300, 170 + i * 75)
		ghost.size = Vector2(90,90)
		ghost.add_theme_font_size_override("font_size", 42)
		ghost.modulate.a = 0.45
		add_child(ghost)
		var flight: Tween = create_tween()
		flight.set_loops()
		flight.tween_property(ghost, "position:x", 1380.0, 5.5 + i)
		flight.tween_callback(func() -> void: ghost.position.x = -120.0)

	for i in range(2):
		var zombie: Label = Label.new()
		zombie.text = "🧟"
		zombie.position = Vector2(-100 - i * 500, 545 + i * 35)
		zombie.size = Vector2(100,100)
		zombie.add_theme_font_size_override("font_size", 50)
		add_child(zombie)
		var walk: Tween = create_tween()
		walk.set_loops()
		walk.tween_property(zombie, "position:x", 1380.0, 10.0 + i * 2.0)
		walk.tween_callback(func() -> void: zombie.position.x = -100.0)

func _spawn_relics() -> void:
	for relic in RELICS:
		var button: Button = Button.new()
		button.text = str(relic["icon"])
		button.tooltip_text = "Something is hidden here..."
		button.position = relic["pos"]
		button.size = Vector2(58,58)
		button.flat = true
		button.modulate = Color(0.60,0.60,0.64,0.24)
		button.add_theme_font_size_override("font_size", 30)
		button.mouse_entered.connect(_on_relic_hover.bind(button))
		button.mouse_exited.connect(_on_relic_exit.bind(button))
		button.pressed.connect(_on_relic_found.bind(button, str(relic["name"])))
		add_child(button)

func _on_relic_hover(button: Button) -> void:
	if button.disabled:
		return
	button.modulate = Color(1,1,1,0.75)
	button.scale = Vector2(1.12,1.12)

func _on_relic_exit(button: Button) -> void:
	if button.disabled:
		return
	button.modulate = Color(0.60,0.60,0.64,0.24)
	button.scale = Vector2.ONE

func _on_relic_found(button: Button, relic_name: String) -> void:
	if button.disabled:
		return
	button.disabled = true
	button.modulate = Color(1.0,0.76,0.30,1.0)
	button.scale = Vector2(1.35,1.35)
	found_count += 1
	found_names.append(relic_name)
	counter.text = "RELICS  %d / 10" % found_count
	message.text = "FOUND: %s" % relic_name
	_flash_screen(0.16)
	if found_count in [3,6,9]:
		_spawn_jump_scare()
	if found_count >= RELICS.size():
		_complete_challenge()

func _complete_challenge() -> void:
	message.text = "THE GATE CREAKS OPEN... YOU MAY RETURN TO THE HOTEL."
	retry_button.disabled = false
	retry_button.text = "RETURN TO THE HOTEL"
	var pulse: Tween = create_tween()
	pulse.set_loops()
	pulse.tween_property(retry_button, "scale", Vector2(1.06,1.06), 0.45)
	pulse.tween_property(retry_button, "scale", Vector2.ONE, 0.45)

func _spawn_jump_scare() -> void:
	var apparition: Label = Label.new()
	apparition.text = "👻"
	apparition.position = Vector2(500,170)
	apparition.size = Vector2(280,280)
	apparition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apparition.add_theme_font_size_override("font_size", 150)
	apparition.modulate.a = 0.0
	add_child(apparition)
	var tween: Tween = create_tween()
	tween.tween_property(apparition, "modulate:a", 0.95, 0.07)
	tween.parallel().tween_property(apparition, "scale", Vector2(1.45,1.45), 0.12)
	tween.tween_property(apparition, "modulate:a", 0.0, 0.20)
	tween.tween_callback(apparition.queue_free)
	_flash_screen(0.42)
	_play_ghost_howl()

func _flash_screen(alpha: float) -> void:
	flash.modulate.a = alpha
	var tween: Tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.22)

func _start_fog() -> void:
	for i in range(4):
		var fog: Label = Label.new()
		fog.text = "☁    ☁    ☁"
		fog.position = Vector2(-500 - i * 360, 500 + (i % 2) * 65)
		fog.size = Vector2(700,130)
		fog.add_theme_font_size_override("font_size", 52)
		fog.add_theme_color_override("font_color", Color(0.65,0.68,0.72,0.20))
		add_child(fog)
		var drift: Tween = create_tween()
		drift.set_loops()
		drift.tween_property(fog, "position:x", 1400.0, 6.0 + i * 0.8)
		drift.tween_callback(func() -> void: fog.position.x = -500.0)

func _play_ghost_howl() -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 2.0
	player.stream = generator
	player.volume_db = -12.0
	add_child(player)
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var frames: int = int(generator.mix_rate * 1.6)
	for i in range(frames):
		var t: float = float(i) / generator.mix_rate
		var envelope: float = sin(PI * minf(t / 1.6, 1.0))
		var frequency: float = 170.0 - 55.0 * t + 12.0 * sin(t * 4.0)
		var sample: float = sin(TAU * frequency * t) * envelope * 0.22
		sample += sin(TAU * (frequency * 0.51) * t) * envelope * 0.08
		playback.push_frame(Vector2(sample, sample))

func _on_retry() -> void:
	if found_count < RELICS.size():
		return
	get_tree().change_scene_to_file("res://main.tscn")
