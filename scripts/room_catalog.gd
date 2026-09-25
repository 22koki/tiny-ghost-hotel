extends RefCounted
class_name RoomCatalog

const ROOMS := {
	"cold_room": {
		"name": "The Frost Chamber",
		"short_name": "Cold Room",
		"icon": "❄",
		"theme": "Icy blue Victorian chamber with frosted windows and silver fixtures.",
		"best_for": ["cold"],
		"unlock_night": 1,
		"unlock_cost": 0,
		"upgrade_costs": [120, 240, 420]
	},
	"dark_room": {
		"name": "The Moonless Suite",
		"short_name": "Dark Room",
		"icon": "☾",
		"theme": "Velvet-draped room lit only by moon-shaped lamps and dying candles.",
		"best_for": ["dark", "quiet"],
		"unlock_night": 1,
		"unlock_cost": 0,
		"upgrade_costs": [120, 240, 420]
	},
	"music_room": {
		"name": "The Crimson Parlour",
		"short_name": "Music Room",
		"icon": "♪",
		"theme": "A burgundy salon with a haunted gramophone, piano and dancing candlelight.",
		"best_for": ["music"],
		"unlock_night": 1,
		"unlock_cost": 0,
		"upgrade_costs": [140, 280, 460]
	},
	"library_room": {
		"name": "The Whispering Library",
		"short_name": "Library",
		"icon": "📚",
		"theme": "Floor-to-ceiling books, rolling ladders and portraits whose eyes quietly follow guests.",
		"best_for": ["quiet", "scholar", "ancient"],
		"unlock_night": 2,
		"unlock_cost": 320,
		"upgrade_costs": [180, 340, 560]
	},
	"garden_room": {
		"name": "The Midnight Conservatory",
		"short_name": "Garden Room",
		"icon": "❧",
		"theme": "An overgrown glasshouse filled with moonflowers, ivy and faintly glowing fountains.",
		"best_for": ["nature", "gentle", "moonlight"],
		"unlock_night": 3,
		"unlock_cost": 420,
		"upgrade_costs": [220, 400, 650]
	},
	"potion_room": {
		"name": "The Alchemist's Chamber",
		"short_name": "Potion Room",
		"icon": "⚗",
		"theme": "Copper pipes, bubbling glassware and shelves of mysterious bottled remedies.",
		"best_for": ["strange", "magical", "restless"],
		"unlock_night": 4,
		"unlock_cost": 560,
		"upgrade_costs": [260, 460, 720]
	},
	"art_room": {
		"name": "The Portrait Gallery",
		"short_name": "Art Room",
		"icon": "♜",
		"theme": "A faded gallery of ornate frames, covered statues and paintings that change overnight.",
		"best_for": ["artistic", "vain", "dramatic"],
		"unlock_night": 4,
		"unlock_cost": 620,
		"upgrade_costs": [280, 500, 780]
	},
	"moonlight_suite": {
		"name": "The Moonlight Suite",
		"short_name": "Moonlight Suite",
		"icon": "☽",
		"theme": "A luxurious tower suite with a circular moon window and silver-blue canopy bed.",
		"best_for": ["royal", "moonlight", "elegant"],
		"unlock_night": 5,
		"unlock_cost": 850,
		"upgrade_costs": [380, 650, 980]
	},
	"seance_room": {
		"name": "The Séance Salon",
		"short_name": "Séance Room",
		"icon": "✦",
		"theme": "A candle-ringed salon with velvet chairs, crystal pendulums and a whispering spirit board.",
		"best_for": ["mysterious", "social", "ancient"],
		"unlock_night": 6,
		"unlock_cost": 980,
		"upgrade_costs": [420, 760, 1120]
	},
	"clockwork_room": {
		"name": "The Clockwork Quarters",
		"short_name": "Clockwork Room",
		"icon": "⚙",
		"theme": "Brass clocks, mechanical birds and softly ticking walls inspired by a forgotten inventor.",
		"best_for": ["curious", "restless", "mechanical"],
		"unlock_night": 7,
		"unlock_cost": 1100,
		"upgrade_costs": [480, 820, 1280]
	},
	"vip_room": {
		"name": "The Royal Haunt",
		"short_name": "VIP Room",
		"icon": "♛",
		"theme": "The grandest suite: gold trim, antique velvet, a private fireplace and spectral room service.",
		"best_for": ["vip", "royal", "elegant"],
		"unlock_night": 5,
		"unlock_cost": 1200,
		"upgrade_costs": [520, 900, 1400]
	},
	"mirror_room": {
		"name": "The Looking-Glass Room",
		"short_name": "Mirror Room",
		"icon": "◈",
		"theme": "A silver room lined with antique mirrors where reflections sometimes move before their guests.",
		"best_for": ["vain", "mysterious", "dramatic"],
		"unlock_night": 8,
		"unlock_cost": 1450,
		"upgrade_costs": [600, 980, 1550]
	}
}

static func get_room(room_id: String) -> Dictionary:
	return ROOMS.get(room_id, {})

static func get_all_room_ids() -> Array[String]:
	var ids: Array[String] = []
	for room_id in ROOMS.keys():
		ids.append(str(room_id))
	return ids
