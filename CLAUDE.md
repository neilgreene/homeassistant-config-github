# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Home Assistant configuration repository running version 2026.2.1. The setup uses a **modular YAML architecture** where the main `configuration.yaml` acts as a hub that includes separate files for each domain (automations, sensors, scripts, etc.). This allows for better organization and maintainability of the large configuration (95 automations, ~5,900 lines in automations.yaml).

## Architecture

### Core Configuration Pattern

The repository follows a **split configuration** pattern:
- `configuration.yaml` - Main hub that includes all other files
- `automations.yaml` - All automation definitions (95 automations)
- `templates.yaml` - Template sensors and binary sensors (~1,100 lines)
- `sensors.yaml` - Platform-based sensors (MQTT, REST, command_line)
- `scripts.yaml` - Reusable script definitions
- `secrets.yaml` - Sensitive credentials (never commit changes to this)
- Additional includes: `calendars.yaml`, `geolocations.yaml`, `groups.yaml`, `input_booleans.yaml`, `input_selects.yaml`, `input_text.yaml`, `intent_script.yaml`, `lights.yaml`, `scenes.yaml`, `switches.yaml`, `yahoofinance.yaml`
- `packages/` - Directory for feature-bundled packages (currently empty, but wired via `!include_dir_named`)

### Categorization System

Automations use a **prefix-based categorization** in their aliases:
- `[LIGHTING]` - Light control automations
- `[CALENDAR]` - Calendar event notifications
- `[OCCUPANCY]` - Room occupancy detection
- `[SECURITY]` - Security and alarm management
- `[CLIMATE]` - HVAC and climate control
- `[MONITOR]` - System monitoring and error logging
- `[NOTIFICATION]` - Alert and announcement systems
- `[CAMERA]` - Camera motion and recording control
- `[DOOR SENSOR]`, `[WINDOW SENSOR]`, `[GATE SENSOR]` - Entry monitoring
- `[GARAGE]` - Garage door automation
- `[MEDIA]` - Media player control
- `[REMINDER]` - Scheduled reminders
- `[SCHEDULE]` - Time-based automations
- `[MODE]` - Home mode changes (Normal/Guest/Vacation)
- `[DO NOT DISTURB]` - DND announcements per room
- `[LAUNDRY]` - Washer/dryer monitoring
- `[TRACKING]` - Person/device tracking
- `[MEDICATION]` - Medication reminders
- `[ACCESS]` - Access control
- `[TAG SCANNED]` - NFC tag automations
- `[WATCHDOG]` - System watchdog automations
- `[BUG]` - Bug workarounds/fixes

When creating or modifying automations, **always use the appropriate category prefix** in the alias.

### Key Integrations

**Custom Components** (18 total in `custom_components/`):
- `alexa_media` - Alexa device control and TTS
- `ms365_calendar` - Microsoft 365 calendar integration
- `area_occupancy` - Room occupancy tracking
- `person_location` - Enhanced person tracking
- `ai_automation_suggester` - AI-based automation suggestions
- `hacs` - Home Assistant Community Store
- `watchman` - Entity monitoring for missing/unavailable entities
- `bermuda` - Bluetooth-based presence detection
- `yahoofinance` - Stock price tracking
- `scrypted` - Camera integration
- `dyson_local` - Dyson device integration
- Others: `ha_strava`, `teamtracker`, `cync_lights`, `hubspace`, `unifi_voucher`, `hass_agent`, `custom_areas`

**ESPHome Devices** (in `esphome/`):
- 4 bed presence sensors (pressure-based detection)
- 1 voice assistant device

**Zigbee2MQTT** (in `zigbee2mqtt/`):
- Configured for Zigbee device integration via MQTT

### Template Architecture

Templates in `templates.yaml` provide derived states:
- **Binary Sensors**: Door status aggregation, room occupancy (all/any/none), home occupied/unoccupied, Alexa integration status
- **Sensors**: Occupancy counts, garage door duration, uptime tracking, current mode

### Automation Global Kill Switch

**Critical**: Most automations check `input_boolean.automations_enabled` before executing. This is a global kill switch for debugging. When this is `off`, most automations will not run.

### Error Monitoring System

The configuration includes a custom **automation error logging system**:
- `system_log` integration set to `fire_event: true` broadcasts log events to the event bus
- Automations tagged `[MONITOR]` capture ERROR/WARNING events
- Shell commands write to `/config/logs/automation_failures.log`
- Script `scripts/update_failures.sh` maintains recent failures view
- This system exists because `notify.file` integration is broken (see HA core issue #132555)

### Secrets Management

All sensitive values (passwords, API keys, tokens) are stored in `secrets.yaml` and referenced using `!secret key_name`. **Never hardcode credentials in configuration files.**

## Common Commands

### Configuration Validation
```bash
# Check YAML syntax (run from HA container or CLI)
ha core check
```

### Reloading Configuration
After editing configuration files, reload the relevant sections via Home Assistant Developer Tools > YAML:
- **Automations**: Developer Tools > YAML > Automations
- **Scripts**: Developer Tools > YAML > Scripts
- **Template Entities**: Developer Tools > YAML > Template Entities
- **Full Restart**: Required for `configuration.yaml` changes

### Checking Logs
```bash
# View current log
tail -f home-assistant.log

# View automation failures
tail -f logs/automation_failures.log

# View ESPHome logs (if running locally)
tail -f esphome/<device-name>.log
```

### ESPHome Management
```bash
# Compile and validate ESPHome config
esphome compile esphome/<device-name>.yaml

# Upload to device
esphome upload esphome/<device-name>.yaml

# View device logs
esphome logs esphome/<device-name>.yaml
```

### Zigbee2MQTT
Configuration is managed through the Zigbee2MQTT web interface or by editing `zigbee2mqtt/configuration.yaml`.

## Development Guidelines

### Adding New Automations

1. Add to `automations.yaml` (not via UI, to maintain version control)
2. Use appropriate category prefix in alias: `[CATEGORY]: Description`
3. Include condition checking `input_boolean.automations_enabled` for most automations
4. Set a meaningful `id` (timestamp-based IDs are auto-generated by UI)
5. Reload automations via Developer Tools

### Adding Template Sensors

1. Add to `templates.yaml` under appropriate section
2. Use meaningful `unique_id` for persistence
3. Include comments explaining complex Jinja2 logic
4. Reload template entities after changes

### Working with Scripts

Scripts in `scripts.yaml` follow these patterns:
- **Helper scripts**: Reusable sequences called by multiple automations (e.g., `arm_ring_alarm`, `disarm_ring_alarm`)
- **Notification scripts**: Alexa/mobile notification wrappers
- Use `fields` to define parameters for reusable scripts
- Reference secrets using `!secret key_name`

### Modifying Custom Components

Custom components in `custom_components/` are typically managed by HACS. To update:
1. Use HACS UI for updates when available
2. For manual updates, replace the component directory and restart HA
3. Check component documentation in its subdirectory for specific requirements

## Important File Locations

- **Logs**: `/config/logs/automation_failures.log`
- **ESPHome secrets**: `esphome/secrets.yaml` (separate from main secrets.yaml)
- **Zigbee2MQTT config**: `zigbee2mqtt/configuration.yaml`
- **Lutron certificates**: `lutron_caseta-*.pem` (in root)
- **Database**: `home-assistant_v2.db` (SQLite)

## System Behavior Notes

### Ring Alarm Integration
- All arm/disarm operations require the code from `!secret ring_alarm_code`
- Helper scripts `arm_ring_alarm` and `disarm_ring_alarm` handle this logic
- Morning disarm includes optional Alexa announcement via `alexa_morning_disarm_notify`

### Alexa Integration
- Uses `alexa_media` custom component
- Check `binary_sensor.alexa_notify_available` before sending notifications
- Device-specific notify services: `notify.upstairs_office_show_announce`, `notify.kitchen_show_speak`, etc.

### Presence Detection (Multi-layered)
- Bluetooth via Bermuda/MQTT (room-level via `mqtt_room` sensors)
- `person_location` custom component for enhanced tracking
- Bed presence via ESPHome pressure sensors
- Stable presence binary sensors in templates (per-person)

### Home Modes
- Managed via `input_select.home_mode`
- Options: Normal Mode, Guest Mode, Vacation Mode
- Script `cycle_home_mode` rotates through modes
- Template sensor `sensor.current_mode` provides current state
