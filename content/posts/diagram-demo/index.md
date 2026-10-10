---
title: Diagram demo
date: 2026-10-10
draft: true
summary: Sample diagrams rendered at build time. Delete this folder once you have real ones.
---
A Mermaid flowchart, rendered to SVG when the site is built:

{{< diagram src="flow" alt="A flowchart: a diagram source goes to the render script, then to light and dark SVG files, then through the Hugo build to a static page." caption="From source to static page." >}}

A Vega-Lite bar chart, rendered the same way:

{{< diagram src="trend" alt="A bar chart of sample build times in milliseconds: Parse 120, Layout 340, Draw 210, Write 45." >}}
