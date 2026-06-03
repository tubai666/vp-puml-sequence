---
name: vp-puml-sequence
description: Use when converting PlantUML/PUML sequence diagrams into Visual Paradigm .vpp projects through VP OpenAPI, preserving UML sequence semantics, generating Boundary/Control/Entity layers, activations, fragments, notes, numbering, and exporting real PNG/SVG images. Trigger for Visual Paradigm, VP OpenAPI, PUML-to-VPP, sequence diagram reproduction, real VP export, PNG/SVG export from .vpp, or fixing VP sequence diagram layout/numbering/fragment range issues.
---

# VP PUML Sequence

## Core Rule

Treat the `.puml` files and project requirements as the source of truth. Use PlantUML-rendered images only as visual references. When PUML and Visual Paradigm differ, preserve complete UML sequence semantics with VP-native tools rather than editing, deleting, or inventing content.

## Workflow

1. Inspect the PUML directory, assignment/project requirements, existing `.vpp` files, and prior exports before changing anything.
2. Read `references/puml-mapping.md` before designing the parser or layout.
3. Read `references/vp-openapi.md` before writing or modifying the VP plugin/command-line flow.
4. Parse PUML as an event stream, not only as messages. Preserve participant declarations, boxes, messages, creates, activations, fragments, operands, notes, and dividers.
5. Generate VP native interaction diagrams with lifelines, actors, messages, activations, combined fragments, operands, notes, and layer backgrounds.
6. Save to a new non-destructive `.vpp` such as `*-polished.vpp`; do not overwrite open, locked, or comparison `.vpp` files.
7. Export real PNG and SVG with VP `ExportDiagramImage`; do not use screenshots as final export artifacts.
8. Run `scripts/verify_vp_sequence_outputs.sh` and visually inspect representative PNGs before claiming completion.

## Hard Rules

- Do not modify `.puml` source unless the user explicitly asks.
- Do not use SVG/HTML-only reproduction when the deliverable is `.vpp`.
- Avoid VP auto nested numbering: force manual single-level sequence numbering.
- Avoid duplicate classifier binding when it causes names like `GameUI5`; lifeline names can stand alone.
- Use `ICombinedFragment.addCoveredLifeLine()` to narrow `alt`, `loop`, `opt`, and `break` fragments to the actual participating lifelines.
- Start created lifelines near their create message; pre-existing actors/boundary/control/entity lifelines start at the top.
- Follow explicit `activate`/`deactivate`; disable activation auto-extension when it over-stretches execution bars.
- Use VP `NOTE` shapes for text-critical labels/dividers because primitive rectangle custom captions may fail to export visibly.
- Keep layer backgrounds behind lifelines and connectors with `sendToBack()`.

## Implementation Shape

Prefer an event model with these records: `Participant`, `MessageSpec`, `ActivationRange`, `FragmentSpec`, `NoteSpec`, and `DividerSpec`.

For fragments, maintain a stack. On each parsed message, add sender and receiver aliases to every open fragment. On `else`, record an operand start message index. On `end`, close the top fragment. Compute fragment bounds from the min/max x positions of actual covered lifelines.

For layout, order actor lifelines first, then `Boundary`, `Control`, `Entity`, `Entity / Strategy`, then other groups. Use pale `box` colors for group backgrounds. Bound note width so it covers the referenced lifelines without hiding unrelated content.

For export, compile/install the VP plugin, copy a base `.vpp` into a new output file, run `com.vp.cmd.Plugin`, then run `com.vp.cmd.ExportDiagramImage` once for PNG and once for SVG.

## Verification

Use `references/quality-checklist.md` for acceptance criteria. At minimum, verify:

- expected count of `InteractionDiagram` in the `.vpp`;
- key text from requirements/PUML exists in VP model data;
- PNG and SVG export counts match the expected diagram count;
- exported SVG does not contain repeated nested numbering like `1.1.1`;
- first, most complex, and last diagrams visually preserve fragment ranges, layers, activations, notes, and dividers;
- no VP command-line processes remain running.
