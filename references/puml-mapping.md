# PUML to VP Sequence Mapping

Use this reference when designing the parser, model, and layout.

## Source Priority

1. Project/assignment requirements.
2. `.puml` files as authoritative content.
3. PlantUML-rendered images as visual reference only.

Do not remove, rewrite, or invent messages to make layout easier.

## Participants

Map declarations:

- `actor "Host Player" as Host` -> VP interaction actor.
- `boundary GameUI` -> lifeline with `boundary` stereotype.
- `control TurnController` -> lifeline with `control` stereotype.
- `entity GameSession` -> lifeline with `entity` stereotype.
- `participant "BoardAction\n<<interface>>" as BoardAction` -> lifeline; if inside `Entity / Strategy`, treat as entity/strategy group.

If no alias exists, derive alias from display text by removing non-alphanumeric characters. Preserve display text, including line breaks where VP can render them.

## Layers

Map PUML boxes:

- `box "Boundary" #EFF6FF`
- `box "Control" #FFF7ED`
- `box "Entity" #ECFDF5`
- `box "Entity / Strategy" #ECFDF5`

Order lifelines left to right:

1. Actors.
2. Boundary.
3. Control.
4. Entity.
5. Entity / Strategy.
6. Other groups.

Create pale background rectangles for groups, send them to back, and use a `NOTE` or other text-stable VP element for visible group labels.

## Messages

Map message forms:

- `A -> B : text` -> call-style message.
- `A --> B : text` -> return-style/dashed message when VP supports it; otherwise preserve text and direction.
- `A -> A : text` -> self message.
- `<<create>>` in message text -> create message.
- `create X` before a message -> mark X as created by its next create-like incoming message.

Keep PUML order exactly. Use manual flat numbering: `1`, `2`, `3`, ...

## Lifeline Creation Semantics

For created objects, start the lifeline near the create message y coordinate. For pre-existing actors, boundary, control, and entity objects, start lifelines at the top.

If a created object is referenced before its create event, prefer content completeness and keep the lifeline visible enough to avoid broken connectors.

## Activations

Parse `activate X` and `deactivate X` as event ranges. Create one short VP activation bar per range.

Recommended behavior:

- Start activation at the received triggering message y coordinate.
- End activation after the explicit deactivate message or after the last related message if no deactivate exists.
- Disable VP auto-extension if it makes execution bars run through unrelated behavior.
- Allow long activations for UI/controller lifelines when the PUML explicitly leaves them active across a workflow.

## Combined Fragments

Map:

- `alt condition` / `else condition` / `end`
- `loop condition` / `end`
- `opt condition` / `end`
- `break condition` / `end`

Parser algorithm:

1. Maintain a stack of open fragments.
2. On fragment start, record kind, guard, and start message index.
3. On `else`, add operand guard and record operand start message index.
4. On every parsed message, add sender and receiver aliases to all open fragments.
5. On `end`, close the top fragment at the previous message index.

Layout algorithm:

- Covered lifelines are only the aliases observed inside the fragment.
- Bounds span `minX - padding` to `maxX + padding`.
- Height starts above the first enclosed message and ends below the last enclosed message.
- Operand shapes use branch start message indexes to place separators close to the actual branch boundary.

If VP native operand rendering is imperfect, keep the native combined fragment for semantics and use cautious bounds to avoid covering unrelated messages.

## Notes and Dividers

Map `note over A,B` to a VP note whose x range spans lifelines A through B. Bound note width so it does not cover unrelated diagram areas.

Map `== Later: ... ==` to a note-style divider or another text-stable VP element. Keep the text visible in exported PNG/SVG. Do not rely on primitive rectangle custom text for required labels.

## Known Pitfalls

- VP may auto-suffix duplicate classifier names (`GameUI5`). Avoid unnecessary classifier binding when readable lifeline names matter more.
- VP nested numbering may create `1.1.1...`; force manual single-level numbering.
- Rectangle `customText` can disappear from exports; use `NOTE` for required text.
- Fragment bounds that cover all lifelines look technically valid but are less precise; use actual covered lifelines.
- Screenshots are not real exports. Use VP command-line export for final PNG/SVG.
