---
title: Cordon
summary: A Crystal shard for running shell commands inside a platform-native sandbox, with a configurable access policy.
kinds: [library, cli]
status: active
repo: ModelArmy/cordon.cr
---

{{< diagram src="overview" alt="How Cordon works, an overview." float="right">}}

The `cordon.cr` project is primarily a Crystal shard for running shell commands inside a platform-native "cordon" or sandbox, with a configurable access policy. It is also ships a command-line tool to run system commands securely on any supported platform without needing to use the platform-specific tools.

Cordon is a thin translation layer. The core idea is that Linux (`bwrap`) and macOS (`sandbox-exec`) both let you wrap an arbitrary command in a sandbox — the same shape, different native languages. Cordon defines a platform-agnostic `Policy` that describes *what a process should be allowed to do*, and a `Runner` per platform that translates that policy into a native invocation.

