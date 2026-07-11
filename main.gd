extends Control


# =========================================================
# CONSTANTS
# =========================================================

const SAVE_PATH := "user://tiny_ghost_hotel_save.json"

const STARTING_LIVES := 3
const MAX_ROUNDS := 10
const DEFAULT_PATIENCE := 8.0

const CORRECT_WAIT_TIME := 1.15
const WRONG_WAIT_TIME := 1.35


# =========================================================
# GAME STATE
# =========================================================

var score: int = 0
var high_score: int = 0
var lives: int = STARTING_LIVES
var streak: int = 0
var best_streak: int = 0

var current_round: int = 0
var current_ghost: Dictionary = {}
var ghost_pool: Array[Dictionary] = []

var game_started: bool = false
var round_active: bool = false
var transition_running: bool = false
var entering_hotel: bool = false

var round_time: float = DEFAULT_PATIENCE
var time_remaining: float = DEFAULT_PATIENCE

var ghost_float_tween: Tween
var menu_ghost_tween: Tween
var moon_tween: Tween
var hotel_tween: Tween
var title_tween: Tween


# =========================================================
# BACKGROUND AND DECORATION NODES
# =========================================================

@onready var night_background: ColorRect = $NightBackground
@onready var hotel_background: TextureRect = $HotelBackground
@onready var background_tint: ColorRect = $BackgroundTint

@onready var moon_label: Label = $MoonLabel
@onready var hotel_silhouette: Label = $HotelSilhouette
@onready var floating_ghost: Label = $FloatingGhost


# =========================================================
# LABEL NODES
# =========================================================

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var round_label: Label = $RoundLabel

@onready var request_label: Label = $RequestLabel
@onready var message_label: Label = $MessageLabel
@onready var ghost_label: Label = $GhostLabel
@onready var rooms_label: Label = $RoomsLabel


# =========================================================
# BUTTON NODES
# =========================================================

@onready var cold_button: Button = $ColdRoomButton
@onready var dark_button: Button = $DarkRoomButton
@onready var music_button: Button = $MusicRoomButton

@onready var restart_button: Button = $RestartButton
@onready var start_button: Button = $StartButton
@onready var get_ready_button: Button = $GetReadyButton
@onready var quit_button: Button = $QuitButton

@onready var menu_panel: Panel = $MenuPanel


# =========================================================
# AUDIO NODES
# =========================================================

@onready var correct_sound: AudioStreamPlayer2D = $CorrectSound
@onready var wrong_sound: AudioStreamPlayer2D = $WrongSound
@onready var game_over_sound: AudioStreamPlayer2D = $GameOverSound


# =========================================================
# GHOST DATA
# =========================================================

var ghosts: Array[Dictionary] = [
	{
		"name": "Frosty",
		"preference": "cold",
		"intro": "loves icy breezes",
		"mood": "Shivering",
		"personality": "Polite",
		"patience": 9.0,
		"base_points": 1,
		"vip": false,
		"icon": "❄️👻"
	},
	{
		"name": "Shade",
		"preference": "dark",
		"intro": "hates bright lights",
		"mood": "Nervous",
		"personality": "Quiet",
		"patience": 7.0,
		"base_points": 1,
		"vip": false,
		"icon": "🌑👻"
	},
	{
		"name": "Melody",
		"preference": "music",
		"intro": "sleeps to lullabies",
		"mood": "Cheerful",
		"personality": "Musical",
		"patience": 8.0,
		"base_points": 1,
		"vip": false,
		"icon": "🎵👻"
	},
	{
		"name": "Echo",
		"preference": "dark",
		"intro": "whispers from the hallway",
		"mood": "Mysterious",
		"personality": "Secretive",
		"patience": 7.0,
		"base_points": 1,
		"vip": false,
		"icon": "🌘👻"
	},
	{
		"name": "Misty",
		"preference": "cold",
		"intro": "drifts like winter fog",
		"mood": "Sleepy",
		"personality": "Gentle",
		"patience": 10.0,
		"base_points": 1,
		"vip": false,
		"icon": "🌨️👻"
	},
	{
		"name": "Velvet",
		"preference": "music",
		"intro": "adores soft piano music",
		"mood": "Relaxed",
		"personality": "Artistic",
		"patience": 10.0,
		"base_points": 1,
		"vip": false,
		"icon": "🎹👻"
	},
	{
		"name": "Lord Nocturne",
		"preference": "dark",
		"intro": "demands complete darkness",
		"mood": "Impatient",
		"personality": "Royal",
		"patience": 5.0,
		"base_points": 2,
		"vip": true,
		"icon": "👑🌙👻"
	},
	{
		"name": "Lady Glimmer",
		"preference": "cold",
		"intro": "sparkles like frozen starlight",
		"mood": "Elegant",
		"personality": "Royal",
		"patience": 6.0,
		"base_points": 2,
		"vip": true,
		"icon": "✨❄️👻"
	},
	{
		"name": "Wisp",
		"preference": "music",
		"intro": "hums a floating tune",
		"mood": "Playful",
		"personality": "Curious",
		"patience": 8.0,
		"base_points": 1,
		"vip": false,
		"icon": "🎶👻"
	}
]


# =========================================================
# INITIAL SETUP
# =========================================================

func _ready() -> void:
	randomize()

	load_high_score()
	setup_mouse_filters()
	setup_button_text()
	connect_buttons()
	setup_button_animations()

	show_title_screen()


func setup_mouse_filters() -> void:
	night_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotel_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE

	moon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotel_silhouette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floating_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	get_ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP

	cold_button.mouse_filter = Control.MOUSE_FILTER_STOP
	dark_button.mouse_filter = Control.MOUSE_FILTER_STOP
	music_button.mouse_filter = Control.MOUSE_FILTER_STOP


func setup_button_text() -> void:
	start_button.text = "ENTER HOTEL"
	get_ready_button.text = "BEGIN NIGHT"
	quit_button.text = "QUIT HOTEL"
	restart_button.text = "PLAY AGAIN"

	cold_button.text = "❄ Cold Room\nQuiet and chilly"
	dark_button.text = "🌑 Dark Room\nDim and restful"
	music_button.text = "🎵 Music Room\nSoft spooky tunes"


func connect_buttons() -> void:
	connect_button(start_button, _on_start_button_pressed)
	connect_button(get_ready_button, _on_get_ready_button_pressed)
	connect_button(quit_button, _on_quit_button_pressed)
	connect_button(restart_button, _on_restart_button_pressed)

	connect_button(cold_button, _on_cold_room_pressed)
	connect_button(dark_button, _on_dark_room_pressed)
	connect_button(music_button, _on_music_room_pressed)


func connect_button(button: Button, callback: Callable) -> void:
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func setup_button_animations() -> void:
	var buttons: Array[Button] = [
		start_button,
		get_ready_button,
		quit_button,
		restart_button,
		cold_button,
		dark_button,
		music_button
	]

	for button in buttons:
		if not button.mouse_entered.is_connected(
			_on_button_mouse_entered.bind(button)
		):
			button.mouse_entered.connect(
				_on_button_mouse_entered.bind(button)
			)

		if not button.mouse_exited.is_connected(
			_on_button_mouse_exited.bind(button)
		):
			button.mouse_exited.connect(
				_on_button_mouse_exited.bind(button)
			)


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:
	if not game_started:
		return

	if not round_active:
		return

	if transition_running:
		return

	time_remaining -= delta
	time_remaining = maxf(time_remaining, 0.0)

	# Shows the remaining patience in the message.
	if time_remaining <= 3.0:
		message_label.text = "Hurry! %.1f seconds remaining!" % time_remaining

	if time_remaining <= 0.0:
		round_active = false
		handle_timeout()


# =========================================================
# TITLE SCREEN
# =========================================================

func show_title_screen() -> void:
	game_started = false
	round_active = false
	transition_running = false
	entering_hotel = false

	stop_game_ghost_animation()
	reset_title_screen_transforms()

	night_background.visible = true
	hotel_background.visible = true
	background_tint.visible = true

	moon_label.visible = true
	hotel_silhouette.visible = true
	floating_ghost.visible = true

	title_label.visible = true
	title_label.text = "TINY GHOST HOTEL"

	subtitle_label.visible = true
	subtitle_label.text = (
		"The night shift is about to begin...\n"
		+ "High Score: %d"
	) % high_score

	menu_panel.visible = true
	start_button.visible = true
	get_ready_button.visible = false
	quit_button.visible = true

	score_label.visible = false
	lives_label.visible = false
	round_label.visible = false

	request_label.visible = false
	message_label.visible = false
	ghost_label.visible = false
	rooms_label.visible = false

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false
	restart_button.visible = false

	start_button.disabled = false
	quit_button.disabled = false

	start_haunted_menu_animations()


func reset_title_screen_transforms() -> void:
	hotel_background.scale = Vector2.ONE
	hotel_silhouette.scale = Vector2.ONE
	floating_ghost.scale = Vector2.ONE
	floating_ghost.rotation = 0.0
	moon_label.scale = Vector2.ONE

	title_label.modulate = Color.WHITE
	subtitle_label.modulate = Color.WHITE
	menu_panel.modulate = Color.WHITE
	start_button.modulate = Color.WHITE
	quit_button.modulate = Color.WHITE
	floating_ghost.modulate = Color.WHITE
	hotel_silhouette.modulate = Color(0.5, 0.4, 0.8, 0.55)
	background_tint.modulate = Color.WHITE


func start_haunted_menu_animations() -> void:
	stop_menu_animations()

	animate_menu_ghost()
	animate_moon()
	animate_hotel()
	animate_title_entrance()


func animate_menu_ghost() -> void:
	await get_tree().process_frame

	if not floating_ghost.visible:
		return

	floating_ghost.pivot_offset = floating_ghost.size / 2.0
	var original_y := floating_ghost.position.y

	menu_ghost_tween = create_tween()
	menu_ghost_tween.set_loops()

	menu_ghost_tween.tween_property(
		floating_ghost,
		"position:y",
		original_y - 22.0,
		1.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	menu_ghost_tween.parallel().tween_property(
		floating_ghost,
		"rotation",
		deg_to_rad(-5.0),
		1.4
	)

	menu_ghost_tween.tween_property(
		floating_ghost,
		"position:y",
		original_y + 22.0,
		1.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	menu_ghost_tween.parallel().tween_property(
		floating_ghost,
		"rotation",
		deg_to_rad(5.0),
		1.4
	)


func animate_moon() -> void:
	await get_tree().process_frame

	moon_label.pivot_offset = moon_label.size / 2.0

	moon_tween = create_tween()
	moon_tween.set_loops()

	moon_tween.tween_property(
		moon_label,
		"scale",
		Vector2(1.08, 1.08),
		1.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	moon_tween.parallel().tween_property(
		moon_label,
		"modulate:a",
		0.72,
		1.8
	)

	moon_tween.tween_property(
		moon_label,
		"scale",
		Vector2.ONE,
		1.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	moon_tween.parallel().tween_property(
		moon_label,
		"modulate:a",
		1.0,
		1.8
	)


func animate_hotel() -> void:
	await get_tree().process_frame

	hotel_silhouette.pivot_offset = hotel_silhouette.size / 2.0

	hotel_tween = create_tween()
	hotel_tween.set_loops()

	hotel_tween.tween_property(
		hotel_silhouette,
		"modulate:a",
		0.78,
		1.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	hotel_tween.parallel().tween_property(
		hotel_silhouette,
		"scale",
		Vector2(1.025, 1.025),
		1.5
	)

	hotel_tween.tween_property(
		hotel_silhouette,
		"modulate:a",
		0.48,
		1.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	hotel_tween.parallel().tween_property(
		hotel_silhouette,
		"scale",
		Vector2.ONE,
		1.5
	)


func animate_title_entrance() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0

	title_label.scale = Vector2(0.75, 0.75)

	await get_tree().process_frame
	title_label.pivot_offset = title_label.size / 2.0

	title_tween = create_tween()
	title_tween.set_parallel(true)

	title_tween.tween_property(
		title_label,
		"modulate:a",
		1.0,
		0.7
	)

	title_tween.tween_property(
		title_label,
		"scale",
		Vector2.ONE,
		0.7
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	title_tween.tween_property(
		subtitle_label,
		"modulate:a",
		1.0,
		0.9
	)

	title_tween.tween_property(
		menu_panel,
		"modulate:a",
		1.0,
		0.9
	)


func stop_menu_animations() -> void:
	if menu_ghost_tween:
		menu_ghost_tween.kill()
		menu_ghost_tween = null

	if moon_tween:
		moon_tween.kill()
		moon_tween = null

	if hotel_tween:
		hotel_tween.kill()
		hotel_tween = null

	if title_tween:
		title_tween.kill()
		title_tween = null


# =========================================================
# ENTER-HOTEL TRANSITION
# =========================================================

func enter_hotel_animation() -> void:
	if entering_hotel:
		return

	entering_hotel = true
	transition_running = true

	start_button.disabled = true
	quit_button.disabled = true

	stop_menu_animations()

	var fade_tween := create_tween()
	fade_tween.set_parallel(true)

	fade_tween.tween_property(
		title_label,
		"modulate:a",
		0.0,
		0.4
	)

	fade_tween.tween_property(
		subtitle_label,
		"modulate:a",
		0.0,
		0.4
	)

	fade_tween.tween_property(
		menu_panel,
		"modulate:a",
		0.0,
		0.4
	)

	fade_tween.tween_property(
		start_button,
		"modulate:a",
		0.0,
		0.4
	)

	fade_tween.tween_property(
		quit_button,
		"modulate:a",
		0.0,
		0.4
	)

	fade_tween.tween_property(
		floating_ghost,
		"modulate:a",
		0.0,
		0.4
	)

	await fade_tween.finished

	await get_tree().process_frame

	hotel_silhouette.pivot_offset = hotel_silhouette.size / 2.0
	hotel_background.pivot_offset = hotel_background.size / 2.0

	var zoom_tween := create_tween()
	zoom_tween.set_parallel(true)

	zoom_tween.tween_property(
		hotel_silhouette,
		"scale",
		Vector2(2.25, 2.25),
		1.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		hotel_background,
		"scale",
		Vector2(1.35, 1.35),
		1.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		moon_label,
		"modulate:a",
		0.0,
		0.8
	)

	zoom_tween.tween_property(
		background_tint,
		"modulate",
		Color(0.05, 0.01, 0.08, 1.0),
		1.25
	)

	await zoom_tween.finished

	await flash_transition()

	show_ready_screen()

	entering_hotel = false
	transition_running = false


func flash_transition() -> void:
	background_tint.color = Color(0.0, 0.0, 0.0, 1.0)
	background_tint.modulate.a = 0.0

	var tween := create_tween()

	tween.tween_property(
		background_tint,
		"modulate:a",
		1.0,
		0.3
	)

	await tween.finished

	await get_tree().create_timer(0.15).timeout


# =========================================================
# READY SCREEN
# =========================================================

func show_ready_screen() -> void:
	stop_menu_animations()

	hotel_background.visible = true
	night_background.visible = true
	background_tint.visible = true

	moon_label.visible = false
	hotel_silhouette.visible = false
	floating_ghost.visible = false

	title_label.visible = true
	title_label.text = "WELCOME TO THE LOBBY"
	title_label.modulate = Color.WHITE
	title_label.scale = Vector2.ONE

	subtitle_label.visible = true
	subtitle_label.text = "Your first guests are waiting..."
	subtitle_label.modulate = Color.WHITE

	menu_panel.visible = true
	menu_panel.modulate = Color.WHITE

	start_button.visible = false
	get_ready_button.visible = true
	quit_button.visible = true

	get_ready_button.modulate = Color.WHITE
	quit_button.modulate = Color.WHITE
	get_ready_button.disabled = false
	quit_button.disabled = false

	score_label.visible = false
	lives_label.visible = false
	round_label.visible = false

	request_label.visible = true
	request_label.text = "HOW TO PLAY"

	message_label.visible = true
	message_label.text = (
		"Read each ghost's request.\n"
		+ "Choose the Cold, Dark or Music room.\n"
		+ "Wrong answers cost one life.\n"
		+ "VIP guests give bonus points."
	)

	ghost_label.visible = true
	ghost_label.text = "🛎️ 👻"
	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE

	rooms_label.visible = false

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false
	restart_button.visible = false

	background_tint.color = Color(0.08, 0.025, 0.18, 0.5)
	background_tint.modulate = Color.WHITE

	animate_ready_screen()


func animate_ready_screen() -> void:
	request_label.modulate.a = 0.0
	message_label.modulate.a = 0.0
	ghost_label.modulate.a = 0.0
	ghost_label.scale = Vector2(0.4, 0.4)

	await get_tree().process_frame
	ghost_label.pivot_offset = ghost_label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		request_label,
		"modulate:a",
		1.0,
		0.5
	)

	tween.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.7
	)

	tween.tween_property(
		ghost_label,
		"modulate:a",
		1.0,
		0.6
	)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.6
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# =========================================================
# GAME SETUP
# =========================================================

func reset_game_data() -> void:
	score = 0
	lives = STARTING_LIVES
	streak = 0
	best_streak = 0

	current_round = 0
	current_ghost = {}

	ghost_pool = ghosts.duplicate(true)
	ghost_pool.shuffle()

	round_active = false
	transition_running = false


func start_game() -> void:
	reset_game_data()

	game_started = true
	round_active = false

	show_game_ui()

	update_score_label()
	update_lives_label()
	update_round_label()

	spawn_new_ghost()


func show_game_ui() -> void:
	stop_menu_animations()

	moon_label.visible = false
	hotel_silhouette.visible = false
	floating_ghost.visible = false

	menu_panel.visible = false
	start_button.visible = false
	get_ready_button.visible = false
	quit_button.visible = false

	title_label.visible = true
	title_label.text = "TINY GHOST HOTEL"

	subtitle_label.visible = false

	score_label.visible = true
	lives_label.visible = true
	round_label.visible = true

	request_label.visible = true
	message_label.visible = true
	ghost_label.visible = true
	rooms_label.visible = true

	cold_button.visible = true
	dark_button.visible = true
	music_button.visible = true

	restart_button.visible = false

	background_tint.color = Color(0.04, 0.01, 0.1, 0.35)
	background_tint.modulate = Color.WHITE


# =========================================================
# HUD UPDATES
# =========================================================

func update_score_label() -> void:
	score_label.text = "Score: %d | Streak: %d" % [
		score,
		streak
	]


func update_lives_label() -> void:
	var hearts := ""

	for i in range(lives):
		hearts += "❤ "

	if hearts.is_empty():
		hearts = "None"

	lives_label.text = "Lives: %s" % hearts.strip_edges()


func update_round_label() -> void:
	round_label.text = "Round %d/%d" % [
		current_round,
		MAX_ROUNDS
	]


# =========================================================
# GHOST SPAWNING
# =========================================================

func refill_ghost_pool_if_needed() -> void:
	if ghost_pool.is_empty():
		ghost_pool = ghosts.duplicate(true)
		ghost_pool.shuffle()


func spawn_new_ghost() -> void:
	if lives <= 0:
		end_game_lost()
		return

	if current_round >= MAX_ROUNDS:
		end_game_won()
		return

	refill_ghost_pool_if_needed()

	current_round += 1
	current_ghost = ghost_pool.pop_back()

	update_round_label()

	var ghost_name := str(
		current_ghost.get("name", "Unknown Ghost")
	)

	var ghost_intro := str(
		current_ghost.get("intro", "floats silently")
	)

	var mood := str(
		current_ghost.get("mood", "Mysterious")
	)

	var personality := str(
		current_ghost.get("personality", "Unknown")
	)

	var is_vip := bool(
		current_ghost.get("vip", false)
	)

	if is_vip:
		request_label.text = (
			"★ VIP GUEST ★\n"
			+ "%s arrives and %s."
		) % [ghost_name, ghost_intro]
	else:
		request_label.text = "%s arrives and %s." % [
			ghost_name,
			ghost_intro
		]

	message_label.text = "Mood: %s | Personality: %s" % [
		mood,
		personality
	]

	ghost_label.text = str(
		current_ghost.get("icon", "👻")
	)

	rooms_label.text = "Choose the Best Room"

	round_time = float(
		current_ghost.get(
			"patience",
			DEFAULT_PATIENCE
		)
	)

	time_remaining = round_time

	set_room_buttons_disabled(false)

	transition_running = false
	round_active = true

	animate_game_ghost_entrance()


# =========================================================
# GAME GHOST ANIMATION
# =========================================================

func animate_game_ghost_entrance() -> void:
	stop_game_ghost_animation()

	ghost_label.visible = true
	ghost_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	ghost_label.scale = Vector2(0.15, 0.15)
	ghost_label.rotation = deg_to_rad(-10.0)

	await get_tree().process_frame

	ghost_label.pivot_offset = ghost_label.size / 2.0

	var entrance_tween := create_tween()
	entrance_tween.set_parallel(true)

	entrance_tween.tween_property(
		ghost_label,
		"modulate:a",
		1.0,
		0.55
	)

	entrance_tween.tween_property(
		ghost_label,
		"scale",
		Vector2(1.18, 1.18),
		0.55
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	entrance_tween.tween_property(
		ghost_label,
		"rotation",
		0.0,
		0.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await entrance_tween.finished

	var settle_tween := create_tween()

	settle_tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.18
	)

	await settle_tween.finished

	if round_active:
		start_game_ghost_float()


func start_game_ghost_float() -> void:
	if ghost_float_tween:
		ghost_float_tween.kill()

	ghost_float_tween = create_tween()
	ghost_float_tween.set_loops()

	ghost_float_tween.tween_property(
		ghost_label,
		"rotation",
		deg_to_rad(-4.0),
		0.85
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	ghost_float_tween.parallel().tween_property(
		ghost_label,
		"scale",
		Vector2(1.06, 1.06),
		0.85
	)

	ghost_float_tween.tween_property(
		ghost_label,
		"rotation",
		deg_to_rad(4.0),
		0.85
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	ghost_float_tween.parallel().tween_property(
		ghost_label,
		"scale",
		Vector2(0.96, 0.96),
		0.85
	)


func stop_game_ghost_animation() -> void:
	if ghost_float_tween:
		ghost_float_tween.kill()
		ghost_float_tween = null

	ghost_label.rotation = 0.0


# =========================================================
# ROOM SELECTION
# =========================================================

func set_room_buttons_disabled(disabled: bool) -> void:
	cold_button.disabled = disabled
	dark_button.disabled = disabled
	music_button.disabled = disabled


func check_room(selected_room: String) -> void:
	if not game_started:
		return

	if not round_active:
		return

	if transition_running:
		return

	if current_ghost.is_empty():
		return

	round_active = false
	transition_running = true

	set_room_buttons_disabled(true)
	stop_game_ghost_animation()

	var correct_room := str(
		current_ghost.get("preference", "")
	)

	if selected_room == correct_room:
		await handle_correct_answer()
	else:
		await handle_wrong_answer()

	if lives <= 0:
		end_game_lost()
		return

	if current_round >= MAX_ROUNDS:
		end_game_won()
		return

	spawn_new_ghost()


func handle_correct_answer() -> void:
	streak += 1
	best_streak = maxi(best_streak, streak)

	var gained_score := calculate_score_gain()
	score += gained_score

	update_score_label()

	if correct_sound.stream:
		correct_sound.play()

	var ghost_name := str(
		current_ghost.get("name", "The ghost")
	)

	message_label.text = "%s is delighted! %s +%d points" % [
		ghost_name,
		get_success_message(),
		gained_score
	]

	await animate_correct_answer()
	await get_tree().create_timer(CORRECT_WAIT_TIME).timeout


func calculate_score_gain() -> int:
	var gained_score := int(
		current_ghost.get("base_points", 1)
	)

	if streak >= 3:
		gained_score += 1

	if streak >= 5:
		gained_score += 1

	# Fast-answer bonus.
	if time_remaining >= round_time * 0.70:
		gained_score += 1

	return gained_score


func animate_correct_answer() -> void:
	ghost_label.modulate = Color(0.55, 1.0, 0.72, 1.0)

	var tween := create_tween()

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2(1.28, 1.28),
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.2
	)

	await tween.finished


func handle_wrong_answer() -> void:
	lives -= 1
	streak = 0

	update_lives_label()
	update_score_label()

	if wrong_sound.stream:
		wrong_sound.play()

	var ghost_name := str(
		current_ghost.get("name", "The ghost")
	)

	if lives > 0:
		message_label.text = get_failure_message(ghost_name)
	else:
		message_label.text = "%s is furious! No lives remain." % ghost_name

	await animate_wrong_answer()
	await get_tree().create_timer(WRONG_WAIT_TIME).timeout


func animate_wrong_answer() -> void:
	ghost_label.modulate = Color(1.0, 0.38, 0.45, 1.0)

	var original_position := ghost_label.position
	var tween := create_tween()

	for i in range(3):
		tween.tween_property(
			ghost_label,
			"position:x",
			original_position.x - 14.0,
			0.06
		)

		tween.tween_property(
			ghost_label,
			"position:x",
			original_position.x + 14.0,
			0.06
		)

	tween.tween_property(
		ghost_label,
		"position",
		original_position,
		0.08
	)

	await tween.finished


# =========================================================
# TIMEOUT
# =========================================================

func handle_timeout() -> void:
	if transition_running:
		return

	transition_running = true
	set_room_buttons_disabled(true)
	stop_game_ghost_animation()

	lives -= 1
	streak = 0

	update_lives_label()
	update_score_label()

	var ghost_name := str(
		current_ghost.get("name", "The ghost")
	)

	message_label.text = (
		"Too slow! %s floated away without a room."
		% ghost_name
	)

	if wrong_sound.stream:
		wrong_sound.play()

	await animate_wrong_answer()
	await get_tree().create_timer(WRONG_WAIT_TIME).timeout

	if lives <= 0:
		end_game_lost()
		return

	if current_round >= MAX_ROUNDS:
		end_game_won()
		return

	spawn_new_ghost()


# =========================================================
# MESSAGES AND RANKS
# =========================================================

func get_success_message() -> String:
	match streak:
		2:
			return "Nice streak!"
		3:
			return "Great service!"
		4:
			return "Excellent hosting!"
		_:
			if streak >= 5:
				return "Legendary ghost service!"
			return "Perfect room!"


func get_failure_message(ghost_name: String) -> String:
	var messages := [
		"%s is upset! You lost one life.",
		"%s rattled the windows in disappointment!",
		"%s drifted away grumbling about the room!",
		"%s left the hotel a terrifying review!",
		"%s vanished through the wall in frustration!"
	]

	return messages.pick_random() % ghost_name


func get_hotel_rank() -> String:
	if score >= 22:
		return "Phantom Palace"

	if score >= 17:
		return "Spectral Suites"

	if score >= 12:
		return "Moonlit Motel"

	if score >= 7:
		return "Haunted Hostel"

	return "Creaky Inn"


# =========================================================
# END GAME
# =========================================================

func end_game_won() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_game_ghost_animation()
	set_room_buttons_disabled(true)
	update_high_score()

	title_label.text = "NIGHT SHIFT COMPLETE!"
	round_label.text = "Hotel Closed"

	request_label.text = "Every ghost received a room."

	message_label.text = (
		"Final score: %d\n"
		+ "Best streak: %d\n"
		+ "Hotel rank: %s"
	) % [
		score,
		best_streak,
		get_hotel_rank()
	]

	ghost_label.text = "✨👻✨"
	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE

	rooms_label.text = "A Successful Night"

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false

	restart_button.visible = true
	animate_end_screen()


func end_game_lost() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_game_ghost_animation()
	set_room_buttons_disabled(true)
	update_high_score()

	title_label.text = "GAME OVER"
	round_label.text = "Hotel Closed"

	request_label.text = "The ghosts have taken over the lobby."

	message_label.text = (
		"Final score: %d\n"
		+ "Best streak: %d\n"
		+ "Hotel rank: %s"
	) % [
		score,
		best_streak,
		get_hotel_rank()
	]

	ghost_label.text = "😵👻"
	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE

	rooms_label.text = "The Night Is Over"

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false

	restart_button.visible = true

	if game_over_sound.stream:
		game_over_sound.play()

	animate_end_screen()


func animate_end_screen() -> void:
	restart_button.modulate.a = 0.0
	message_label.modulate.a = 0.0
	ghost_label.scale = Vector2(0.4, 0.4)

	await get_tree().process_frame
	ghost_label.pivot_offset = ghost_label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.55
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.65
	)

	tween.tween_property(
		restart_button,
		"modulate:a",
		1.0,
		0.8
	)


# =========================================================
# HIGH SCORE
# =========================================================

func update_high_score() -> void:
	if score > high_score:
		high_score = score
		save_high_score()


func save_high_score() -> void:
	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		push_warning("Unable to save high score.")
		return

	var data := {
		"high_score": high_score
	}

	file.store_string(JSON.stringify(data))


func load_high_score() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		high_score = 0
		return

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		high_score = 0
		return

	var parsed_data = JSON.parse_string(
		file.get_as_text()
	)

	if typeof(parsed_data) == TYPE_DICTIONARY:
		high_score = int(
			parsed_data.get("high_score", 0)
		)
	else:
		high_score = 0


# =========================================================
# BUTTON ANIMATIONS
# =========================================================

func _on_button_mouse_entered(button: Button) -> void:
	if button.disabled:
		return

	await get_tree().process_frame
	button.pivot_offset = button.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2(1.06, 1.06),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		button,
		"modulate",
		Color(1.12, 1.12, 1.12, 1.0),
		0.12
	)


func _on_button_mouse_exited(button: Button) -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.12
	)

	tween.tween_property(
		button,
		"modulate",
		Color.WHITE,
		0.12
	)


func animate_button_press(button: Button) -> void:
	await get_tree().process_frame
	button.pivot_offset = button.size / 2.0

	var tween := create_tween()

	tween.tween_property(
		button,
		"scale",
		Vector2(0.94, 0.94),
		0.06
	)

	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.08
	)


# =========================================================
# BUTTON CALLBACKS
# =========================================================

func _on_start_button_pressed() -> void:
	if entering_hotel:
		return

	animate_button_press(start_button)
	await enter_hotel_animation()


func _on_get_ready_button_pressed() -> void:
	animate_button_press(get_ready_button)
	start_game()


func _on_restart_button_pressed() -> void:
	animate_button_press(restart_button)
	start_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_cold_room_pressed() -> void:
	animate_button_press(cold_button)
	check_room("cold")


func _on_dark_room_pressed() -> void:
	animate_button_press(dark_button)
	check_room("dark")


func _on_music_room_pressed() -> void:
	animate_button_press(music_button)
	check_room("music")
