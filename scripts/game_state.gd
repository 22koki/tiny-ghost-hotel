extends Node

const SAVE_PATH := "user://tiny_ghost_hotel_progress.json"

var coins: int = 0
var current_night: int = 1
var hotel_reputation: int = 0
var discovered_ghosts: Array[String] = []
var unlocked_rooms: Array[String] = ["cold_room", "dark_room", "music_room"]
var room_levels: Dictionary = {
	"cold_room": 1,
	"dark_room": 1,
	"music_room": 1
}

func _ready() -> void:
	load_progress()

func add_coins(amount: int) -> void:
	coins = maxi(0, coins + amount)
	save_progress()

func spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	save_progress()
	return true

func unlock_room(room_id: String) -> void:
	if room_id not in unlocked_rooms:
		unlocked_rooms.append(room_id)
		room_levels[room_id] = 1
		save_progress()

func is_room_unlocked(room_id: String) -> bool:
	return room_id in unlocked_rooms

func upgrade_room(room_id: String, cost: int) -> bool:
	if not is_room_unlocked(room_id):
		return false
	if not spend_coins(cost):
		return false
	room_levels[room_id] = int(room_levels.get(room_id, 1)) + 1
	save_progress()
	return true

func discover_ghost(ghost_id: String) -> void:
	if ghost_id not in discovered_ghosts:
		discovered_ghosts.append(ghost_id)
		save_progress()

func complete_night(reputation_gain: int = 1) -> void:
	hotel_reputation = maxi(0, hotel_reputation + reputation_gain)
	current_night += 1
	save_progress()

func reset_progress() -> void:
	coins = 0
	current_night = 1
	hotel_reputation = 0
	discovered_ghosts.clear()
	unlocked_rooms = ["cold_room", "dark_room", "music_room"]
	room_levels = {
		"cold_room": 1,
		"dark_room": 1,
		"music_room": 1
	}
	save_progress()

func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Unable to save Tiny Ghost Hotel progression.")
		return

	var payload := {
		"coins": coins,
		"current_night": current_night,
		"hotel_reputation": hotel_reputation,
		"discovered_ghosts": discovered_ghosts,
		"unlocked_rooms": unlocked_rooms,
		"room_levels": room_levels
	}
	file.store_string(JSON.stringify(payload))

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	coins = int(parsed.get("coins", 0))
	current_night = int(parsed.get("current_night", 1))
	hotel_reputation = int(parsed.get("hotel_reputation", 0))

	discovered_ghosts.clear()
	for ghost_id in parsed.get("discovered_ghosts", []):
		discovered_ghosts.append(str(ghost_id))

	unlocked_rooms.clear()
	for room_id in parsed.get("unlocked_rooms", ["cold_room", "dark_room", "music_room"]):
		unlocked_rooms.append(str(room_id))

	room_levels = parsed.get("room_levels", {
		"cold_room": 1,
		"dark_room": 1,
		"music_room": 1
	})
