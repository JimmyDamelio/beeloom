# BEELOOM — Roblox game (lineage breeding, bee, pollination)
- Design doc: `docs/BEELOOM - Game Design Document.docx` (source of truth).
- The owner speaks French: reply in French.
- Skills in `.claude/skills/`: `roblox-*` (Luau/Studio/design), `caveman` (/caveman to save tokens). Sources: `.claude/skills/SOURCES.md`.
- Code: Rojo project (`default.project.json`), Luau in `src/`. Files are the source of truth, not Studio.
- Tests: `lune run tests/genetics.test.luau` (pure logic, no Studio). Run before every commit touching `Shared/`.
- Server decides every cross result; the client only displays.
- Studio MCP: `.mcp.json` uses Roblox Studio's built-in MCP server (Windows path); enable it in Studio: Assistant > ... > Manage MCP Servers. Rojo owns the code: edit files, not scripts via MCP.
