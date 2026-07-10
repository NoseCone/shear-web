# Copilot Instructions for Shear-Web

This repository is an Ur/Web application. Prioritize correctness and compile-safe edits over broad refactors.

Primary guidance locations:
- Ur/Web coding guidance for source edits: `.github/instructions/urweb.instructions.md`
- Ur/Web language manual (markdown): `docs/reference/urweb_manual.md`

External local references (prefer local over web links when available):
- `../urweb` (language implementation)
- `../urweb/lib/ur` (Ur standard library sources)
- `../urweb/lib/js` (JavaScript runtime/library sources)
- `../bazqux-urweb` (large example app)
- `../upo` (large example app)

GitHub fallback references (when local paths are unavailable):
- `https://github.com/urweb/urweb`
- `https://github.com/typechecker/bazqux-urweb`
- `https://github.com/urweb/upo`

When generating or changing code:
- Prefer minimal diffs that preserve existing module structure and naming.
- Keep `.ur`/`.urs` interface alignment exact.
- Respect existing build flow from `Makefile` and `README.md`.
- If introducing non-trivial Ur/Web patterns, explain briefly in comments or commit notes.

Documentation handling:
- Keep durable, project-specific guidance in text files committed to this repo.
- Prefer markdown references for docs Copilot should use directly.
- Prefer local sibling repositories over GitHub URLs for examples and API usage patterns.
