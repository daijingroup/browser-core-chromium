# Contributing

Changes to this repository must preserve the `browser-core` boundary defined by `daijingroup/browser-spec`.

## Before adding code

Confirm that the change belongs in the neutral Chromium integration layer.

Use another repository when the change is:

- derived from Brave or another external browser project → `browser-community-derived-chromium`;
- a KiTech product feature or service integration → `browser-kitech-derived-chromium`.

## Chromium changes

Prefer Chromium-supported extension points over patches.

When a direct Chromium patch is required:

- keep it minimal;
- document why the patch is necessary;
- keep unrelated changes out of the patch;
- record the Chromium revision it was validated against;
- reassess it on every Chromium rebase.

## Dependencies

`browser-core-chromium` MUST NOT depend on either upper-layer repository.

New third-party dependencies must have their licence and purpose reviewed before inclusion.

## Commits

Keep commits small and scoped. Do not combine Chromium rebases, feature work, formatting, and unrelated refactors in one change.

## Security

Do not commit credentials, signing material, recovery keys, user data, or production secrets.
