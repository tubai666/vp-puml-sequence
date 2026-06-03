# Source Requirements to PlantUML

Use this reference when the user wants VP sequence diagrams but has no `.puml` files yet.

## Goal

Create reviewable PlantUML sequence diagrams from project requirements, code, or design notes before generating Visual Paradigm `.vpp`. The generated PUML becomes the transparent intermediate source for VP conversion.

## Source Priority

1. Explicit project/assignment requirements.
2. Existing code behavior and public APIs.
3. User-provided screenshots, UI flows, or domain notes.
4. Clearly marked assumptions.

Never silently invent messages to make a diagram look complete. If a required detail is missing, either infer conservatively from code/requirements and label it as an assumption, or ask the user when the choice changes the scenario.

## Scenario Selection

Create one sequence diagram per meaningful workflow:

- one user goal, use case, or assignment-required scenario per diagram;
- split long workflows when a later phase has a different responsibility or actor;
- avoid mixing unrelated happy paths and error-handling paths unless they belong in one `alt` fragment.

Name diagrams with stable numeric prefixes when the project has multiple required diagrams:

```text
01-start-game-part-1.puml
02-start-game-part-2.puml
03-player-movement.puml
```

## Participant Modeling

Use UML analysis stereotypes:

- `actor` for external users or systems.
- `boundary` for UI, API endpoints, views, screens, CLI, or adapters.
- `control` for use-case coordinators, controllers, services, or orchestrators.
- `entity` for domain objects, repositories, records, stores, game/session state, and persistent concepts.

Group participants with PUML `box` blocks:

```plantuml
box "Boundary" #EFF6FF
boundary GameUI
end box

box "Control" #FFF7ED
control GameSetupController
end box

box "Entity" #ECFDF5
entity GameSession
end box
```

Use aliases for long or multiline labels:

```plantuml
entity "Player\n(guessing)" as GuessingPlayer
```

## Message Rules

Use messages that represent meaningful responsibility transfer, not every low-level line of code.

- Solid call: `A -> B : doWork(input)`.
- Dashed return: `B --> A : result`.
- Self call: `A -> A : validate()`.
- Create object: include `create X` before the create message, or use `<<create>>` in the message text.
- Keep message names close to project vocabulary and code method names when available.

Preserve chronological order. Avoid crossing arrows caused only by poor participant order; reorder participants by actor, boundary, control, and entity instead.

## Activation Rules

Add explicit activations for major execution spans:

```plantuml
A -> Controller : start()
activate Controller
Controller -> Entity : query()
activate Entity
Entity --> Controller : data
deactivate Entity
Controller --> A : done
deactivate Controller
```

Do not keep entity activations alive for the whole diagram unless the entity is truly executing for that span.

## Fragment Rules

Use combined fragments when requirements describe alternatives, loops, optional behavior, or early termination:

```plantuml
alt input is invalid
  Controller --> UI : showError()
else input is valid
  Controller -> Entity : save()
end

loop for each item
  Controller -> Entity : process(item)
end

opt optional condition
  Controller -> Service : optionalStep()
end

break terminal error
  Controller --> UI : stopFlow()
end
```

Keep fragment guards specific and traceable to requirements. Do not use vague guards like `[success]` if the requirement states the real condition.

## Notes and Dividers

Use notes for assumptions, rule summaries, or requirement traceability that should remain visible:

```plantuml
note over Controller, Entity
This interaction follows requirement R3:
players are checked in clockwise order.
end note
```

Use dividers for separated later phases:

```plantuml
== Later: skipped player's next turn ==
```

## Review Before VP Conversion

Before converting derived PUML to VP:

- Check every diagram maps to a requirement or scenario.
- Check actor/boundary/control/entity responsibilities are not mixed.
- Check every branch/loop/optional path has a meaningful guard.
- Check created objects are represented with create semantics.
- Check assumptions are documented in notes or in the response.
- Render with PlantUML if available and inspect for obvious sequence issues.

Then proceed through `puml-mapping.md` and `vp-openapi.md`.
