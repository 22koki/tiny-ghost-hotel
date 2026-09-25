# Tiny Ghost Hotel

A cozy-creepy haunted hotel management game built with Godot 4.6.

You run a mysterious old hotel that opens after midnight. Ghosts arrive with strange moods, preferences, and demands. Read their clues, assign them to the right rooms, earn Ghost Coins, build reputation, unlock forgotten wings, and survive increasingly chaotic night shifts.

## Current version

**v0.2 — Vintage Hotel Management Foundation**

## Core gameplay loop

1. Start a night shift.
2. Welcome supernatural guests at reception.
3. Read each ghost's clues, personality, and mood.
4. Assign them to the correct room before patience runs out.
5. Earn score, Ghost Coins, streak bonuses, and reputation.
6. Complete the shift and review the Night Ledger.
7. Upgrade and unlock hotel rooms.
8. Discover guests in the Ghost Book.
9. Start the next, harder night.

## Hotel progression

The hotel now has persistent progression for:

- Ghost Coins
- Current night
- Hotel reputation
- Room unlocks
- Room levels
- Ghost discoveries
- Guest room occupancy
- End-of-night summaries

## Rooms

The hotel contains 12 themed rooms:

- The Frost Chamber
- The Moonless Suite
- The Crimson Parlour
- The Whispering Library
- The Midnight Conservatory
- The Alchemist's Chamber
- The Portrait Gallery
- The Moonlight Suite
- The Séance Salon
- The Clockwork Quarters
- The Royal Haunt
- The Looking-Glass Room

Rooms unlock across later nights and can be upgraded using Ghost Coins.

## Ghost collection

There are currently 18 discoverable guests, including:

Frosty, Shade, Melody, Echo, Misty, Velvet, Wisp, Lord Nocturne, Lady Glimmer, Count Vesper, Mabel Mourning, Professor Cog, The Headless Traveller, The Bell Twins, Banshee Beatrice, Little Lucien, The Poltergeist, and Madame Umbra.

The Ghost Book records personality, mood, preferences, dislikes, rarity, and lore for spirits you have encountered.

## Special guest mechanics

Later guests introduce unique behavior:

- The Bell Twins reduce decision time.
- Banshee Beatrice drains patience faster.
- The Poltergeist shuffles room buttons.
- Count Vesper alters the Dark Room into his Blackout Suite.
- Madame Umbra appears as a Legendary Boss Guest and punishes mistakes more severely.

## Dynamic nights

Later nights include:

- Increasing guest counts
- Decreasing patience
- VIP guest unlocks
- New spirit unlocks
- Random hotel events
- Full Moon Rush
- Flickering Candles
- Heavy Fog

## Main screens

- Vintage Main Menu
- Reception / Night Shift
- Hotel Floor Map
- Ghost Book
- Night Ledger / End-of-Night Summary

## Visual direction

Tiny Ghost Hotel uses an old-world Victorian haunted-hotel style:

- Dark wood
- Brass and gold framing
- Candlelight
- Moonlight
- Aged parchment
- Velvet
- Fog
- Friendly supernatural characters

The goal is spooky and atmospheric without becoming gruesome.

## Running the game

1. Install Godot 4.6 or a compatible Godot 4.x version.
2. Clone this repository.
3. Open `project.godot` in Godot.
4. Run the project.

The configured main scene is:

`res://scenes/MainMenu.tscn`

## Project structure

```
assets/
scenes/
  MainMenu.tscn
  RoomsOverview.tscn
  GhostBook.tscn
  NightSummary.tscn
scripts/
  main_menu.gd
  game_state.gd
  room_catalog.gd
  rooms_overview.gd
  ghost_catalog.gd
  ghost_book.gd
  night_summary.gd
main.gd
main.tscn
project.godot
```

## Next ideas

Future versions can expand into:

- Guest queues
- Multi-room occupancy
- Cleaning and maintenance
- Staff ghosts
- Hotel decorations
- More boss nights
- Random room failures
- Guest relationships
- More supernatural room types
- Achievements
- Additional hotel wings

## Status

v0.2 is the first full hotel-management foundation. The original room-matching mini-game has now evolved into a persistent multi-night progression game.
