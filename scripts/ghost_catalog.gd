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
	},
	"count_vesper": {
		"name": "Count Vesper",
		"icon": "🦇👻",
		"rarity": "Rare",
		"personality": "Aristocratic",
		"mood": "Composed",
		"preference": "Dark rooms",
		"dislikes": "Mirrors and daylight",
		"lore": "A nocturnal noble who signs the registry only after sunset and never seems to cast a reflection."
	},
	"mabel_mourning": {
		"name": "Mabel Mourning",
		"icon": "👰👻",
		"rarity": "Uncommon",
		"personality": "Romantic",
		"mood": "Melancholy",
		"preference": "Music rooms",
		"dislikes": "Silence",
		"lore": "A spectral bride who has been waiting for the final dance from a wedding that ended long ago."
	},
	"professor_cog": {
		"name": "Professor Cog",
		"icon": "⚙️👻",
		"rarity": "Uncommon",
		"personality": "Inventive",
		"mood": "Focused",
		"preference": "Music rooms",
		"dislikes": "Broken clocks",
		"lore": "An eccentric inventor whose pocket watch still ticks despite having no hands."
	},
	"the_headless_traveller": {
		"name": "The Headless Traveller",
		"icon": "🎩👻",
		"rarity": "Rare",
		"personality": "Stoic",
		"mood": "Weary",
		"preference": "Cold rooms",
		"dislikes": "Crowded halls",
		"lore": "A tireless wanderer who has crossed forgotten roads for centuries in search of one peaceful night."
	},
	"the_bell_twins": {
		"name": "The Bell Twins",
		"icon": "🔔👻👻",
		"rarity": "Rare",
		"personality": "Mischievous",
		"mood": "Excited",
		"preference": "Music rooms",
		"dislikes": "Being separated",
		"lore": "Two inseparable spirits who announce their arrival with bells that ring from empty corridors."
	},
	"banshee_beatrice": {
		"name": "Banshee Beatrice",
		"icon": "📣👻",
		"rarity": "Rare",
		"personality": "Dramatic",
		"mood": "Restless",
		"preference": "Dark rooms",
		"dislikes": "Bright light",
		"lore": "Beatrice insists she is not screaming; the hotel walls are simply too acoustically sensitive."
	},
	"little_lucien": {
		"name": "Little Lucien",
		"icon": "🧸👻",
		"rarity": "Uncommon",
		"personality": "Gentle",
		"mood": "Shy",
		"preference": "Cold rooms",
		"dislikes": "Loud guests",
		"lore": "A quiet young spirit who never travels without the same worn wooden toy."
	},
	"the_poltergeist": {
		"name": "The Poltergeist",
		"icon": "🪑👻",
		"rarity": "Rare",
		"personality": "Unruly",
		"mood": "Chaotic",
		"preference": "Dark rooms",
		"dislikes": "Rules",
		"lore": "Nobody knows its real name. Furniture begins moving several minutes before it enters the lobby."
	},
	"madame_umbra": {
		"name": "Madame Umbra",
		"icon": "🌘👑👻",
		"rarity": "Legendary",
		"personality": "Regal",
		"mood": "Severe",
		"preference": "Dark rooms",
		"dislikes": "Ordinary accommodation",
		"lore": "A legendary eclipse spirit whose arrival is said to mark the beginning of the hotel's most difficult nights."
	}
}

static func get_ghost(ghost_id: String) -> Dictionary:
	return GHOSTS.get(ghost_id, {})

static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for ghost_id in GHOSTS.keys():
		ids.append(str(ghost_id))
	return ids
