# Contributing to dweee/Handy

This is the `dweee/Handy` fork. Open issues, feature requests and pull requests
here, targeting `nix/darwin` unless the owner requests another branch.

Owner-requested maintenance and features can proceed directly. Agents may write
code, generate descriptions and submit pull requests. Human-authored paragraphs,
manual website submission, upstream community approval and upstream feature-freeze
exceptions are not prerequisites in this fork.

## Development

See [BUILD.md](BUILD.md) for platform dependencies and model setup, and
[AGENTS.md](AGENTS.md) for architecture, conventions and agent guidance.

Common commands:

```sh
bun install
bun run tauri dev
bun run build
bun run lint
bun run format:check
cargo fmt --manifest-path src-tauri/Cargo.toml --check
cargo clippy --manifest-path src-tauri/Cargo.toml
```

Run the checks appropriate to the changed code and report their results. Include
relevant Rust/frontend tests and native builds for application changes. For
configuration or documentation changes, validate the affected configuration,
formatting and links. State any checks that were unavailable or not run.

## Preparing and submitting changes

Keep each change focused. Preserve upstream authors and ancestry, unrelated work,
and this fork's contribution policy when synchronizing upstream changes.

Describe the problem and resulting behavior, then give validation results and any
remaining limitations. The [PR template](.github/PULL_REQUEST_TEMPLATE.md) is an
optional outline. Links to related work and screenshots are useful when relevant;
no ceremonial checklist or separate human-written section is required.

Search [this fork's issues](https://github.com/dweee/Handy/issues) and
[pull requests](https://github.com/dweee/Handy/pulls) when it helps avoid duplicate
work. Reports, feature requests and free-form maintenance tasks are welcome in
this fork's issues. Only submit to `cjpais/Handy` when the owner explicitly asks;
that repository has its own contribution process.

## License

Contributions retain the project's [MIT license](LICENSE).
