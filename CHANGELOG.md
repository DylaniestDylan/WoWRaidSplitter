# Changelog

All notable changes to the WoW Raid Splitter addon will be documented in this file.

## [1.0.0] - 2025-07-29

### Added
- Initial release of WoW Raid Splitter addon
- Party-specific raid warning functionality
- `/wrs party <number> <message>` command to send warnings to specific parties
- `/wrs exclude <parties> <message>` command to send warnings to all except specified parties
- `/wrs list` command to display current raid composition
- Permission checking (raid leader/assist only)
- Raid detection (must be in raid, not just party)
- Support for up to 8 parties (40-player raids)
- Whisper-based message delivery system
- Color-coded feedback messages
- Comprehensive help system
- Saved variables support for future configuration options

### Technical Features
- Uses standard WoW API functions for maximum compatibility
- Event-driven architecture for efficient operation
- Proper error handling and user feedback
- Modular code structure for easy maintenance and expansion

### Commands Added
- `/wrs` - Primary command alias
- `/raidsplit` - Alternative command alias
- Full help system with examples and usage instructions
