# Rendering Rules

## Quality Levels
- **Smoke test** (`-ql`): 480p15, use during development and iteration
- **Preview** (`-pql`): 480p15 with auto-open, for visual review
- **Final** (`-pqh`): 1080p60, for export and sharing
- **GIF** (`-pqh --format gif`): For inline previews and documentation

## Render Commands
```bash
# Always use the full path from project root
manim render -ql scenes/mathematics/<file>.py <SceneName>
manim render -pql scenes/mathematics/<file>.py <SceneName>
manim render -pqh scenes/mathematics/<file>.py <SceneName>
```

## Caching
- Manim caches partial movie files in `media/`
- Use `--disable_caching` when debugging render issues
- Never commit anything in `media/`

## LaTeX Rendering
- BasicTeX must be on PATH: `eval "$(/usr/libexec/path_helper)"`
- LaTeX intermediate files go to `media/Tex/`
- If a TeX error occurs, check `media/Tex/*.log` for details

## Export
- Final renders go to `media/videos/<filename>/<quality>/`
- GIFs go to `media/videos/<filename>/<quality>/`
- For sharing, copy to `exports/` (gitignored)
