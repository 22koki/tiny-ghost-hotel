extends RefCounted
class_name GhostCatalog

const GHOSTS := {
	"frosty": {
		"name": "Frosty",
		"icon": "❄️👻",
		"rarity": "Common",
		"personality": "Polite",
		"mood": "Shivering",
		"preference": "Cold rooms",
		"dislikes": "Warm fireplaces",
		"lore": "A courteous winter spirit who checks in whenever the old pipes begin to freeze."
	},
	"shade": {
		"name": "Shade",
		"icon": "🌑👻",
		"rarity": "Common",
		"personality": "Quiet",
		"mood": "Nervous",
		"preference": "Dark rooms",
		"dislikes": "Bright lamps",
		"lore": "Shade prefers forgotten corners and rarely speaks above a whisper."
	},
	"melody": {
		"name": "Melody",
		"icon": "🎵👻",
		"rarity": "Common",
		"personality": "Musical",
		"mood": "Cheerful",
		"preference": "Music rooms",
		"dislikes": "Complete silence",
		"lore": "A humming guest who remembers songs no living musician seems to know."
	},
	"echo": {
		"name": "Echo",
		"icon": "🌘👻",
		"rarity": "Uncommon",
		"personality": "Secretive",
		"mood": "Mysterious",
		"preference": "Dark, quiet rooms",
		"dislikes": "Crowds",
		"lore": "Echo repeats fragments of conversations that took place in the hotel decades ago."
	},
	"misty": {
		"name": "Misty",
		"icon": "🌨️👻",
		"rarity": "Uncommon",
		"personality": "Gentle",
		"mood": "Sleepy",
		"preference": "Cold rooms",
		"dislikes": "Noisy hallways",
		"lore": "Misty drifts through keyholes like winter fog and naps until sunrise."
	},
	"velvet": {
		"name": "Velvet",
		"icon": "🎹👻",
		"rarity": "Uncommon",
		"personality": "Artistic",
		"mood": "Relaxed",
		"preference": "Music rooms",
		"dislikes": "Harsh noises",
		"lore": "A former salon performer who still requests a piano whenever she stays."
	},
	"lord_nocturne": {
		"name": "Lord Nocturne",
		"icon": "👑🌙👻",
		"rarity": "Rare",
		"personality": "Royal",
		"mood": "Impatient",
		"preference": "Complete darkness",
		"dislikes": "Waiting",
		"lore": "An aristocratic apparition who insists the moon itself should dim for his arrival."
	},
	"lady_glimmer": {
		"name": "Lady Glimmer",
		"icon": "✨❄️👻",
		"rarity": "Rare",
		"personality": "Royal",
		"mood": "Elegant",
		"preference": "Cold luxury",
		"dislikes": "Dust and disorder",
		"lore": "A frozen noble spirit whose gowns sparkle like frost beneath candlelight."
	},
	"wisp": {
		"name": "Wisp",
		"icon": "🎶👻",
		"rarity": "Uncommon",
		"personality": "Curious",
		"mood": "Playful",
		"preference": "Music rooms",
		"dislikes": "Being ignored",
		"lore": "Wisp wanders the corridors collecting tunes, gossip and loose room keys."
	}
}

static func get_ghost(ghost_id: String) -> Dictionary:
	return GHOSTS.get(ghost_id, {})

static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for ghost_id in GHOSTS.keys():
		ids.append(str(ghost_id))
	return ids
