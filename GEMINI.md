# Gemini Home Assistant Configuration Context

## Directory Overview

This directory contains the configuration for a Home Assistant instance. It is used to automate and control a smart home. The configuration is written in YAML and is split across multiple files for organization.

## Key Files

*   `configuration.yaml`: The main entry point for the Home Assistant configuration. It includes other YAML files and defines the overall structure of the configuration.
*   `automations.yaml`: Contains a large number of automations for various tasks, including lighting, notifications, security, and occupancy detection.
*   `templates.yaml`: Defines custom template sensors and binary sensors. This includes a sophisticated multi-source presence detection system for "Neil," "Jaydon," and "Chloe," as well as sensors for tracking trash cans, laundry, and home occupancy.
*   `scripts.yaml`: Contains reusable scripts for tasks like arming/disarming the alarm, changing home modes, and sending notifications.
*   `scenes.yaml`: Defines various lighting scenes for different situations.
*   `secrets.yaml`: This file is not read, but it is assumed to contain sensitive information like API keys, passwords, and other credentials.
*   `packages/`: This directory contains "packages" which are self-contained bundles of configuration for specific features.
*   `custom_components/`: This directory contains custom integrations for Home Assistant.

## Usage

This directory is the central configuration for a Home Assistant instance. To make changes, you should edit the relevant YAML files and then either reload the configuration in Home Assistant or restart Home Assistant.

### Development Conventions

*   **Modularity:** The configuration is highly modular, with different domains and features split into separate files. This should be maintained when adding new features.
*   **Secrets:** All sensitive information should be stored in `secrets.yaml` and accessed using `!secret`.
*   **Automations:** Automations should be given a descriptive `alias`. Many automations are controlled by the `input_boolean.automations_enabled` switch.
*   **Templates:** Template sensors should be used to create derived values from other entities. The existing multi-source presence detection is a good example of a complex template sensor.
