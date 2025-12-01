---
"hex": minor
---

Replace double-tap lock with tap-to-toggle recording mode

- Simplify hotkey state machine from 3 states to 2 states (idle, recording)
- Add RecordingMode enum with holdToRecord and tapToToggle options
- In tap-to-toggle mode: single press starts, single press stops (release ignored)
- Add guard to block new recording while transcription is still in progress
- Extend minimum hold time slider range from 2s to 5s for accessibility
- Show minimum hold time slider for all hotkey types (not just modifier-only)
- Migrate existing useDoubleTapOnly setting to new recordingMode automatically
