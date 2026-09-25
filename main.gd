extends Control


const SAVE_PATH := "user://tiny_ghost_hotel_save.json"

const STARTING_LIVES := 3
const BASE_ROUNDS := 8
const DEFAULT_PATIENCE := 8.0

const CORRECT_WAIT_TIME := 1.1
const WRONG_WAIT_TIME := 1.3


var score: int = 0
var high_score: int = 0
var lives: int = STARTING_LIVES
var streak: int = 0
var best_streak: int = 0

var current_round: int = 0
var max_rounds: int = BASE_ROUNDS
var current_event: Dictionary = {}
var room_button_order: Array[Button] = []
var special_effect_active: bool = false
var current_ghost: Dictionary = {}
var ghost_pool: Array[Dictionary] = []

var game_started: bool = false
var round_active: bool = false
var transition_running: bool = false

var round_time: float = DEFAULT_PATIENCE
var time_remaining: float = DEFAULT_PATIENCE

var ghost_float_tween: Tween


@onready var night_background: ColorRect = $NightBackground
@onready var hotel_background: TextureRect = $HotelBackground
@onready var background_tint: ColorRect = $BackgroundTint

@onready var lobby_title: Label = $LobbyTitle

@onready var score_label: Label = $HudPanel/ScoreLabel
@onready var lives_label: Label = $HudPanel/LivesLabel
@onready var round_label: Label = $HudPanel/RoundLabel

@onready var guest_badge_label: Label = (
	$ReceptionPanel/GuestBadgeLabel
)

@onready var request_label: Label = (
	$ReceptionPanel/RequestLabel
)

@onready var ghost_label: Label = (
	$ReceptionPanel/GhostLabel
)

@onready var message_label: Label = (
	$ReceptionPanel/MessageLabel
)

@onready var timer_bar: ProgressBar = (
	$ReceptionPanel/TimerBar
)

@onready var rooms_label: Label = $RoomsLabel

@onready var cold_button: Button = $ColdRoomButton
@onready var dark_button: Button = $DarkRoomButton
@onready var music_button: Button = $MusicRoomButton

@onready var restart_button: Button = $RestartButton
@onready var menu_button: Button = $MenuButton

@onready var correct_sound: AudioStreamPlayer2D = $CorrectSound
@onready var wrong_sound: AudioStreamPlayer2D = $WrongSound
@onready var game_over_sound: AudioStreamPlayer2D = $GameOverSound


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
	},
	{
		"name": "Count Vesper",
		"preference": "dark",
		"intro": "requests blackout curtains and no mirrors",
		"mood": "Composed",
		"personality": "Aristocratic",
		"patience": 6.0,
		"base_points": 2,
		"vip": true,
		"unlock_night": 4,
		"icon": "🦇👻"
	},
	{
		"name": "Mabel Mourning",
		"preference": "music",
		"intro": "asks for a room where old wedding songs still play",
		"mood": "Melancholy",
		"personality": "Romantic",
		"patience": 7.0,
		"base_points": 2,
		"vip": false,
		"unlock_night": 4,
		"icon": "👰👻"
	},
	{
		"name": "Professor Cog",
		"preference": "music",
		"intro": "ticks softly and listens for mechanical rhythms",
		"mood": "Focused",
		"personality": "Inventive",
		"patience": 6.5,
		"base_points": 2,
		"vip": false,
		"unlock_night": 5,
		"icon": "⚙️👻"
	},
	{
		"name": "The Headless Traveller",
		"preference": "cold",
		"intro": "has arrived from a very long road and wants silence",
		"mood": "Weary",
		"personality": "Stoic",
		"patience": 5.5,
		"base_points": 2,
		"vip": false,
		"unlock_night": 5,
		"icon": "🎩👻"
	},
	{
		"name": "The Bell Twins",
		"preference": "music",
		"intro": "finish each other's melodies and refuse to separate",
		"mood": "Excited",
		"personality": "Mischievous",
		"patience": 5.0,
		"base_points": 3,
		"vip": false,
		"unlock_night": 6,
		"icon": "🔔👻👻"
	},
	{
		"name": "Banshee Beatrice",
		"preference": "dark",
		"intro": "warns that bright rooms make her voice much louder",
		"mood": "Restless",
		"personality": "Dramatic",
		"patience": 4.8,
		"base_points": 3,
		"vip": false,
		"unlock_night": 6,
		"icon": "📣👻"
	},
	{
		"name": "Little Lucien",
		"preference": "cold",
		"intro": "clutches a wooden toy and asks for a quiet chilly room",
		"mood": "Shy",
		"personality": "Gentle",
		"patience": 8.5,
		"base_points": 2,
		"vip": false,
		"unlock_night": 7,
		"icon": "🧸👻"
	},
	{
		"name": "The Poltergeist",
		"preference": "dark",
		"intro": "has already moved three lamps without touching them",
		"mood": "Chaotic",
		"personality": "Unruly",
		"patience": 4.2,
		"base_points": 3,
		"vip": false,
		"unlock_night": 7,
		"icon": "🪑👻"
	},
	{
		"name": "Madame Umbra",
		"preference": "dark",
		"intro": "arrives beneath an eclipse and expects royal treatment",
		"mood": "Severe",
		"personality": "Regal",
		"patience": 4.0,
		"base_points": 4,
		"vip": true,
		"unlock_night": 8,
		"icon": "🌘👑👻"
	}
]


func _ready() -> void:
	randomize()
	load_high_score()

	setup_mouse_filters()
	setup_button_text()
	connect_buttons()
	setup_button_animations()
	room_button_order = [cold_button, dark_button, music_button]

	start_game()


func _process(delta: float) -> void:
	if not game_started:
		return

	if not round_active:
		return

	if transition_running:
		return

	time_remaining = maxf(
		time_remaining - delta,
		0.0
	)

	timer_bar.value = time_remaining

	if time_remaining <= 3.0:
		timer_bar.modulate = Color(
			1.0,
			0.42,
			0.48,
			1.0
		)

		message_label.text = (
			"Hurry! %.1f seconds remaining!"
			% time_remaining
		)
	else:
		timer_bar.modulate = Color.WHITE

	if time_remaining <= 0.0:
		round_active = false
		handle_timeout()


func setup_mouse_filters() -> void:
	night_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotel_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup_button_text() -> void:
	cold_button.text = "❄ COLD ROOM\nQuiet and chilly"
	dark_button.text = "🌑 DARK ROOM\nDim and restful"
	music_button.text = "🎵 MUSIC ROOM\nSoft spooky tunes"

	restart_button.text = "PLAY AGAIN"
	menu_button.text = "MAIN MENU"


func connect_buttons() -> void:
	connect_button(
		cold_button,
		_on_cold_room_pressed
	)

	connect_button(
		dark_button,
		_on_dark_room_pressed
	)

	connect_button(
		music_button,
		_on_music_room_pressed
	)

	connect_button(
		restart_button,
		_on_restart_button_pressed
	)

	connect_button(
		menu_button,
		_on_menu_button_pressed
	)


func connect_button(
	button: Button,
	callback: Callable
) -> void:
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func setup_button_animations() -> void:
	var buttons: Array[Button] = [
		cold_button,
		dark_button,
		music_button,
		restart_button,
		menu_button
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


func reset_game_data() -> void:
	score = 0
	lives = STARTING_LIVES
	streak = 0
	best_streak = 0

	current_round = 0
	current_ghost = {}

	ghost_pool = get_available_ghosts()
	ghost_pool.shuffle()

	round_active = false
	transition_running = false

	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE
	ghost_label.rotation = 0.0

	message_label.modulate = Color.WHITE


func start_game() -> void:
	GameState.clear_room_occupants()
	reset_game_data()

	game_started = true

	max_rounds = get_round_count_for_night()
	current_event = get_night_event()
	lobby_title.text = "TINY GHOST HOTEL — NIGHT %d" % GameState.current_night
	rooms_label.text = str(current_event.get("title", "Choose the perfect room"))

	restart_button.visible = false

	cold_button.visible = true
	dark_button.visible = true
	music_button.visible = true

	update_score_label()
	update_lives_label()
	update_round_label()

	spawn_new_ghost()


func update_score_label() -> void:
	score_label.text = (
		"Score: %d  |  Streak: %d  |  Best: %d"
		% [score, streak, high_score]
	)


func update_lives_label() -> void:
	var hearts := ""

	for i in range(lives):
		hearts += "❤ "

	if hearts.is_empty():
		hearts = "None"

	lives_label.text = (
		"Lives: %s"
		% hearts.strip_edges()
	)


func update_round_label() -> void:
	round_label.text = (
		"Guest %d/%d  •  Night %d"
		% [current_round, max_rounds, GameState.current_night]
	)


func refill_ghost_pool_if_needed() -> void:
	if ghost_pool.is_empty():
		ghost_pool = get_available_ghosts()
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

	var ghost_id := str(current_ghost.get("name", "unknown")).to_lower().replace(" ", "_")
	GameState.discover_ghost(ghost_id)

	update_round_label()

	var ghost_name := str(
		current_ghost.get(
			"name",
			"Unknown Ghost"
		)
	)

	var ghost_intro := str(
		current_ghost.get(
			"intro",
			"floats silently"
		)
	)

	var mood := str(
		current_ghost.get(
			"mood",
			"Mysterious"
		)
	)

	var personality := str(
		current_ghost.get(
			"personality",
			"Unknown"
		)
	)

	var is_vip := bool(
		current_ghost.get(
			"vip",
			false
		)
	)

	if is_vip:
		guest_badge_label.text = "★ VIP GUEST ★"
		guest_badge_label.modulate = Color(
			1.0,
			0.82,
			0.32,
			1.0
		)
	else:
		guest_badge_label.text = "NEW GUEST"
		guest_badge_label.modulate = Color(
			0.88,
			0.75,
			1.0,
			1.0
		)

	request_label.text = (
		"%s arrives and %s."
		% [ghost_name, ghost_intro]
	)

	message_label.text = (
		"Mood: %s  |  Personality: %s"
		% [mood, personality]
	)

	ghost_label.text = str(
		current_ghost.get(
			"icon",
			"👻"
		)
	)

	round_time = float(
		current_ghost.get(
			"patience",
			DEFAULT_PATIENCE
		)
	)
	round_time *= get_patience_multiplier()
	round_time *= float(current_event.get("patience_multiplier", 1.0))

	time_remaining = round_time

	timer_bar.max_value = round_time
	timer_bar.value = round_time
	timer_bar.modulate = Color.WHITE

	set_room_buttons_disabled(false)
	apply_guest_special_mechanic()

	transition_running = false
	round_active = true

	animate_game_ghost_entrance()


func animate_game_ghost_entrance() -> void:
	stop_game_ghost_animation()

	ghost_label.visible = true
	ghost_label.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	ghost_label.scale = Vector2(
		0.2,
		0.2
	)

	ghost_label.rotation = deg_to_rad(-8.0)

	await get_tree().process_frame

	ghost_label.pivot_offset = (
		ghost_label.size / 2.0
	)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		ghost_label,
		"modulate:a",
		1.0,
		0.5
	)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2(1.18, 1.18),
		0.55
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		ghost_label,
		"rotation",
		0.0,
		0.5
	)

	await tween.finished

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
		deg_to_rad(-3.0),
		0.9
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	ghost_float_tween.parallel().tween_property(
		ghost_label,
		"scale",
		Vector2(1.05, 1.05),
		0.9
	)

	ghost_float_tween.tween_property(
		ghost_label,
		"rotation",
		deg_to_rad(3.0),
		0.9
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	ghost_float_tween.parallel().tween_property(
		ghost_label,
		"scale",
		Vector2(0.97, 0.97),
		0.9
	)


func stop_game_ghost_animation() -> void:
	if ghost_float_tween:
		ghost_float_tween.kill()
		ghost_float_tween = null

	ghost_label.rotation = 0.0


func set_room_buttons_disabled(
	disabled: bool
) -> void:
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
	reset_special_mechanics()
	stop_game_ghost_animation()

	var correct_room := str(
		current_ghost.get(
			"preference",
			""
		)
	)

	if selected_room == correct_room:
		var room_id: String = {
			"cold": "cold_room",
			"dark": "dark_room",
			"music": "music_room"
		}.get(selected_room, "")
		if not room_id.is_empty():
			GameState.check_in_guest(
				room_id,
				str(current_ghost.get("name", "Unknown Guest")),
				str(current_ghost.get("icon", "👻"))
			)
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
	best_streak = maxi(
		best_streak,
		streak
	)

	var gained_score := calculate_score_gain()
	score += gained_score

	update_score_label()

	if correct_sound.stream:
		correct_sound.play()

	var ghost_name := str(
		current_ghost.get(
			"name",
			"The ghost"
		)
	)

	message_label.text = (
		"%s is delighted! %s  +%d points"
		% [
			ghost_name,
			get_success_message(),
			gained_score
		]
	)

	await animate_correct_answer()

	await get_tree().create_timer(
		CORRECT_WAIT_TIME
	).timeout


func calculate_score_gain() -> int:
	var gained_score := int(
		current_ghost.get(
			"base_points",
			1
		)
	)

	if streak >= 3:
		gained_score += 1

	if streak >= 5:
		gained_score += 1

	if time_remaining >= round_time * 0.70:
		gained_score += 1

	return gained_score


func animate_correct_answer() -> void:
	ghost_label.modulate = Color(
		0.55,
		1.0,
		0.72,
		1.0
	)

	var tween := create_tween()

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2(1.28, 1.28),
		0.18
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.2
	)

	await tween.finished


func handle_wrong_answer() -> void:
	lives -= get_guest_failure_penalty()
	streak = 0

	update_lives_label()
	update_score_label()

	if wrong_sound.stream:
		wrong_sound.play()

	var ghost_name := str(
		current_ghost.get(
			"name",
			"The ghost"
		)
	)

	if lives > 0:
		message_label.text = (
			get_failure_message(
				ghost_name
			)
		)
	else:
		message_label.text = (
			"%s is furious! No lives remain."
			% ghost_name
		)

	await animate_wrong_answer()

	await get_tree().create_timer(
		WRONG_WAIT_TIME
	).timeout


func animate_wrong_answer() -> void:
	ghost_label.modulate = Color(
		1.0,
		0.38,
		0.45,
		1.0
	)

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


func handle_timeout() -> void:
	if transition_running:
		return

	transition_running = true

	set_room_buttons_disabled(true)
	stop_game_ghost_animation()

	lives -= get_guest_failure_penalty()
	streak = 0

	update_lives_label()
	update_score_label()

	var ghost_name := str(
		current_ghost.get(
			"name",
			"The ghost"
		)
	)

	message_label.text = (
		"Too slow! %s floated away without a room."
		% ghost_name
	)

	if wrong_sound.stream:
		wrong_sound.play()

	await animate_wrong_answer()

	await get_tree().create_timer(
		WRONG_WAIT_TIME
	).timeout

	if lives <= 0:
		end_game_lost()
		return

	if current_round >= max_rounds:
		end_game_won()
		return

	spawn_new_ghost()


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


func get_failure_message(
	ghost_name: String
) -> String:
	var messages: Array[String] = [
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


func end_game_won() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_game_ghost_animation()
	set_room_buttons_disabled(true)
	update_high_score()

	lobby_title.text = "NIGHT SHIFT COMPLETE!"
	round_label.text = "Hotel Closed"

	guest_badge_label.text = "SHIFT COMPLETE"

	request_label.text = (
		"Every ghost received a room."
	)

	message_label.text = (
		"Final score: %d  |  Best streak: %d\n"
		+ "Hotel rank: %s"
	) % [
		score,
		best_streak,
		get_hotel_rank()
	]

	ghost_label.text = "✨👻✨"
	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE

	timer_bar.value = 0.0
	rooms_label.text = "A successful night"

	GameState.finish_shift(score, best_streak, true, get_hotel_rank())
	await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file("res://scenes/NightSummary.tscn")


func end_game_lost() -> void:
	game_started = false
	round_active = false
	transition_running = false

	stop_game_ghost_animation()
	set_room_buttons_disabled(true)
	update_high_score()

	lobby_title.text = "GAME OVER"
	round_label.text = "Hotel Closed"

	guest_badge_label.text = "LOBBY OVERRUN"

	request_label.text = (
		"The ghosts have taken over reception."
	)

	message_label.text = (
		"Final score: %d  |  Best streak: %d\n"
		+ "Hotel rank: %s"
	) % [
		score,
		best_streak,
		get_hotel_rank()
	]

	ghost_label.text = "😵👻"
	ghost_label.modulate = Color.WHITE
	ghost_label.scale = Vector2.ONE

	timer_bar.value = 0.0
	rooms_label.text = "The night is over"

	show_end_buttons()

	if game_over_sound.stream:
		game_over_sound.play()

	GameState.finish_shift(score, best_streak, false, get_hotel_rank())
	await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file("res://scenes/NightSummary.tscn")


func show_end_buttons() -> void:
	cold_button.visible = false
	dark_button.visible = false
	music_button.visible = false

	restart_button.visible = true


func animate_end_screen() -> void:
	restart_button.modulate.a = 0.0
	message_label.modulate.a = 0.0
	ghost_label.scale = Vector2(0.4, 0.4)

	await get_tree().process_frame

	ghost_label.pivot_offset = (
		ghost_label.size / 2.0
	)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		ghost_label,
		"scale",
		Vector2.ONE,
		0.55
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

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
		push_warning(
			"Unable to save high score."
		)
		return

	var data: Dictionary = {
		"high_score": high_score
	}

	file.store_string(
		JSON.stringify(data)
	)


func load_high_score() -> void:
	if not FileAccess.file_exists(
		SAVE_PATH
	):
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
			parsed_data.get(
				"high_score",
				0
			)
		)
	else:
		high_score = 0


func _on_button_mouse_entered(
	button: Button
) -> void:
	if button.disabled:
		return

	await get_tree().process_frame

	button.pivot_offset = (
		button.size / 2.0
	)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2(1.06, 1.06),
		0.12
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		button,
		"modulate",
		Color(1.1, 1.08, 1.14, 1.0),
		0.12
	)


func _on_button_mouse_exited(
	button: Button
) -> void:
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


func animate_button_press(
	button: Button
) -> void:
	await get_tree().process_frame

	button.pivot_offset = (
		button.size / 2.0
	)

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


func _on_restart_button_pressed() -> void:
	animate_button_press(restart_button)
	start_game()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)


func _on_cold_room_pressed() -> void:
	animate_button_press(cold_button)
	check_room("cold")


func _on_dark_room_pressed() -> void:
	animate_button_press(dark_button)
	check_room("dark")


func _on_music_room_pressed() -> void:
	animate_button_press(music_button)
	check_room("music")

func get_round_count_for_night() -> int:
	return mini(BASE_ROUNDS + (GameState.current_night - 1), 15)


func get_patience_multiplier() -> float:
	var reduction := minf(float(GameState.current_night - 1) * 0.045, 0.30)
	return 1.0 - reduction


func get_available_ghosts() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for ghost in ghosts:
		var unlock_night := int(ghost.get("unlock_night", 1))
		if GameState.current_night < unlock_night:
			continue
		var is_vip := bool(ghost.get("vip", false))
		if is_vip and GameState.current_night < 3:
			continue
		available.append(ghost.duplicate(true))
	return available


func get_night_event() -> Dictionary:
	var events: Array[Dictionary] = [
		{
			"title": "A Quiet Night at Reception",
			"patience_multiplier": 1.0
		},
		{
			"title": "Flickering Candles — guests are uneasy",
			"patience_multiplier": 0.92
		},
		{
			"title": "Full Moon Rush — spirits arrive impatient",
			"patience_multiplier": 0.84
		},
		{
			"title": "Heavy Fog — the lobby feels strangely slow",
			"patience_multiplier": 1.08
		}
	]

	if GameState.current_night <= 1:
		return events[0]

	return events[randi() % events.size()]


func apply_guest_special_mechanic() -> void:
	special_effect_active = false
	var ghost_name := str(current_ghost.get("name", ""))

	match ghost_name:
		"The Bell Twins":
			special_effect_active = true
			round_time *= 0.88
			time_remaining = round_time
			timer_bar.max_value = round_time
			timer_bar.value = round_time
			message_label.text += "  •  Twin Trouble: decide quickly!"
		"Banshee Beatrice":
			special_effect_active = true
			round_time *= 0.78
			time_remaining = round_time
			timer_bar.max_value = round_time
			timer_bar.value = round_time
			message_label.text += "  •  Banshee Wail: patience drains faster!"
		"The Poltergeist":
			special_effect_active = true
			shuffle_room_buttons()
			message_label.text += "  •  Poltergeist: the room plaques have moved!"
		"Count Vesper":
			special_effect_active = true
			dark_button.text = "🌑 BLACKOUT SUITE\nNo mirrors. No sunrise."
			message_label.text += "  •  Noble Demand: he expects darkness."
		"Madame Umbra":
			special_effect_active = true
			guest_badge_label.text = "★ LEGENDARY BOSS GUEST ★"
			guest_badge_label.modulate = Color(1.0, 0.52, 0.18, 1.0)
			round_time *= 0.70
			time_remaining = round_time
			timer_bar.max_value = round_time
			timer_bar.value = round_time
			message_label.text += "  •  Eclipse Trial: one mistake could ruin the night."
		_:
			pass


func shuffle_room_buttons() -> void:
	var positions: Array[Vector2] = []
	for button in room_button_order:
		positions.append(button.position)
	positions.shuffle()
	for i in range(room_button_order.size()):
		room_button_order[i].position = positions[i]


func reset_special_mechanics() -> void:
	if not special_effect_active:
		return
	special_effect_active = false
	setup_button_text()

	# Restore the original scene positions after Poltergeist interference.
	cold_button.position = Vector2(105.0, 590.0)
	dark_button.position = Vector2(495.0, 590.0)
	music_button.position = Vector2(885.0, 590.0)


func get_guest_failure_penalty() -> int:
	var ghost_name := str(current_ghost.get("name", ""))
	if ghost_name == "Madame Umbra":
		return 2
	return 1
