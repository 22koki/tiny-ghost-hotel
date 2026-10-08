# Contributing to Tiny Ghost Hotel

Tiny Ghost Hotel is a Godot 4 haunted hotel management game. Contributions that improve gameplay clarity, atmosphere, accessibility, and reliability are welcome.

## Workflow

1. Read [README.md](README.md) for the current gameplay loop and version.
2. Create a branch for one focused change.
3. Open the project in the Godot version documented by the repository.
4. Run the main scene and play through a night shift.
5. Open a pull request with the reason for the change, testing notes, and screenshots or a short clip for visual work.

## Godot-specific checks

- Keep scenes and script resource paths valid after renames.
- Watch for GDScript parser errors and ambiguous Variant type inference.
- Check that room assignment, guest patience, scoring, and shift progression still work.
- Test mouse and keyboard interactions at the target window size.
- Avoid introducing plugins or external assets with unclear licenses.
- When changing rendering or physics, note the Godot version and platform tested.

## Pull request checklist

- [ ] Game launches without parser errors
- [ ] One full night shift was tested
- [ ] No missing scene resources or broken asset paths
- [ ] New art/audio has appropriate license or attribution
- [ ] Screenshots included for UI or atmosphere changes

Keep the vintage, cozy-creepy identity while making the game readable and fun.
