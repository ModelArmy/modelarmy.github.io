# ModelArmy site -- Session Handoff

Last verified 2026-10-10 against `main` at `993e557` (first-launch PR merged), plus the
Pages settings changes made afterwards. If `git log` shows newer commits, treat
"Where things stand" as possibly stale.

## Repository

https://github.com/ModelArmy/modelarmy.github.io

Clone the repo and read files before editing. Never edit stale in-memory copies.

Default branch is `main`. Work on a feature branch and open a PR: PRs build but
do not deploy; a push to `main` deploys to GitHub Pages at modelarmy.dev.

---

## Read these first, in the repo

1. `README.md` -- setup, adding projects, kinds, posts and diagrams, deploy, licensing.
2. `layouts/_shortcodes/diagram.html` -- the diagram contract (alt text required, float rules).
3. `assets/css/main.css` -- design tokens at the top (light and dark accent, code colours),
   then the wordmark rules (`.mark`, `.mark-sm`).
4. `scripts/render-diagrams.sh`, `scripts/diagrams.mjs`, `diagrams/*.json` -- the diagram pipeline and its themes.
5. `package.json` -- pinned dependencies and the `allowScripts` approval.
6. `.github/workflows/pages.yml` -- CI.
7. `content/projects/*/index.md` -- real examples of project front matter.

---

## Standing instructions

The owner's live instructions in a session override this file.

- Sync first: clone or fetch, then read the files you will touch.
- Do not assume facts that change (versions of Hugo, npm, GitHub Actions, browser
  behaviour). Check, and say plainly what could not be verified.
- Test before handing over: build from a fresh clone. For visual changes, capture
  light and dark at desktop and phone widths, and measure rather than eyeball.
- Deliver changes as a patch that applies to the current branch head, verified on a
  fresh clone, with a suggested one-line commit message. The owner commits and pushes.
- Pin dependencies. Avoid releases under 14 days old. Never run `npm audit fix --force`.
- No analytics, no third-party requests, and no popularity metrics (stars, counts,
  rankings) anywhere on the site.
- Accessibility floor: text contrast of at least 4.5:1, visible focus, reduced
  motion respected, alt text on every diagram.
- Code comments are minimal. Document how to use an API or what a function produces.
  Inside a function, describe steps only where they are not obvious. Never record
  change history in comments; that belongs in git.
- Diagrams in documentation are Mermaid, as standalone `.mermaid` files, with emphasis
  by coloured border only. Split a diagram that is too detailed into an overview plus
  zoomed views.
- Writing is matter-of-fact and concise. Prefer examples to abstraction, label
  decisions and questions, and number multi-step instructions.

### Working rhythm

1. Lay out the options with trade-offs and a recommendation. The owner decides.
2. For visual choices, render comparisons from the real site before asking.
3. Build, test, then deliver the patch and commit message.
4. The owner pushes a feature branch; the PR build must be green before merging.
5. After merging, check the Actions run and the live site.
6. Update this file when a decision or lesson changes.

---

## Where things stand (2026-10-10)

- **Site:** Hugo with a custom theme in the repo root. Hugo 0.167.0 is pinned in CI.
  Live at modelarmy.dev. The Pages source is GitHub Actions and the custom domain is
  verified, both set in repo settings (a root `CNAME` file also exists but is not needed).
- **Content:** three projects (Adjutant, Cordon, Liaison), one post ("About"), and
  a draft `diagram-demo` post that serves as a test bed.
- **Design:** the cleaved wordmark (large on the home page, small in the header),
  olive accent (`#55731c` light, `#a8bf7d` dark), self-hosted Archivo and Source
  Serif 4, light and dark following the OS.
- **Diagrams:** Mermaid and Vega-Lite render at build time to light and dark SVGs.
  `float="right"` places diagrams up to 360px wide in the margin on screens of 71rem
  or wider. Committed figures (for example from R) are supported by convention only.
- **Licensing:** each project keeps its own license; site code is MPL-2.0; site text
  under `content/` is all rights reserved. The footer and README say so.
- **Confirmed by the owner (2026-10-10):** `Deploy site` is green on `main`, the live
  site renders well in Firefox and Safari. Assistants cannot see Actions runs, macOS,
  or the deployed domain, so rely on the owner for anything about production.

### Open work

Track tasks as GitHub issues and link them here. At the time of writing:

- Confirm HTTPS is enforced in Pages settings.
- Replace or delete the `diagram-demo` post when real diagrams exist.
- Optional: the owner confirmed Firefox and Safari render the site well, but the
  feed-copy button, dark diagram switching and floated diagrams were developed and
  tested in Chromium only. Note any defect here if one turns up.
- R chart tooling: only the commit-the-SVGs convention exists. Build tooling when the first chart arrives.
- Accepted risk: five low-severity `npm audit` findings, all one KaTeX advisory reached
  through Mermaid. Not exploitable here (no untrusted math). Revisit when mermaid-cli
  raises its KaTeX range.

---

## Decisions

Each entry gives the reason and what was rejected, so it is not re-argued.

- **Custom theme, not an existing one.** The site is a catalogue. Blog and business
  themes assume posts, authors and dates, and would have been overridden anyway.
- **No popularity metrics.** Projects stand on their merits. The listing is
  alphabetical because that is the neutral order.
- **One entry per repo; `kinds` is a list; `related` links entries.** This matches how
  projects are actually built (library, CLI, or both in one repo). Filtering uses real
  URLs (`/kinds/library/`), not JavaScript.
- **Static, no JavaScript apart from the feed-copy button,** which degrades to a normal
  link. The site has to keep working when scripts do not.
- **Repo is `modelarmy.github.io`.** As an organization site, its custom domain also
  serves other repos' Pages at `modelarmy.dev/<repo>/`. Avoid repo names that collide
  with routes (`projects`, `posts`, `kinds`).
- **GitHub Pages over Digital Ocean.** One fewer system to run for a static site.
- **Diagrams are rendered at build time,** in two palettes (light and dark) chosen via
  `<picture>`. One render cannot serve both modes. They use Arial because an SVG shown
  as an image cannot load web fonts, and Arial's metrics match across platforms, so
  labels fit their boxes.
- **Olive accent, hue-aligned across modes.** It echoes the name; peridot, an olive
  crystal, keeps the shard theme. Dark mode uses a calmer tint to avoid glare.
- **Wordmark: the top half shifts,** not the bottom. The base looks grounded. The hero
  uses the larger offset; the header uses half, because small sizes exaggerate a step.
- **Dependencies:** versions pinned; `allowScripts` approves puppeteer only (it downloads
  Chromium); `canvas` is an alias for `@napi-rs/canvas` (prebuilt, no install script).
- **Licensing split:** project licenses stay with projects; site code MPL-2.0; site text
  all rights reserved. `content/` is the boundary.
- **`status: in development` means not ready to use, and the layout reacts to it:** a
  caution-coloured tag in the catalogue and the page header, a "Not ready to use"
  notice under the header, and no dependency snippet or install section. `active`
  keeps its meaning: usable but changing. Rejected: a label alone (small grey text
  that reads like "Active", and it wrapped in the catalogue column), and a blockquote
  note in the body (its green border reads as "go", it is absent from the catalogue,
  and the install section still invites use). The caution colour is amber because
  green signals go; contrast is 5.5:1 in light and 9.8:1 in dark. The value is
  matched as an exact string, so a misspelling shows no warning.

---

## Lessons carried forward

- Hugo skips future-dated content by default. A post dated tomorrow silently did not build.
- `_index.md` inside a project folder makes a section, not a page. Use `index.md`.
- Inside a Go-template `with`, `.` changes. Pass `$` to partials that need the page.
- npm 12 blocks dependency install scripts. Approve explicitly, and approve again after
  bumping puppeteer.
- A peer dependency range can pull a brand-new release. Pin puppeteer explicitly.
- `workflow_dispatch` needs the workflow file on the default branch, and the
  `github-pages` environment rejects deploys from other branches. Hence build-only PRs.
- Pages **Source** must be GitHub Actions. With "Deploy from a branch", GitHub runs its
  built-in "pages build and deployment" (Jekyll) workflow instead of ours. A
  `Create CNAME` commit in history is the tell.
- Hugo publishes unreferenced bundle files unless `publishResources = false`, which is set.
- File-event watchers miss editors that save by replacing the file. The diagram watcher polls.
- Assistants cannot run CI, macOS or other browsers. State what was and was not tested.

---

## About this file

- Keep it short. Link to the README, code and history rather than repeating them.
- Date it and name the commit it describes whenever it changes.
- Review edits as carefully as code. Both people and AI tools read it as instructions.