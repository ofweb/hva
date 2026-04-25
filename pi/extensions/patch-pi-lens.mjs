// No patch needed as of pi-lens 3.8.32 — the lsp-navigation operation
// normalization (Type.Union → Type.String + normalizeOperation) was fixed
// upstream in apmantza/pi-lens@4c39d706.
//
// Keep this file around as a patch hook for future use.
// To re-enable patching: replace the body below with actual transforms.

const _extDir = process.argv[2] ?? "/hva/pi/extensions";
