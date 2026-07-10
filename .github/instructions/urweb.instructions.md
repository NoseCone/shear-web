---
applyTo: "**/*.{ur,urs,urp}"
description: "Use Ur/Web-safe editing patterns and preserve interface/implementation compatibility."
---

# Ur/Web File Instructions

Use these rules for Ur/Web source files.

## Type and Signature Safety

- Keep `.urs` signatures synchronized with corresponding `.ur` implementations.
- Avoid changing public signatures unless required by the task.
- Prefer explicit helper values when type inference becomes ambiguous.

## Monadic and Transaction Style

- Use normal transaction sequencing style used in this codebase.
- Do not introduce `let ... end` patterns where existing code uses direct `<-` sequencing.

## JSON and FFI Patterns

- Follow the established `Json.json_derived` usage style used in this repository.
- Reuse existing FFI and parsing patterns before introducing new wrappers.
- Keep C FFI boundary changes minimal and aligned with existing build targets.

## Scope of Changes

- Prefer small, local edits and avoid broad stylistic rewrites.
- Add short comments only where control flow or type intent is not obvious.
