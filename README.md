# template-formula

A skeleton to copy when starting a new formula. It follows the
[saltstack-formulas](https://github.com/saltstack-formulas) layout
conventions and does nothing useful on its own — the package, user,
group and service it defines are placeholders.

## Starting a new formula from this

1. Copy the directory and rename it (`cp -r template mynewthing`).
2. Rename the top-level `template:` key in `defaults.yaml`, and the
   `import template` in `init.sls`, to `mynewthing`.
3. Replace the placeholder package/user/service values in
   `defaults.yaml` and `osfamilymap.yaml`.
4. Write real states in `init.sls`, splitting them into
   `install.sls` / `config.sls` / `service.sls` once there's enough to
   warrant it.
5. Replace this README and `pillar.example`.

`map.jinja` derives the formula name from `tpldir`, so it needs no
editing.

## The map cascade

`map.jinja` builds a single settings dict by merging, lowest to highest
priority:

```
defaults.yaml
  -> osarchmap.yaml     (grain: osarch)
  -> osfamilymap.yaml   (grain: os_family)
  -> osmap.yaml         (grain: os)
  -> osfingermap.yaml   (grain: osfinger)
  -> pillar <formula>:lookup
  -> pillar <formula>
```

Every layer deep-merges onto the one below, so a pillar author only ever
has to specify the keys they want to change. All five YAML files must
exist even if empty — `import_yaml` will fail on a missing file.

Put OS-specific facts (package names, config paths, service names) in
the `os*map.yaml` files. Put environment- and host-specific values in
pillar. Don't put either in `defaults.yaml`, or upgrading the formula
will clobber local customizations.

## Requisites

`init.sls` demonstrates the ordering convention worth keeping: file
order in an SLS does *not* guarantee execution order — requisites do. The
service `require`s its package and its user; add a `watch` on any config
file state you introduce so the service restarts when config changes.

## Usage

```yaml
# top.sls
base:
  '*':
    - template
```

See `pillar.example` for the settings the placeholder states read.

## Relationship to upstream

**This is a heavily modified fork of
[`saltstack-formulas/template-formula`](https://github.com/saltstack-formulas/template-formula). Do not treat it as a drop-in
replacement for it.**

States have been renamed, split, merged, and removed; pillar keys have moved;
defaults differ; and behaviour has changed in ways that are not backward
compatible. Pointing an existing deployment at this formula without reading
`pillar.example` and the state list above will not do what you expect.

It is also not a newer version of upstream — it diverged and was maintained
separately, so upstream may well have fixes and platform support that this
does not. If you want the maintained original, use
[`saltstack-formulas/template-formula`](https://github.com/saltstack-formulas/template-formula).

### Credit

The foundation of this formula, and much of what still works well in it, is
the work of the [saltstack-formulas](https://github.com/saltstack-formulas) authors and contributors. Any
bugs introduced in the divergence are this fork's own.

## License

Dedicated to the public domain under [CC0 1.0 Universal](LICENSE).
