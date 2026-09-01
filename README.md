# Feather Toolkit

Reusable, client-side utility contracts for future Feather resources. Toolkit uses named exports, result envelopes, bounded model loading, per-resource ownership, and automatic cleanup.

Contract 1 includes models, objects, peds, blips, named control resolution, key listeners, prompts, 2D/3D text, and clipboard access. Teleport, horses, and wagons remain domain-owned. All stateful handles belong to the resource that created them; cross-resource mutation is rejected and owned handles are released when that resource stops.

Start the resource with `ensure feather-toolkit`. Run `ToolkitServerContractSmokeTest` in the server console and `ToolkitContractSmokeTest` in F8 after startup. Run `ToolkitClipboardSmokeTest optional text` in F8 and paste elsewhere to verify clipboard delivery.

Consumers should call the named exports directly and inspect every result envelope. Toolkit intentionally does not expose an initiate object or compatibility bridge.

Key listeners default to edge-triggered `just_pressed` behavior. Pass `pressed` only when a callback is intentionally expected every frame while the control is held.
