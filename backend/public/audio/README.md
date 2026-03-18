# Ambient Audio Files

Place the three ambient track files here. These are served at `/static/audio/<filename>` by the Fastify static plugin.

## Required files

The filenames must match exactly (note the `_20` encoding for spaces):

| File | Track name | Source |
|------|-----------|--------|
| `Clean_20Soul.mp3` | Relax | Kevin MacLeod — "Clean Soul" (incompetech.com) |
| `Meditation_20Impromptu_2001.mp3` | Deep Focus | Kevin MacLeod — "Meditation Impromptu 01" |
| `Long_20Note_20Four.mp3` | Night Reflection | Kevin MacLeod — "Long Note Four" |

## Download

All Kevin MacLeod tracks are free under CC BY 4.0 (attribution required).
Download from: https://incompetech.com/music/royalty-free/

Attribution (add to About screen or credits):
> Music by Kevin MacLeod (incompetech.com) — Licensed under Creative Commons: By Attribution 4.0 License

## Notes

- Files must be MP3 (not WAV or OGG) — `just_audio` handles cross-platform MP3 reliably.
- The Flutter app streams from the deployed backend URL — files are NOT bundled in the APK.
- After adding files here, redeploy the backend to Render (`git push origin main`).
- The ambient audio button appears in the feed header. Tap it to open the track selector.
