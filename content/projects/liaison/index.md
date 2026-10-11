---
title: Liaison
summary: A Crystal shard for applications that talk to LLMs, anchored by a portable session history that starts a conversation with one provider and continues it with another.
kinds: [library]
status: active
repo: ModelArmy/liaison.cr
---

Every LLM vendor stores a conversation in its own shape. Anthropic keeps signed `thinking` blocks, OpenAI's Responses API keeps encrypted reasoning items, and Gemini pairs tool calls by position rather than by id. Move a conversation from one to another and something is lost, usually quietly.

{{< diagram src="handoff" alt="A conversation exported from Ollama as a canonical session, resumed on Anthropic, with a report returned alongside the reply to say what the handoff cost." float="right">}}

Liaison keeps the conversation in one canonical, portable form and translates at the edges. Translation is not always lossless, so Liaison's job is to be honest about the cost: every call returns a report of what the handoff changed.

## What you get

**One session, any provider.** A session is plain data. `Archive` turns it into a JSON string and back, and where it is stored is up to you. Start on a local Ollama, save, and resume on Anthropic:

```crystal
alias M = Liaison::MPSH

File.write("vienna.json", M::Archive.write(session))

session = M::Archive.read(File.read("vienna.json"))
session << M::Message.user("Now recommend a coffee house.")

anthropic = Liaison::Server.new("anthropic",
  "https://api.anthropic.com", ENV["ANTHROPIC_API_KEY"])
provider = Liaison::Provider.for(anthropic,
  Liaison::ProtocolKind::Anthropic)

client = Liaison::Client.new(provider)
reply, report = client.send(session, "claude-haiku-4-5")
```

Four protocols are covered: Anthropic Messages, Chat Completions (which also reaches Ollama), Responses and Gemini. Azure OpenAI works as a deployment of Chat Completions or Responses.

**Losses are reported, and capped by policy.** `send` returns the reply and a report. Each translation is graded `Exact`, `Restructured`, `Compensated`, `Degraded` or `Refused`, and a policy sets the worst grade you will accept: `Strict`, `Compensating` (the default) or `Lenient`. A `Refused` mapping is never sent, so a handoff that cannot be done fails loudly. Whatever was degraded is also recorded on the session and travels with it in the archive.

```crystal
Liaison::Client.new(provider, Liaison::Capability::Policy::Strict)
```

**The usual breakages are handled.** Streaming works on all four protocols. A tool loop built on `Toolbox` gives every call a result, including calls to unknown tools and tools that raise, because a session holding a call without its result is one providers reject. A reply cut off by a dropped stream or an output cap is mended by `Repair.repaired`, which drops the unfinished calls and keeps the text.

**Nothing else to install.** Liaison has no runtime dependencies, and none are planned.

## Limits

As of version 0.2.2:

- The README warns that the shard is a work in progress. Expect the API to change before 1.0.
- Anthropic, Gemini and Azure OpenAI have recorded runs against the real services. Chat Completions and Responses are otherwise exercised only against Ollama's compatible endpoint, and OpenAI's own API has not been tested directly.
- Gemini disregards `ToolChoice::None` once a conversation holds a tool call, and the report does not say so. Check the reply.
- Forcing a tool call (`ToolChoice::Required`) is not offered yet. Only `Auto` and `None` are.

## Next

The [README](https://github.com/ModelArmy/liaison.cr#readme) covers streaming, tool loops and policies in full. [MPSH_SPECIFICATION.md](https://github.com/ModelArmy/liaison.cr/blob/main/docs/MPSH_SPECIFICATION.md) explains why the canonical session is shaped as it is, and [SCOPE.md](https://github.com/ModelArmy/liaison.cr/blob/main/SCOPE.md) lists what is outstanding.
