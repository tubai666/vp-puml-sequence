# Quality Checklist

Use this checklist before claiming a VP PUML sequence conversion is complete.

## Source Integrity

- `.puml` files were not modified unless explicitly requested.
- Every declared participant appears or is intentionally handled.
- Message order and message text are preserved.
- Notes, dividers, guards, and fragment conditions are preserved.
- PlantUML images were used only for visual comparison.

## VP Model Integrity

- The output `.vpp` is new/non-destructive and not an overwritten comparison project.
- `sqlite3 "$PROJECT_VPP"` confirms the expected count of `InteractionDiagram`.
- Key requirement texts or PUML texts exist in `MODEL_ELEMENT.DEFINITION`.
- Lifelines have readable names without unwanted suffixes such as `GameUI5`.
- Created lifelines start near create messages where practical.
- Sequence numbering is flat and manual.

## Diagram Semantics

- `alt`, `loop`, `opt`, and `break` use native VP combined fragments.
- Combined fragments cover actual participant lifelines, not the whole diagram by default.
- Operand guards are visible and aligned with branch boundaries.
- Activations follow explicit `activate/deactivate` ranges.
- Return messages are visually distinguishable where VP supports that.
- Boundary/Control/Entity groups are visible and behind the sequence content.

## Exports

- PNG files were exported by VP `ExportDiagramImage`.
- SVG files were exported by VP `ExportDiagramImage`.
- PNG count equals expected diagram count.
- SVG count equals expected diagram count.
- Exported SVG text has no repeated nested numbering such as `1.1.1`.
- Required divider/layer/note text appears in exports.

## Visual QA

Inspect at least:

- the first diagram;
- the most complex/nested fragment diagram;
- the last diagram.

Check that fragment boxes do not cover unrelated messages, notes do not hide core messages, layer backgrounds do not obscure connectors, and no VP command-line processes remain running.
