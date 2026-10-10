# modelarmy.dev

Static site for the ModelArmy organisation, built with [Hugo](https://gohugo.io) (extended, v0.167.0 or later) and deployed to GitHub Pages. No JavaScript, no third-party requests.

## Preview

```sh
hugo server
```

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