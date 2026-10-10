# modelarmy.dev

Static site for the ModelArmy organisation, built with [Hugo](https://gohugo.io) (extended, v0.167.0 or later) and deployed to GitHub Pages. No third-party requests. The only JavaScript is a few lines that copy the feed URL to the clipboard; the feed link works without it.

## Setup

```sh
brew install hugo node
npm ci
```

`npm ci` installs the diagram renderers at the versions in `package-lock.json`, including a copy of Chromium for Mermaid.

npm 12 blocks dependency install scripts unless `allowScripts` in `package.json` approves them. Only puppeteer is approved, because its install script downloads Chromium. After changing the puppeteer version, run `npm install-scripts approve puppeteer` and commit `package.json`.

## Preview

```sh
npm run dev
```

This renders the diagrams, then runs `hugo server -D` alongside a watcher that re-renders a diagram whenever its source changes. Plain `hugo server` also works, but does not re-render diagrams.

## Add a project

```sh
hugo new projects/<name>.md
```

Fill in the front matter. The file name is the project's slug.

| Field     | Meaning                                                       |
|-----------|---------------------------------------------------------------|
| `title`   | Repository or shard name                                      |
| `summary` | One sentence, shown in the catalogue                          |
| `kinds`   | `library`, `cli`, or both                                     |
| `status`  | `active`, `stable` or `archived`                              |
| `repo`    | `ModelArmy/<repository>`                                      |
| `docs`    | Optional URL of the API documentation                         |
| `shard`   | Optional shard name, if it differs from the file name         |
| `install` | Optional shell snippet for CLI projects                       |
| `related` | Optional list of project slugs; links are shown on both pages |

The body is the long description in Markdown. A library page shows a `shard.yml` dependency snippet; a CLI page shows `install` and a link to the releases.

## Diagrams

Diagrams are rendered to SVG at build time, so pages carry no diagram JavaScript. A post that uses them must be a folder (`posts/<slug>/index.md`).

1. Put the source beside `index.md`: `<name>.mmd` for Mermaid or `<name>.vl.json` for Vega-Lite.
2. Embed it with `{{< diagram src="<name>" alt="Describe the diagram" caption="Optional" >}}`. Alt text is required.
3. Run `npm run diagrams`, or let `npm run dev` do it. The SVGs land in `rendered/` beside the source, are ignored by git, and are rebuilt in CI before Hugo runs. Add `--force` to ignore the cache.

Each source is rendered twice, with the light and dark palettes in `diagrams/`, and the page picks one using `prefers-color-scheme`. Fonts are Arial because an SVG shown as an image cannot load the site's web fonts. In Mermaid, `class <node> emphasis` gives a node the accent border.

Wide diagrams scroll sideways on narrow screens rather than shrinking, so prefer `flowchart TD` for diagrams that must read well on a phone.

Figures produced elsewhere, such as R charts, are committed as `<name>.light.svg` and `<name>.dark.svg` directly beside `index.md` (not in `rendered/`), and use the same shortcode.

## Add a kind

Create `content/kinds/<kind>/_index.md` with `title`, `linkTitle` and a `weight` that sets its order in the filter. Add a matching shape for the kind in `assets/css/main.css` (`.glyph-<kind>`).

## Write a post

```sh
hugo new posts/<slug>.md
```

List the projects it concerns under `projects:` using their slugs. An unknown slug fails the build. Posts marked `draft: true` are not published, but remain visible in this public repository.

## Deploy

Pushing to `main` builds and deploys through `.github/workflows/pages.yml`. Pages must be set to deploy from GitHub Actions (Settings, Pages, Source).

## Fonts

Archivo and Source Serif 4, self-hosted under the SIL Open Font License. Licences are in `static/fonts/`.

## Licensing

Everything outside `content/` is under MPL-2.0 (see `LICENSE`), except the fonts in `static/fonts/`, which keep their SIL Open Font License. Text under `content/` is © 2026 ModelArmy contributors, all rights reserved.