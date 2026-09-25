extends Control

@onready var counter: Label = $Counter
@onready var message: Label = $Message
@onready var retry_button: Button = $RetryButton
@onready var flash: ColorRect = $Flash
@onready var timer_label: Label = $Timer
@onready var level_label: Label = $Level

const ITEM_POOLS: Array[Array] = [
	[
		{"name":"Rusty Gate Key","icon":"🗝"},
		{"name":"Raven Feather","icon":"🪶"},
		{"name":"Silver Bell","icon":"🔔"},
		{"name":"Wax Candle","icon":"🕯"},
		{"name":"Ghost Coin","icon":"◉"},
		{"name":"Broken Watch","icon":"⌚"},
		{"name":"Black Rose","icon":"✿"},
		{"name":"Old Locket","icon":"◈"},
		{"name":"Bone Charm","icon":"☠"},
		{"name":"Potion Vial","icon":"⚗"}
	],
	[
		{"name":"Cracked Porcelain Eye","icon":"◉"},
		{"name":"Undertaker's Ring","icon":"◌"},
		{"name":"Gravedigger Token","icon":"◆"},
		{"name":"Moth Wing","icon":"🦋"},
		{"name":"Spider Amulet","icon":"🕷"},
		{"name":"Funeral Ribbon","icon":"🎗"},
		{"name":"Coffin Nail","icon":"†"},
		{"name":"Moon Shard","icon":"☽"},
		{"name":"Ashen Rose","icon":"✾"},
		{"name":"Widow's Brooch","icon":"✦"}
	],
	[
		{"name":"Phantom Lantern","icon":"🏮"},
		{"name":"Witch Bottle","icon":"⚗"},
		{"name":"Crypt Seal","icon":"⬟"},
		{"name":"Blood Moon Coin","icon":"●"},
		{"name":"Lost Doll","icon":"🪆"},
		{"name":"Ritual Feather","icon":"🪶"},
		{"name":"Mourning Bell","icon":"🔔"},
		{"name":"Spectral Key","icon":"🗝"},
		{"name":"Grave Orchid","icon":"❀"},
		{"name":"Hourglass of Dust","icon":"⌛"}
	],
	[
		{"name":"Eclipse Talisman","icon":"☀"},
		{"name":"Royal Death Mask","icon":"♛"},
		{"name":"Wraith Compass","icon":"✥"},
		{"name":"Cursed Mirror Shard","icon":"◇"},
		{"name":"Black Candle","icon":"🕯"},
		{"name":"Seance Crystal","icon":"◆"},
		{"name":"Umbra Sigil","icon":"✺"},
		{"name":"Lost Soul Vial","icon":"⚗"},
		{"name":"Ancient Grave Key","icon":"🗝"},
		{"name":"Whispering Skull","icon":"☠"}
	]
]

const HIDING_SPOTS: Array[Vector2] = [
	Vector2(105,215), Vector2(205,515), Vector2(318,330), Vector2(410,565),
	Vector2(515,245), Vector2(610,485), Vector2(705,315), Vector2(810,535),
	Vector2(905,255), Vector2(1005,445), Vector2(1115,320), Vector2(1180,555),
	Vector2(255,395), Vector2(470,445), Vector2(745,580), Vector2(935,385),
	Vector2(1085,205), Vector2(585,600), Vector2(355,255), Vector2(845,205)
]

const DECOY_ICONS: Array[String] = ["✚","✧","●","◆","☾","†","♠","♣","◌","✦","⚰","🦴"]

var found_count: int = 0
var required_count: int = 10
var graveyard_level: int = 1
var time_left: float = 90.0
var challenge_complete: bool = false
var active_relics: Array[Button] = []

func _ready() -> void:
	graveyard_level = clampi(int(GameState.last_night_summary.get("night", GameState.current_night)), 1, 8)
	required_count = 10
	time_left = _time_limit_for_level(graveyard_level)
	level_label.text = "GRAVEYARD LEVEL %d  •  %s" % [graveyard_level, _difficulty_name(graveyard_level)]
	retry_button.pressed.connect(_on_retry)
	_build_real_graveyard()
	_spawn_level_relics()
	_spawn_decoys()
	_start_fog()
	_play_ghost_howl()
	counter.text = "RELICS  0 / %d" % required_count

func _process(delta: float) -> void:
	if challenge_complete:
		return
	time_left = maxf(0.0, time_left - delta)
	timer_label.text = "TIME  %02d" % int(ceil(time_left))
	if time_left <= 15.0:
		timer_label.modulate = Color(1.0,0.28,0.22,1.0)
	if time_left <= 0.0:
		_reset_search_after_timeout()

func _time_limit_for_level(level: int) -> float:
	return maxf(38.0, 92.0 - float(level - 1) * 7.0)

func _difficulty_name(level: int) -> String:
	if level <= 2:
		return "RESTLESS SOIL"
	if level <= 4:
		return "WHISPERING CRYPTS"
	if level <= 6:
		return "CURSED GROUNDS"
	return "ECLIPSE CEMETERY"

func _item_pool_for_level(level: int) -> Array:
	var index: int = clampi((level - 1) / 2, 0, ITEM_POOLS.size() - 1)
	return ITEM_POOLS[index].duplicate(true)

func _build_real_graveyard() -> void:
	var gate_left: Label = Label.new()
	gate_left.text = "╔╦╦╦╦╗\n║║║║║║\n║║║║║║"
	gate_left.position = Vector2(-8,360)
	gate_left.size = Vector2(180,220)
	gate_left.add_theme_font_size_override("font_size", 30)
	gate_left.add_theme_color_override("font_color", Color(0.10,0.10,0.12,0.95))
	add_child(gate_left)

	var gate_right: Label = Label.new()
	gate_right.text = "╔╦╦╦╦╗\n║║║║║║\n║║║║║║"
	gate_right.position = Vector2(1110,360)
	gate_right.size = Vector2(180,220)
	gate_right.add_theme_font_size_override("font_size", 30)
	gate_right.add_theme_color_override("font_color", Color(0.10,0.10,0.12,0.95))
	add_child(gate_right)

	var crypt: ColorRect = ColorRect.new()
	crypt.position = Vector2(520,330)
	crypt.size = Vector2(250,190)
	crypt.color = Color(0.11,0.115,0.12,0.86)
	add_child(crypt)
	var crypt_roof: Polygon2D = Polygon2D.new()
	crypt_roof.polygon = PackedVector2Array([Vector2(495,335),Vector2(645,235),Vector2(795,335)])
	crypt_roof.color = Color(0.075,0.075,0.085,0.95)
	add_child(crypt_roof)
	var crypt_door: ColorRect = ColorRect.new()
	crypt_door.position = Vector2(600,405)
	crypt_door.size = Vector2(90,115)
	crypt_door.color = Color(0.025,0.025,0.035,0.96)
	add_child(crypt_door)

	for i in range(17):
		var stone: Label = Label.new()
		stone.text = "▰"
		stone.position = Vector2(38 + (i * 71) % 1180, 395 + (i % 5) * 45)
		stone.size = Vector2(62,82)
		stone.rotation = deg_to_rad(float((i % 5) - 2) * 2.5)
		stone.add_theme_font_size_override("font_size", 50 - (i % 3) * 4)
		stone.add_theme_color_override("font_color", Color(0.20,0.22,0.23,0.90))
		add_child(stone)

	for i in range(6):
		var tree: Label = Label.new()
		tree.text = "╲  │  ╱\n ╲ │ ╱\n───│───\n  ╱│╲\n   │"
		tree.position = Vector2(10 + i * 235, 180 + (i % 2) * 75)
		tree.size = Vector2(160,310)
		tree.add_theme_font_size_override("font_size", 24)
		tree.add_theme_color_override("font_color", Color(0.055,0.045,0.05,0.92))
		add_child(tree)

	for pos in [Vector2(5,130),Vector2(1080,130),Vector2(60,455),Vector2(1040,450)]:
		var web: Label = Label.new()
		web.text = "🕸"
		web.position = pos
		web.size = Vector2(180,145)
		web.add_theme_font_size_override("font_size", 76)
		web.modulate.a = 0.30
		add_child(web)

	for i in range(2 + mini(graveyard_level / 2, 3)):
		var zombie: Label = Label.new()
		zombie.text = "🧟"
		zombie.position = Vector2(-110 - i * 310, 545 + (i % 2) * 35)
		zombie.size = Vector2(100,100)
		zombie.add_theme_font_size_override("font_size", 48)
		zombie.modulate.a = 0.86
		add_child(zombie)
		var walk: Tween = create_tween()
		walk.set_loops()
		walk.tween_property(zombie, "position:x", 1380.0, maxf(5.8, 10.0 - graveyard_level * 0.45) + i)
		walk.tween_callback(func() -> void: zombie.position.x = -110.0)

	for i in range(2 + mini(graveyard_level, 5)):
		var ghost: Label = Label.new()
		ghost.text = "👻"
		ghost.position = Vector2(-120 - i * 210, 155 + (i % 4) * 70)
		ghost.size = Vector2(80,80)
		ghost.add_theme_font_size_override("font_size", 38)
		ghost.modulate.a = 0.38
		add_child(ghost)
		var flight: Tween = create_tween()
		flight.set_loops()
		flight.tween_property(ghost, "position", Vector2(1380,ghost.position.y - 35), 5.0 + i * 0.55)
		flight.tween_callback(func() -> void: ghost.position.x = -120.0)

func _spawn_level_relics() -> void:
	var pool: Array = _item_pool_for_level(graveyard_level)
	pool.shuffle()
	var spots: Array[Vector2] = HIDING_SPOTS.duplicate()
	spots.shuffle()
	var target_alpha: float = maxf(0.13, 0.40 - float(graveyard_level - 1) * 0.035)
	var target_size: float = maxf(36.0, 58.0 - float(graveyard_level - 1) * 2.5)

	for i in range(required_count):
		var relic: Dictionary = pool[i % pool.size()]
		var button: Button = Button.new()
		button.text = str(relic.get("icon","?"))
		button.tooltip_text = "Something doesn't belong here..."
		button.position = spots[i]
		button.size = Vector2(target_size,target_size)
		button.flat = true
		button.modulate = Color(0.67,0.67,0.70,target_alpha)
		button.add_theme_font_size_override("font_size", int(target_size * 0.52))
		button.mouse_entered.connect(_on_relic_hover.bind(button))
		button.mouse_exited.connect(_on_relic_exit.bind(button))
		button.pressed.connect(_on_relic_found.bind(button,str(relic.get("name","Unknown Relic"))))
		add_child(button)
		active_relics.append(button)

		if graveyard_level >= 3 and i % 3 == 0:
			var creep: Tween = create_tween()
			creep.set_loops()
			var start_x: float = button.position.x
			creep.tween_property(button,"position:x",start_x + 24.0,1.5 + i * 0.04).set_trans(Tween.TRANS_SINE)
			creep.tween_property(button,"position:x",start_x,1.5 + i * 0.04).set_trans(Tween.TRANS_SINE)

		if graveyard_level >= 6 and i % 4 == 1:
			var blink: Tween = create_tween()
			blink.set_loops()
			blink.tween_property(button,"modulate:a",0.06,0.8)
			blink.tween_property(button,"modulate:a",target_alpha,0.8)

func _spawn_decoys() -> void:
	var count: int = 3 + graveyard_level * 2
	for i in range(count):
		var decoy: Button = Button.new()
		decoy.text = DECOY_ICONS[i % DECOY_ICONS.size()]
		decoy.position = HIDING_SPOTS[(i * 3 + graveyard_level) % HIDING_SPOTS.size()] + Vector2((i % 3) * 22,-18 + (i % 2) * 30)
		decoy.size = Vector2(42,42)
		decoy.flat = true
		decoy.modulate = Color(0.55,0.56,0.58,0.17)
		decoy.add_theme_font_size_override("font_size",22)
		decoy.pressed.connect(_on_decoy_pressed.bind(decoy))
		add_child(decoy)

func _on_decoy_pressed(decoy: Button) -> void:
	if challenge_complete:
		return
	message.text = "A FALSE RELIC! The graveyard steals 3 seconds."
	time_left = maxf(0.0,time_left - 3.0)
	decoy.disabled = true
	decoy.modulate = Color(0.55,0.08,0.08,0.55)
	_flash_screen(0.22)
	if graveyard_level >= 4:
		_spawn_jump_scare()

func _on_relic_hover(button: Button) -> void:
	if button.disabled:
		return
	button.modulate.a = minf(0.78,button.modulate.a + 0.33)
	button.scale = Vector2(1.12,1.12)

func _on_relic_exit(button: Button) -> void:
	if button.disabled:
		return
	var target_alpha: float = maxf(0.13,0.40 - float(graveyard_level - 1) * 0.035)
	button.modulate.a = target_alpha
	button.scale = Vector2.ONE

func _on_relic_found(button: Button,relic_name: String) -> void:
	if button.disabled or challenge_complete:
		return
	button.disabled = true
	button.modulate = Color(1.0,0.76,0.30,1.0)
	button.scale = Vector2(1.35,1.35)
	found_count += 1
	counter.text = "RELICS  %d / %d" % [found_count,required_count]
	message.text = "FOUND: %s" % relic_name
	time_left += 2.0
	_flash_screen(0.14)
	if found_count in [3,6,9]:
		_spawn_jump_scare()
	if found_count >= required_count:
		_complete_challenge()

func _reset_search_after_timeout() -> void:
	message.text = "THE BELL TOLLS. THE RELICS HAVE SHIFTED..."
	_play_ghost_howl()
	_flash_screen(0.65)
	time_left = _time_limit_for_level(graveyard_level)
	for button in active_relics:
		if not button.disabled:
			button.position = HIDING_SPOTS[randi() % HIDING_SPOTS.size()] + Vector2(randi_range(-24,24),randi_range(-18,18))

func _complete_challenge() -> void:
	challenge_complete = true
	timer_label.text = "ESCAPED"
	message.text = "THE IRON GATE CREAKS OPEN... YOU MAY RETURN TO THE HOTEL."
	retry_button.disabled = false
	retry_button.text = "RETURN TO THE HOTEL"
	var pulse: Tween = create_tween()
	pulse.set_loops()
	pulse.tween_property(retry_button,"scale",Vector2(1.06,1.06),0.45)
	pulse.tween_property(retry_button,"scale",Vector2.ONE,0.45)

func _spawn_jump_scare() -> void:
	var apparition: Label = Label.new()
	apparition.text = "👻"
	apparition.position = Vector2(500,150)
	apparition.size = Vector2(280,300)
	apparition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apparition.add_theme_font_size_override("font_size",160)
	apparition.modulate.a = 0.0
	add_child(apparition)
	var tween: Tween = create_tween()
	tween.tween_property(apparition,"modulate:a",0.96,0.06)
	tween.parallel().tween_property(apparition,"scale",Vector2(1.55,1.55),0.11)
	tween.tween_property(apparition,"modulate:a",0.0,0.18)
	tween.tween_callback(apparition.queue_free)
	_flash_screen(0.38)
	_play_ghost_howl()

func _flash_screen(alpha: float) -> void:
	flash.modulate.a = alpha
	var tween: Tween = create_tween()
	tween.tween_property(flash,"modulate:a",0.0,0.20)

func _start_fog() -> void:
	for i in range(5):
		var fog: Label = Label.new()
		fog.text = "☁      ☁      ☁"
		fog.position = Vector2(-650 - i * 330,455 + (i % 3) * 70)
		fog.size = Vector2(850,150)
		fog.add_theme_font_size_override("font_size",58)
		fog.add_theme_color_override("font_color",Color(0.68,0.72,0.78,0.20))
		add_child(fog)
		var drift: Tween = create_tween()
		drift.set_loops()
		drift.tween_property(fog,"position:x",1400.0,maxf(4.5,7.2 - graveyard_level * 0.25) + i * 0.35)
		drift.tween_callback(func() -> void: fog.position.x = -650.0)

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
		var time_value: float = float(i) / generator.mix_rate
		var envelope: float = sin(PI * minf(time_value / 1.6,1.0))
		var frequency: float = 170.0 - 55.0 * time_value + 12.0 * sin(time_value * 4.0)
		var sample: float = sin(TAU * frequency * time_value) * envelope * 0.22
		sample += sin(TAU * frequency * 0.51 * time_value) * envelope * 0.08
		playback.push_frame(Vector2(sample,sample))

func _on_retry() -> void:
	if not challenge_complete:
		return
	get_tree().change_scene_to_file("res://main.tscn")
