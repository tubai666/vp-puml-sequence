# Visual Paradigm OpenAPI Reference

Use this reference when writing or modifying a Visual Paradigm plugin that converts PUML sequence diagrams into `.vpp`.

Official sources to check when details matter:

- VP sequence diagram guide: https://www.visual-paradigm.com/support/documents/vpuserguide/94/2577/7025_creatingsequ.html
- VP OpenAPI sequence example: https://knowhow.visual-paradigm.com/openapi/sequence-diagram/

## Diagram Creation

Create a native interaction diagram:

```java
DiagramManager dm = ApplicationManager.instance().getDiagramManager();
IInteractionDiagramUIModel diagram =
    (IInteractionDiagramUIModel) dm.createDiagram(IDiagramTypeConstants.DIAGRAM_TYPE_INTERACTION_DIAGRAM);
diagram.setName(title);
IFrame root = diagram.getRootFrame(true);
```

Attach the diagram to a model:

```java
IModel model = IModelElementFactory.instance().createModel();
model.setName("Generated sequence diagrams");
model.addSubDiagram(diagram);
```

## Numbering

VP can produce nested numbers such as `1.1.1...`. Force flat numbering:

```java
diagram.setShowSequenceNumbers(true);
diagram.setSequenceNumberHandling(IInteractionDiagramUIModel.MANUAL);
diagram.setSequenceNumbering(IInteractionDiagramUIModel.SINGLE_LEVEL);
diagram.setRequestRecalculateSequenceNumbers(false);
```

Set each message number manually:

```java
msg.setSequenceNumber(Integer.toString(seq++));
```

## Lifelines, Actors, Activations

Create actors for PUML `actor`; create interaction lifelines for boundary/control/entity/participant.

```java
IInteractionLifeLine life = IModelElementFactory.instance().createInteractionLifeLine();
life.setName(displayName);
life.addStereotype(kind);
root.addChild(life);
IDiagramElement shape = dm.createDiagramElement(diagram, life);
shape.setBounds(x, startY, width, height);
shape.resetCaption();
```

Avoid binding duplicate classifiers if it causes VP to suffix names. If the submitted diagram cares about readable lifeline names more than classifier traceability, lifeline names alone are acceptable.

Create explicit activations:

```java
IActivation activation = IModelElementFactory.instance().createActivation();
life.addActivation(activation);
IDiagramElement activationShape = dm.createDiagramElement(diagram, activation);
activationShape.setBounds(x, y, activationWidth, activationHeight);
```

Disable auto-extension when explicit `activate/deactivate` ranges should control execution bars:

```java
diagram.setShowActivations(true);
diagram.setAutoExtendActivations(false);
```

## Messages

Create messages in PUML order and connect shapes at the calculated y coordinate:

```java
IMessage msg = IModelElementFactory.instance().createMessage();
msg.setName(text);
msg.setSequenceNumber(Integer.toString(seq++));
msg.setType(create ? IMessage.TYPE_CREATE_MESSAGE :
    self ? IMessage.TYPE_SELF_MESSAGE : IMessage.TYPE_MESSAGE);
msg.setFromActivation(fromActivation);
msg.setToActivation(toActivation);
IDiagramElement connector = dm.createConnector(
    diagram, msg, fromShape, toShape,
    new Point[] {new Point(fromX, y), new Point(toX, y)}
);
connector.resetCaption();
```

Use `TYPE_CREATE_MESSAGE` for `<<create>>` messages, and start the created lifeline near that message.

## Combined Fragments

VP's UI documentation says combined fragments cover selected messages, and covered lifelines can be added or removed to extend or narrow the covered area. Mirror that in OpenAPI.

```java
ICombinedFragment fragment = IModelElementFactory.instance().createCombinedFragment();
fragment.setInteractionOperator(ICombinedFragment.INTERACTION_OPERATOR_LOOP);
fragment.addCoveredLifeLine(lifelineA);
fragment.addCoveredLifeLine(lifelineB);
fragment.addOperand(operand);
ICombinedFragmentUIModel shape =
    (ICombinedFragmentUIModel) dm.createDiagramElement(diagram, fragment);
shape.setBounds(x, y, width, height);
shape.addChild(operandShape);
shape.resetCaption();
```

Create operands with guards:

```java
IInteractionOperand operand = IModelElementFactory.instance().createInteractionOperand();
IInteractionConstraint guard = IModelElementFactory.instance().createInteractionConstraint();
guard.setName(guardText);
guard.setConstraint(guardText);
operand.setGuard(guard);
```

Map `alt`, `loop`, `opt`, and `break` to VP interaction operators.

## Layers, Notes, Dividers

Use primitive rectangles for non-text-critical group backgrounds:

```java
IDiagramElement layer = dm.createDiagramElement(diagram, IShapeTypeConstants.SHAPE_TYPE_RECTANGLE);
layer.setBounds(x, y, width, height);
layer.setBackground(color);
((IShapeUIModel) layer).sendToBack();
```

Use `NOTE` for labels, dividers, and PUML notes when text must appear in exported PNG/SVG:

```java
INOTE note = IModelElementFactory.instance().createNOTE();
note.setName(text);
note.setDocumentation(text);
root.addNOTE(note);
IDiagramElement noteShape = dm.createDiagramElement(diagram, note);
noteShape.setBounds(x, y, width, height);
noteShape.resetCaption();
```

Known caveat: primitive rectangle `setCustomText()` may appear blank in VP image exports. Do not rely on it for required text.

## Command-Line Execution

Direct Java invocation may be more reliable than VP wrapper scripts when the wrapper cannot locate Java.

Run plugin:

```bash
'/Applications/Visual Paradigm.app/Contents/Resources/jre.bundle/Contents/Home/bin/java' \
  -Xms256m -Xmx768m -Djava.awt.headless=false \
  -cp '.:../lib/vpplatform.jar:../lib/jniwrap.jar:../lib/winpack.jar:../ormlib/orm.jar:../ormlib/orm-core.jar:../lib/lib01.jar:../lib/lib02.jar:../lib/lib03.jar:../lib/lib04.jar:../lib/lib05.jar:../lib/lib06.jar:../lib/lib07.jar:../lib/lib08.jar:../lib/lib09.jar:../lib/lib10.jar:../lib/lib11.jar:../lib/lib12.jar:../lib/lib13.jar:../lib/lib14.jar:../lib/lib15.jar:../lib/lib16.jar:../lib/lib17.jar:../lib/lib18.jar:../lib/lib19.jar:../lib/lib20.jar' \
  com.vp.cmd.Plugin \
  -project "$PROJECT_VPP" \
  -pluginid "$PLUGIN_ID" \
  -pluginargs "$PUML_DIR"
```

Export images:

```bash
com.vp.cmd.ExportDiagramImage -project "$PROJECT_VPP" -out "$PNG_DIR" -diagram '*' -type png_with_background
com.vp.cmd.ExportDiagramImage -project "$PROJECT_VPP" -out "$SVG_DIR" -diagram '*' -type svg
```
