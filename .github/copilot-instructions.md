# Copilot Instructions for ZR_Ammo SourcePawn Plugin

## Repository Overview
This repository contains a SourcePawn plugin for SourceMod that provides infinite ammo functionality for human players in Zombie Reloaded game mode. The plugin is designed for Source engine games and integrates with the Zombie Reloaded framework to enhance gameplay mechanics.

## Project Structure
```
addons/sourcemod/scripting/ZR_Ammo.sp    # Main plugin source code
sourceknight.yaml                        # Build configuration and dependencies
.github/workflows/ci.yml                # CI/CD pipeline
```

## Technical Environment

### Language & Platform
- **Language**: SourcePawn
- **Platform**: SourceMod 1.11+ (configured for 1.11.0-git6934)
- **Build Tool**: sourceknight 0.2
- **Compiler**: Latest SourcePawn compiler via sourceknight

### Dependencies
- **sourcemod**: Core SourceMod framework (1.11.0-git6934)
- **zombiereloaded**: ZR plugin for zombie/human game mechanics
- **multicolors**: Enhanced chat color support

## Build System

### Building the Plugin
```bash
# Install sourceknight (if not available)
# Build the plugin
sourceknight build
```

The build system:
- Uses `sourceknight.yaml` for configuration
- Outputs compiled plugin to `/addons/sourcemod/plugins`
- Automatically handles dependencies via the configuration
- CI/CD runs on every push/PR using GitHub Actions

### Testing
- Test on a development server with SourceMod 1.11+
- Ensure Zombie Reloaded is loaded and functional
- Verify infinite ammo works for human players only
- Test special burst-fire weapons (Glock, FAMAS) for proper ammo restoration

## Code Style & Standards

### SourcePawn Conventions (This Project)
- Use `#pragma semicolon 1` and `#pragma newdecls required` (already implemented)
- Global variables prefixed with `g_` (e.g., `g_bInfAmmo`, `g_bInfAmmoEnabled`)
- Boolean arrays for per-client state management
- Event-driven architecture using SourceMod hooks

### Code Patterns Used
- **Client State Management**: `g_bInfAmmo[MAXPLAYERS + 1]` array for tracking player states
- **Event Handling**: Hooks for `weapon_fire`, `player_death`, `player_spawn`
- **Weapon Validation**: Proper checks for weapon slots and entity validity
- **Special Weapon Logic**: Custom burst-fire handling for Glock and FAMAS weapons

### Variable Naming
- Global variables: `g_` prefix, camelCase (e.g., `g_cvBots`)
- Local variables: camelCase
- Function names: PascalCase (following SourceMod convention)
- Constants: UPPER_CASE where applicable

## Plugin Architecture

### Core Functionality
The plugin operates by:
1. Tracking human players' infinite ammo state
2. Intercepting weapon fire events
3. Restoring ammunition after each shot
4. Handling special cases for burst-fire weapons

### Key Functions
- `OnPluginStart()`: Initialization, ConVar creation, event hooks
- `OnClientPutInServer()`/`OnClientDisconnect()`: Client state management
- `Event_WeaponFire()`: Core infinite ammo logic
- `IsValidClient()`: Client validation helper

### Integration Points
- **Zombie Reloaded**: Uses `ZR_IsClientZombie()` to exclude zombies
- **SourceMod Core**: Standard event system and ConVar management
- **MultiColors**: Available for enhanced chat messaging (if needed)

## Development Guidelines

### When Making Changes
1. **Preserve Core Logic**: The weapon fire event handler is the heart of the plugin
2. **Client State**: Always reset `g_bInfAmmo[client]` on disconnect/death
3. **Weapon Validation**: Maintain checks for weapon slots (primary/secondary only)
4. **Burst Fire Logic**: Special handling for Glock/FAMAS burst modes is critical
5. **Performance**: Minimize operations in frequently called events like `weapon_fire`

### Common Modifications
- **New Weapons**: Add special cases in `Event_WeaponFire()` if needed
- **Configuration**: Use ConVars for new settings, following the `g_cv` prefix pattern
- **Admin Commands**: Follow the `sm_` prefix convention for commands

### Error Handling
- Always validate client indices and entity handles
- Use `IsValidClient()` for client validation
- Check `IsValidEntity()` before manipulating weapons
- Verify game state (alive, not zombie) before processing

## Memory Management
- Client arrays are automatically managed by SourceMod
- No dynamic memory allocation in this plugin
- Event handles are managed by SourceMod framework

## Version Control
- Current version: 3.0 (defined in plugin info)
- Use semantic versioning for releases
- CI/CD automatically creates releases from tags

## Testing Checklist
When modifying the plugin:
- [ ] Plugin compiles without errors
- [ ] Infinite ammo works for human players
- [ ] Zombies do not receive infinite ammo
- [ ] Burst-fire weapons (Glock/FAMAS) work correctly
- [ ] Plugin loads/unloads cleanly
- [ ] ConVars function as expected
- [ ] Admin commands work with proper permissions

## Performance Considerations
- `Event_WeaponFire` is called frequently - keep logic minimal
- Client state arrays are O(1) access
- Weapon property access is optimized by caching active weapon
- Early returns prevent unnecessary processing

## Common Issues
- **Weapon Detection**: Some custom weapons may need special handling
- **Burst Fire**: Ensure proper ammo restoration for burst modes
- **Client State**: Reset state properly on player events to prevent issues
- **ZR Integration**: Verify ZR is loaded before using ZR natives

## File Organization
This is a single-file plugin by design. If expanding functionality:
- Keep core logic in `ZR_Ammo.sp`
- Consider includes for shared utilities if creating multiple related plugins
- Follow SourceMod directory structure for any additional files