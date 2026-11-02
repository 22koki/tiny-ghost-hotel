extends Control

@onready var backdrop: TextureRect = $Backdrop
@onready var tint: ColorRect = $Tint
@onready var night_label: Label = $NightLabel
@onready var message: Label = $Message
@onready var reveal: Label = $Reveal
@onready var countdown: Label = $Countdown
@onready var completion_label: Label = $CompletionLabel
@onready var moon: Label = $Moon
@onready var clock: Label = $Clock
@onready var fog_left: Label = $FogLeft
@onready var fog_right: Label = $FogRight
@onready var left_door: ColorRect = $Doors/Left
@onready var right_door: ColorRect = $Doors/Right
@onready var seam: ColorRect = $Doors/Seam
@onready var knob_left: Label = $Doors/KnobLeft
@onready var knob_right: Label = $Doors/KnobRight
@onready var watcher: Label = $Watcher
@onready var watcher_eyes: Label = $WatcherEyes
@onready var omen_flash: ColorRect = $OmenFlash
@onready var fade_overlay: ColorRect = $FadeOverlay

var scene_night: int = 1


func _ready() -> void:
	scene_night = GameState.current_night
	night_label.text = "NIGHT %d" % scene_night
	message.text = _night_message(scene_night)
	reveal.text = _unlock_reveal(scene_night)
	_prepare_text()
	_play_ghost_howl()
	_play_cinematic()


func _prepare_text() -> void:
	night_label.modulate.a = 0.0
	message.modulate.a = 0.0
	reveal.modulate.a = 0.0
	countdown.modulate.a = 0.0
	completion_label.modulate.a = 0.0
	moon.modulate.a = 0.0
	clock.modulate.a = 0.0
	watcher.modulate.a = 0.0
	watcher_eyes.modulate.a = 0.0
	omen_flash.modulate.a = 0.0
	fade_overlay.modulate.a = 1.0


func _play_cinematic() -> void:
	await get_tree().process_frame
	backdrop.pivot_offset = backdrop.size / 2.0
	night_label.pivot_offset = night_label.size / 2.0
	clock.pivot_offset = clock.size / 2.0
	countdown.pivot_offset = countdown.size / 2.0

	backdrop.scale = Vector2(1.14, 1.14)
	night_label.scale = Vector2(0.82, 0.82)
	clock.scale = Vector2(0.75, 0.75)
	clock.rotation = deg_to_rad(-12.0)

	var target_night_position := night_label.position
	night_label.position.y += 18.0
	fog_left.modulate.a = 0.0
	fog_right.modulate.a = 0.0

	var fade_in := create_tween()
	fade_in.set_parallel(true)
	fade_in.tween_property(fade_overlay, "modulate:a", 0.0, 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(backdrop, "scale", Vector2(1.10, 1.10), 1.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(moon, "modulate:a", 0.72, 0.85)
	fade_in.tween_property(clock, "modulate:a", 0.8, 0.75)
	fade_in.tween_property(clock, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(clock, "rotation", 0.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(fog_left, "modulate:a", 0.42, 0.75)
	fade_in.tween_property(fog_right, "modulate:a", 0.34, 0.9)
	await fade_in.finished

	var omen := create_tween()
	omen.set_parallel(true)
	omen.tween_property(moon, "modulate", Color(0.78, 0.06, 0.12, 0.9), 0.52).set_trans(Tween.TRANS_SINE)
	omen.tween_property(tint, "color", Color(0.035, 0.004, 0.018, 0.72), 0.5)
	omen.tween_property(seam, "modulate", Color(1.0, 0.12, 0.08, 1.0), 0.36)
	omen.tween_property(watcher, "modulate:a", 0.82, 0.38)
	omen.tween_property(watcher, "scale", Vector2(1.22, 1.22), 0.72).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	omen.tween_property(watcher_eyes, "modulate:a", 1.0, 0.24).set_delay(0.26)
	await omen.finished

	var flash := create_tween()
	flash.tween_property(omen_flash, "modulate:a", 0.20, 0.045)
	flash.tween_property(omen_flash, "modulate:a", 0.0, 0.16)
	await flash.finished

	var rattle := create_tween()
	for knock in range(3):
		rattle.tween_property(left_door, "position:x", 10.0, 0.045)
		rattle.parallel().tween_property(right_door, "position:x", 630.0, 0.045)
		rattle.tween_property(left_door, "position:x", 0.0, 0.07)
		rattle.parallel().tween_property(right_door, "position:x", 640.0, 0.07)
		rattle.tween_interval(0.08 if knock < 2 else 0.16)
	await rattle.finished

	var reveal_flash := create_tween()
	reveal_flash.tween_property(omen_flash, "modulate:a", 0.14, 0.05)
	reveal_flash.tween_property(omen_flash, "modulate:a", 0.0, 0.22)

	var door_reveal := create_tween()
	door_reveal.set_parallel(true)
	door_reveal.tween_property(left_door, "position:x", -660.0, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_reveal.tween_property(right_door, "position:x", 660.0, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_reveal.tween_property(knob_left, "position:x", -90.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_reveal.tween_property(knob_right, "position:x", 1300.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	door_reveal.tween_property(seam, "modulate:a", 0.0, 0.36)
	door_reveal.tween_property(watcher, "modulate:a", 0.0, 0.24)
	door_reveal.tween_property(watcher_eyes, "modulate:a", 0.0, 0.12)
	door_reveal.tween_property(watcher, "scale", Vector2(1.75, 1.75), 0.46).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	door_reveal.tween_property(backdrop, "scale", Vector2.ONE, 1.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	door_reveal.tween_property(tint, "color", Color(0.012, 0.008, 0.022, 0.42), 1.2).set_trans(Tween.TRANS_SINE)
	door_reveal.tween_property(fog_left, "position:x", -70.0, 2.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	door_reveal.tween_property(fog_right, "position:x", 630.0, 2.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await door_reveal.finished

	var title_reveal := create_tween()
	title_reveal.set_parallel(true)
	title_reveal.tween_property(night_label, "modulate:a", 1.0, 0.42)
	title_reveal.tween_property(night_label, "position", target_night_position, 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	title_reveal.tween_property(night_label, "scale", Vector2.ONE, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	title_reveal.tween_property(message, "modulate:a", 1.0, 0.38).set_delay(0.12)
	title_reveal.tween_property(reveal, "modulate:a", 1.0, 0.42).set_delay(0.28)
	title_reveal.tween_property(moon, "modulate:a", 0.92, 1.3)
	await title_reveal.finished

	var title_haunt := create_tween()
	for flicker in range(2):
		title_haunt.tween_property(night_label, "modulate:a", 0.42, 0.045)
		title_haunt.tween_property(night_label, "modulate:a", 1.0, 0.085)
	await title_haunt.finished
	await get_tree().create_timer(0.82).timeout
	var fade_out := create_tween()
	fade_out.tween_property(fade_overlay, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fade_out.finished
	get_tree().change_scene_to_file("res://main.tscn")


func _play_ghost_howl() -> void:
	var player := AudioStreamPlayer.new()
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 1.4
	player.stream = generator
	player.volume_db = -20.0
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var frames := int(generator.mix_rate * 1.2)
	for i in range(frames):
		var time_value := float(i) / generator.mix_rate
		var envelope := sin(PI * minf(time_value / 1.2, 1.0))
		var frequency := 148.0 - 34.0 * time_value + 7.0 * sin(time_value * 4.2)
		var sample := sin(TAU * frequency * time_value) * envelope * 0.13
		sample += sin(TAU * frequency * 0.48 * time_value) * envelope * 0.045
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
