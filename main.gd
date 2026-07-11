extends Control


# =========================================================
# GAME SETTINGS
# =========================================================

const SAVE_PATH := "user://tiny_ghost_hotel_save.json"

const STARTING_LIVES := 3
const DEFAULT_MAX_ROUNDS := 10
const DEFAULT_ROUND_TIME := 8.0

const CORRECT_DELAY := 1.2
const WRONG_DELAY := 1.4


# =========================================================
# GAME DATA
# =========================================================

var score: int = 0
var high_score: int = 0
var lives: int = STARTING_LIVES
var streak: int = 0
var best_streak: int = 0

var current_ghost: Dictionary = {}
var current_round: int = 0
var max_rounds: int = DEFAULT_MAX_ROUNDS

var game_started: bool = false
var round_active: bool = false
var transition_running: bool = false

var round_time: float = DEFAULT_ROUND_TIME
var time_remaining: float = DEFAULT_ROUND_TIME

var ghost_pool: Array = []

var ghost_float_tween: Tween
var ghost_entrance_tween: Tween


# =========================================================
# REQUIRED UI NODES
# =========================================================

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var round_label: Label = $RoundLabel
@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var request_label: Label = $RequestLabel
@onready var message_label: Label = $MessageLabel
@onready var ghost_label: Label = $GhostLabel
@onready var rooms_label: Label = $RoomsLabel

@onready var cold_button: Button = $ColdRoomButton
@onready var dark_button: Button = $DarkRoomButton
@onready var music_button: Button = $MusicRoomButton
@onready var restart_button: Button = $RestartButton

@onready var menu_panel: Control = $MenuPanel
@onready var start_button: Button = $StartButton
@onready var quit_button: Button = $QuitButton
@onready var get_ready_button: Button = $GetReadyButton

@onready var correct_sound: AudioStreamPlayer = $CorrectSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound


# =========================================================
# OPTIONAL NODES
#
# These will be used automatically if you add them later.
# =========================================================

@onready var timer_bar: ProgressBar = get_node_or_null("TimerBar") as ProgressBar
@onready var high_score_label: Label = get_node_or_null("HighScoreLabel") as Label
@onready var background_music: AudioStreamPlayer = (
	get_node_or_null("BackgroundMusic") as AudioStreamPlayer
)

@onready var ghost_sprite: TextureRect = (
	get_node_or_null("GhostSprite") as TextureRect
)


# =========================================================
# GHOST INFORMATION
# =========================================================

var ghosts: Array[Dictionary] = [
	{
		"name": "Frosty",
		"preference": "cold",
		"intro": "loves icy breezes",
		"icon": "❄️👻"
	},
	{
		"name": "Shade",
		"preference": "dark",
		"intro": "hates bright lights",
		"icon": "🌑👻"
	},
	{
		"name": "Melody",
		"preference": "music",
		"intro": "sleeps to lullabies",
		"icon": "🎵👻"
	},
	{
		"name": "Echo",
		"preference": "dark",
		"intro": "whispers from the hallway",
		"icon": "🌘👻"
	},
	{
		"name": "Misty",
		"preference": "cold",
		"intro": "drifts like winter fog",
		"icon": "🌨️👻"
	},
	{
		"name": "Velvet",
		"preference": "music",
		"intro": "adores soft piano",
		"icon": "🎹👻"
	},
	{
		"name": "Nocturne",
		"preference": "dark",
		"intro": "comes alive at midnight",
		"icon": "🌙👻"
	},
	{
		"name": "Glimmer",
		"preference": "cold",
		"intro": "sparkles like frost",
		"icon": "✨👻"
	},
	{
		"name": "Wisp",
		"preference": "music",
		"intro": "hums a floating tune",
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
	connect_signals()
	setup_button_animations()
	setup_optional_nodes()

	show_title_screen()


func setup_mouse_filters() -> void:
	# Prevent the panel from blocking buttons.
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	get_ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP

	cold_button.mouse_filter = Control.MOUSE_FILTER_STOP
	dark_button.mouse_filter = Control.MOUSE_FILTER_STOP
	music_button.mouse_filter = Control.MOUSE_FILTER_STOP


func setup_button_text() -> void:
	start_button.text = "Start Game"
	get_ready_button.text = "Begin Night"
	quit_button.text = "Quit"
	restart_button.text = "Play Again"

	cold_button.text = "❄ Cold Room"
	dark_button.text = "🌑 Dark Room"
	music_button.text = "🎵 Music Room"

	rooms_label.text = "Choose a Room"


func setup_optional_nodes() -> void:
	if timer_bar:
		timer_bar.min_value = 0.0
		timer_bar.max_value = round_time
		timer_bar.value = round_time
		timer_bar.visible = false

	if high_score_label:
		update_high_score_label()

	if background_music:
		if not background_music.playing:
			background_music.play()


func connect_signals() -> void:
	connect_button_signal(
		cold_button,
		_on_cold_room_pressed
	)

	connect_button_signal(
		dark_button,
		_on_dark_room_pressed
	)

	connect_button_signal(
		music_button,
		_on_music_room_pressed
	)

	connect_button_signal(
		restart_button,
		_on_restart_button_pressed
	)

	connect_button_signal(
		start_button,
		_on_start_button_pressed
	)

	connect_button_signal(
		quit_button,
		_on_quit_button_pressed
	)

	connect_button_signal(
		get_ready_button,
		_on_get_ready_button_pressed
	)


func connect_button_signal(
	button: Button,
	callback: Callable
) -> void:
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
		button.pivot_offset = button.size / 2.0

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
# MAIN PROCESS — ROUND TIMER
# =========================================================

func _process(delta: float) -> void:
	if not round_active:
		return

	if transition_running:
		return

	time_remaining -= delta
	time_remaining = maxf(time_remaining, 0.0)

	update_timer_display()

	if time_remaining <= 0.0:
		round_active = false
		handle_timeout()


func update_timer_display() -> void:
	if timer_bar:
		timer_bar.value = time_remaining

		if time_remaining <= 2.5:
			timer_bar.modulate = Color(1.0, 0.35, 0.35)
		else:
			timer_bar.modulate = Color.WHITE


# =========================================================
# TITLE SCREEN
# =========================================================

func show_title_screen() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_ghost_animation()

	title_label.text = "Tiny Ghost Hotel"
	subtitle_label.text = "Welcome to the spookiest hotel in town!"

	title_label.visible = true
	subtitle_label.visible = true

	request_label.text = ""
	message_label.text = ""
	ghost_label.text = "👻"

	menu_panel.visible = true
	start_button.visible = true
	get_ready_button.visible = false
	quit_button.visible = true

	round_label.visible = false
	score_label.visible = false
	lives_label.visible = false
	request_label.visible = false
	message_label.visible = false
	ghost_label.visible = false
	rooms_label.visible = false

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false
	restart_button.visible = false

	if timer_bar:
		timer_bar.visible = false

	if high_score_label:
		high_score_label.visible = true
		update_high_score_label()

	animate_title_screen()


func animate_title_screen() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0

	title_label.scale = Vector2(0.8, 0.8)
	title_label.pivot_offset = title_label.size / 2.0

	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		title_label,
		"modulate:a",
		1.0,
		0.6
	)

	tween.tween_property(
		title_label,
		"scale",
		Vector2.ONE,
		0.6
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		subtitle_label,
		"modulate:a",
		1.0,
		0.8
	)

	tween.tween_property(
		menu_panel,
		"modulate:a",
		1.0,
		0.8
	)


# =========================================================
# READY SCREEN
# =========================================================

func show_ready_screen() -> void:
	game_started = false
	round_active = false

	title_label.text = "Tiny Ghost Hotel"
	subtitle_label.visible = true
	subtitle_label.text = "Prepare for the Night Shift"

	menu_panel.visible = true
	start_button.visible = false
	get_ready_button.visible = true
	quit_button.visible = true

	round_label.visible = false
	score_label.visible = false
	lives_label.visible = false

	request_label.visible = true
	request_label.text = "How to Play"

	message_label.visible = true
	message_label.text = (
		"Match each ghost to its favourite room.\n"
		+ "A wrong choice costs one life.\n"
		+ "Answer quickly and build streaks for bonus points."
	)

	ghost_label.visible = true
	ghost_label.text = "🛎️ 👻"

	rooms_label.visible = false
	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false
	restart_button.visible = false

	if timer_bar:
		timer_bar.visible = false

	animate_ready_screen()


func animate_ready_screen() -> void:
	request_label.modulate.a = 0.0
	message_label.modulate.a = 0.0
	ghost_label.modulate.a = 0.0

	ghost_label.scale = Vector2(0.5, 0.5)
	ghost_label.pivot_offset = ghost_label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		request_label,
		"modulate:a",
		1.0,
		0.4
	)

	tween.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.6
	)

	tween.tween_property(
		ghost_label,
		"modulate:a",
		1.0,
		0.5
	)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# =========================================================
# GAME UI
# =========================================================

func show_game_ui() -> void:
	menu_panel.visible = false

	title_label.visible = true
	subtitle_label.visible = false

	round_label.visible = true
	score_label.visible = true
	lives_label.visible = true
	request_label.visible = true
	message_label.visible = true
	ghost_label.visible = true
	rooms_label.visible = true

	cold_button.visible = true
	dark_button.visible = true
	music_button.visible = true
	restart_button.visible = false

	if timer_bar:
		timer_bar.visible = true

	if high_score_label:
		high_score_label.visible = true


func set_room_buttons_disabled(disabled: bool) -> void:
	cold_button.disabled = disabled
	dark_button.disabled = disabled
	music_button.disabled = disabled


# =========================================================
# GAME START AND RESET
# =========================================================

func reset_game_data() -> void:
	score = 0
	lives = STARTING_LIVES
	streak = 0
	best_streak = 0

	current_round = 0
	current_ghost = {}

	round_time = DEFAULT_ROUND_TIME
	time_remaining = round_time

	ghost_pool = ghosts.duplicate(true)
	ghost_pool.shuffle()

	round_active = false
	transition_running = false


func start_game() -> void:
	game_started = true

	reset_game_data()
	show_game_ui()

	title_label.text = "Tiny Ghost Hotel"

	update_round_label()
	update_score_label()
	update_lives_label()
	update_high_score_label()

	request_label.text = "A ghost is approaching the lobby..."
	message_label.text = "Choose the room that matches its request."
	ghost_label.text = "👻"
	rooms_label.text = "Choose a Room"

	set_room_buttons_disabled(false)
	restart_button.visible = false

	spawn_new_ghost()


# =========================================================
# HUD UPDATES
# =========================================================

func update_lives_label() -> void:
	var hearts := ""

	for i in range(lives):
		hearts += "❤ "

	if hearts.is_empty():
		hearts = "None"

	lives_label.text = "Lives: %s" % hearts.strip_edges()


func update_score_label() -> void:
	score_label.text = "Score: %d  |  Streak: %d" % [
		score,
		streak
	]


func update_round_label() -> void:
	round_label.text = "Guest %d / %d" % [
		current_round,
		max_rounds
	]


func update_high_score_label() -> void:
	if high_score_label:
		high_score_label.text = "High Score: %d" % high_score


# =========================================================
# GHOST MANAGEMENT
# =========================================================

func refill_ghost_pool_if_needed() -> void:
	if ghost_pool.is_empty():
		ghost_pool = ghosts.duplicate(true)
		ghost_pool.shuffle()


func spawn_new_ghost() -> void:
	if lives <= 0:
		end_game_lost()
		return

	if current_round >= max_rounds:
		end_game_won()
		return

	refill_ghost_pool_if_needed()

	current_round += 1
	current_ghost = ghost_pool.pop_back()

	update_round_label()

	var ghost_name: String = current_ghost.get(
		"name",
		"Unknown Ghost"
	)

	var ghost_intro: String = current_ghost.get(
		"intro",
		"floats silently"
	)

	request_label.text = "%s arrives and %s." % [
		ghost_name,
		ghost_intro
	]

	message_label.text = "Where should this ghost stay?"
	ghost_label.text = get_ghost_icon(current_ghost)

	time_remaining = round_time

	if timer_bar:
		timer_bar.max_value = round_time
		timer_bar.value = round_time
		timer_bar.modulate = Color.WHITE

	set_room_buttons_disabled(false)
	round_active = true
	transition_running = false

	animate_ghost_entrance()


func get_ghost_icon(ghost_data: Dictionary) -> String:
	if ghost_data.has("icon"):
		return str(ghost_data["icon"])

	var preference: String = str(
		ghost_data.get("preference", "")
	)

	match preference:
		"cold":
			return "❄️👻"
		"dark":
			return "🌑👻"
		"music":
			return "🎵👻"
		_:
			return "👻"


# =========================================================
# GHOST ANIMATION
# =========================================================

func animate_ghost_entrance() -> void:
	stop_ghost_animation()

	ghost_label.pivot_offset = ghost_label.size / 2.0
	ghost_label.modulate = Color(1, 1, 1, 0)
	ghost_label.scale = Vector2(0.3, 0.3)

	var original_position := ghost_label.position
	ghost_label.position.y = original_position.y - 45.0

	ghost_entrance_tween = create_tween()
	ghost_entrance_tween.set_parallel(true)

	ghost_entrance_tween.tween_property(
		ghost_label,
		"modulate:a",
		1.0,
		0.45
	)

	ghost_entrance_tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.55
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	ghost_entrance_tween.tween_property(
		ghost_label,
		"position",
		original_position,
		0.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await ghost_entrance_tween.finished

	if round_active:
		start_ghost_float()


func start_ghost_float() -> void:
	if ghost_float_tween:
		ghost_float_tween.kill()

	var starting_y := ghost_label.position.y

	ghost_float_tween = create_tween()
	ghost_float_tween.set_loops()

	ghost_float_tween.tween_property(
		ghost_label,
		"position:y",
		starting_y - 10.0,
		0.9
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	ghost_float_tween.tween_property(
		ghost_label,
		"position:y",
		starting_y + 10.0,
		0.9
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func stop_ghost_animation() -> void:
	if ghost_float_tween:
		ghost_float_tween.kill()
		ghost_float_tween = null

	if ghost_entrance_tween:
		ghost_entrance_tween.kill()
		ghost_entrance_tween = null


# =========================================================
# ROOM SELECTION
# =========================================================

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
	stop_ghost_animation()

	var correct_room: String = str(
		current_ghost.get("preference", "")
	)

	if selected_room == correct_room:
		await handle_correct_answer()
	else:
		await handle_wrong_answer()

	if lives <= 0:
		end_game_lost()
		return

	if current_round >= max_rounds:
		end_game_won()
		return

	spawn_new_ghost()


func handle_correct_answer() -> void:
	streak += 1
	best_streak = maxi(best_streak, streak)

	var gained_score := calculate_score_gain()
	score += gained_score

	update_score_label()

	if correct_sound:
		correct_sound.play()

	var ghost_name: String = str(
		current_ghost.get("name", "The ghost")
	)

	message_label.text = "%s is delighted! %s  +%d points" % [
		ghost_name,
		get_success_message(),
		gained_score
	]

	await animate_correct_answer()
	await get_tree().create_timer(CORRECT_DELAY).timeout


func calculate_score_gain() -> int:
	var gained_score := 1

	if streak >= 3:
		gained_score = 2

	if streak >= 5:
		gained_score = 3

	if time_remaining >= round_time * 0.70:
		gained_score += 1

	return gained_score


func animate_correct_answer() -> void:
	ghost_label.modulate = Color(
		0.6,
		1.0,
		0.75,
		1.0
	)

	ghost_label.pivot_offset = ghost_label.size / 2.0

	var tween := create_tween()

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2(1.25, 1.25),
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

	if wrong_sound:
		wrong_sound.play()

	var ghost_name: String = str(
		current_ghost.get("name", "The ghost")
	)

	if lives > 0:
		message_label.text = get_failure_message(ghost_name)
	else:
		message_label.text = (
			"%s is furious! The hotel has no lives left."
			% ghost_name
		)

	await animate_wrong_answer()
	await get_tree().create_timer(WRONG_DELAY).timeout


func animate_wrong_answer() -> void:
	ghost_label.modulate = Color(
		1.0,
		0.45,
		0.45,
		1.0
	)

	var original_position := ghost_label.position

	var tween := create_tween()

	for i in range(3):
		tween.tween_property(
			ghost_label,
			"position:x",
			original_position.x - 12.0,
			0.06
		)

		tween.tween_property(
			ghost_label,
			"position:x",
			original_position.x + 12.0,
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
	stop_ghost_animation()

	lives -= 1
	streak = 0

	update_lives_label()
	update_score_label()

	var ghost_name: String = str(
		current_ghost.get("name", "The ghost")
	)

	message_label.text = (
		"Too slow! %s floated away without a room."
		% ghost_name
	)

	if wrong_sound:
		wrong_sound.play()

	await animate_wrong_answer()
	await get_tree().create_timer(WRONG_DELAY).timeout

	if lives <= 0:
		end_game_lost()
		return

	if current_round >= max_rounds:
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
		"%s left the hotel a frightening review!",
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

	stop_ghost_animation()
	set_room_buttons_disabled(true)

	update_high_score()

	title_label.text = "Night Shift Complete!"
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
	rooms_label.text = "A Successful Night"

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false

	restart_button.visible = true

	if timer_bar:
		timer_bar.visible = false

	animate_end_screen()


func end_game_lost() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_ghost_animation()
	set_room_buttons_disabled(true)

	update_high_score()

	title_label.text = "Game Over"
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
	rooms_label.text = "The Night Is Over"

	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false

	restart_button.visible = true

	if timer_bar:
		timer_bar.visible = false

	if game_over_sound:
		game_over_sound.play()

	animate_end_screen()


func animate_end_screen() -> void:
	restart_button.modulate.a = 0.0
	message_label.modulate.a = 0.0

	ghost_label.scale = Vector2(0.5, 0.5)
	ghost_label.pivot_offset = ghost_label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.6
	)

	tween.tween_property(
		restart_button,
		"modulate:a",
		1.0,
		0.8
	)


# =========================================================
# HIGH-SCORE SAVING
# =========================================================

func update_high_score() -> void:
	if score > high_score:
		high_score = score
		save_high_score()

	update_high_score_label()


func save_high_score() -> void:
	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		push_warning("Could not save the high score.")
		return

	var data := {
		"high_score": high_score
	}

	file.store_string(
		JSON.stringify(data)
	)


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

	var json_text := file.get_as_text()
	var parsed_data = JSON.parse_string(json_text)

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
	animate_button_press(start_button)
	show_ready_screen()


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