# App Store assets — 2.3.0

## Uploaded to App Store Connect

| File | Slot |
|---|---|
| `preview_recorded_886x1920_upload.mp4` | App preview, Dynamic Island iPhone (7.4 MB re-encode of `preview_recorded_886x1920.mp4`, browser upload cap is 10 MB) |
| `header_loop_3840x1646.mp4` | Product page header (iOS 27 creative asset), 10 s seamless loop, muted |

Screenshots live in `fastlane/screenshots/ko/` (iPhone 6.9" 1320×2868, iPhone 6.3" 1206×2622,
iPad 13" 2064×2752). fastlane uploads them: the release lane (`fastlane ios upload isReleasing:true`)
and the screenshots-only lane (`fastlane ios screenshots`) both use `overwrite_screenshots`, so the
folder is the source of truth. The device slot comes from the resolution; previews are not touched.
Re-frame raw simulator shots with `python3 frame.py <raw_dir> <out_dir> <width> <height>`.

Also available: `header_3840x1646.png` (21:9 still) and `universal_5244x2950.png` (16:9, header + search).

## Rebuild

```bash
# 1. ad-free recording: Debug simulator build of the current source, then
src/take.sh path/to/App.app          # SIM_UDID=... to pick a simulator
# 2. re-check the cut points at the top of make_preview_recorded.sh against the new take
./make_preview_recorded.sh           # captions (make_captions.py) must be rendered first
python3 make_header.py               # still header + universal
python3 make_header_loop.py          # header loop video
```

- `src/fresh.sh` reinstalls the app and presets `LaunchCount = -5`; every ad gate needs `LaunchCount > 1`,
  so the take has no ads or ATT prompt. The random sheet's ad prompt still appears and is cut in editing.
- Narration: `narration.tsv` → `audio/NN.mp3` via edge-tts `ko-KR-SunHiNeural --rate=+8%`. The mp3s are
  cached so re-renders never call the service.
- Header safe areas: 21:9 → 1646×661 @ (1097,493); 16:9 universal → 1402×962 @ (1921,660).
  Keep the focal block inside, decoration outside; content must be 4+.
