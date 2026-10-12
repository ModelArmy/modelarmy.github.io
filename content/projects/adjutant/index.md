---
title: Adjutant
summary: A Ruby-like scripting interpreter for AI agent harnesses that limits what a script can reach and checks its risk before and while it runs.
kinds: [library]
status: in development
repo: ModelArmy/adjutant.cr
---

An AI agent that writes scripts can do more in one step than one that calls fixed tools: it can loop, branch and combine results. The cost is running code that nobody on your team wrote, with a model deciding what it says.

{{< diagram src="overview" alt="A script written by an AI agent is risk-assessed before it runs, and the user is asked only if the risk is high. It then runs in the interpreter with risk flow tracking its data. Every call to Legate is checked and logged, and the user is asked only if policy says ask, before the call reaches files, the network or the environment." float="right">}}

Adjutant is an interpreter for a deliberate subset of Ruby built for that situation. A script reaches files, the network, and the environment only through grants the host establishes in advance, and its risks are made visible twice: _before it runs_ and _while it runs_. It can also run the script in a separate process, so a defect in Adjutant costs a run rather than your host.

## What you get

**Scripts a model can write.** Adjutant ships a `SKILL.md` for the agent that writes the scripts. It lists the parts of Ruby that work and what to write instead of the rest, such as `Legate.read(path)` in place of `File.read(path)`, so the scripts a model generates fit the subset. Errors carry a code and a hint that names the fix. An exam in the repository checks whether a model can write working scripts from that file alone, and a spec keeps the file in step with the runtime.

**See the risk before anything runs.** Every native function the host exposes is registered with a risk profile: its effects, whether it can be undone, and how severe it is. Adjutant walks the script and reports which of those calls it could make, as a bound over every branch, so you can ask the user before running it. The body that was assessed is the body that runs, so nothing changes in between.

```crystal
body = File.open("script.rb") do |io|
  interp.parse(io, "script.rb")
end
tree = Adjutant::RiskWalker.new(interp).walk_body(body)
summary = Adjutant::RiskAggregator.summarize(tree)
interp.eval(body, "script.rb") if user_allows?(summary)
```

**Stop sensitive data on its way out.** Risk flow labels data with where it came from and how sensitive it is, follows it through assignments, arithmetic, strings, arrays and hashes, and applies your policy when it reaches a risky call: allow, ask or reject. That catches what static assessment cannot, such as a script that reads a credential and only sometimes sends it somewhere.

A policy can let a credential reach its own server and nowhere else, and combining it with another secret does not get it past:

```yaml
rules:
  - { authority: net, sensitivity: high, action: reject }
  - authority: net
    sensitivity: high
    action: allow
    priority: 10
    origin: { kind: env, pattern: STRIPE_KEY }
    subject: { pattern: "https://api.stripe.com:443" }
```

A policy must state its risk-flow choice: `none` is valid, but it is written down, never assumed. When the answer is `ask`, the question goes to your own code, which decides how to put it to a user.

{{< diagram src="call" alt="For each Legate call: if it is outside the grants, the run ends with an error that cannot be rescued. Otherwise risk-flow policy decides. Allow runs the call, and reject raises an error the script can rescue. Ask puts the question to the user, whose allow runs the call and whose reject raises the rescuable error." float="right">}}

**The world only through grants.** Scripts touch files, the network and the environment through Legate, Adjutant's standard library, and only as far as the host's grants allow: which roots, hosts, methods and environment variables, with limits per call and per run. The grants are fixed before the first line runs and cannot be escalated or delegated, so a call outside them is never put to the user. It ends the run with an error no script can rescue. Inside the grants, the risk-flow policy decides, and every outcome, allowed or not, is written to an audit log the host can read.

**Isolation from your host.** An interpreter that runs inside your process can take that process down: a crash, a hang or a runaway allocation in Adjutant becomes one in your agent harness. Adjutant can instead run each script in a worker, a second copy of your own executable, so a host that ships one binary still ships one binary. A `Supervisor` in the host drives the worker over its stdin and stdout, passes on what you must see or decide, and reports how the run ended. A worker that crashes, overruns its time or breaks the protocol is killed and reported as `Crashed`, `TimedOut` or `Violated`, and the host carries on.

```crystal
report = Adjutant::Supervisor.spawn.run(
  source, policy_yaml, ceiling: 15.minutes
) do |event|
  case event
  in Adjutant::Supervisor::Output
    ui.append(event.text)
  in Adjutant::Supervisor::Log
    log.info { event.message }
  in Adjutant::Supervisor::Ask
    event.answer(ui.decide(event.request))
  end
end
```

Events and outcomes are unions, so a `case … in` that misses one does not compile. The report keeps what the Supervisor saw for itself, such as exit status and time, apart from what the worker said, since a script that took over its worker could say anything.

An operating-system sandbox around the worker limits what such a defect could reach. Adjutant does not start one, but the Supervisor accepts any process with pipes, so [Cordon]({{< relref "/projects/cordon" >}}) 0.8.0 and later fits directly through `Cordon.spawn`. Together these make layers, each limiting what the one inside it can do:

{{< diagram src="layers" alt="Layers of protection, outermost first. The host, whose Supervisor can kill the worker. An optional operating-system sandbox, which limits what the worker can reach. The worker process, so a defect costs a run, not the host. The interpreter and Legate. At the centre, the script written by an AI agent." >}}

## Limits

Adjutant has not been released yet. As of `main` on 11 October 2026:

- It is a subset of Ruby, not Ruby, so a script written for full Ruby will not run unchanged. Left out by design: `eval` and `instance_eval`, calling a method by a computed name, reopening classes, `Class.new` and `Module.new`, and Ruby's own file, network and process classes (use Legate instead).
- Static assessment is best-effort. It reads the shape of calls, not the data, so a call made on a method parameter is reported as unresolved.
- Risk flow follows explicit data flow only: assignment, arithmetic, and building strings, arrays and hashes. It does not follow implicit flow through control structure.
- There is no approval cache yet, so an `Ask` for the same origin repeats every time it is reached within a run. A run is limited to 20 Asks by default (`max_asks`), and the Ask past the limit ends the run.
- The sandbox for a worker is the host's to set up. On macOS, a worker that a script has taken over could stall a run past its time limit, because a process it started can outlive the kill; it cannot escape the sandbox.
- A native function that needs the host's own state, such as a conversation or a credential store, cannot run in the worker yet.

## Next

The [README](https://github.com/ModelArmy/adjutant.cr#readme) walks through assessment, risk flow, policies and running scripts in a worker process. [POLICY.md](https://github.com/ModelArmy/adjutant.cr/blob/main/POLICY.md) and [LEGATE.md](https://github.com/ModelArmy/adjutant.cr/blob/main/LEGATE.md) cover the policy document and the standard library. [WORKER_DESIGN.md](https://github.com/ModelArmy/adjutant.cr/blob/main/research/WORKER_DESIGN.md) covers the worker protocol and what a host can trust from a worker. [UNSUPPORTED.md](https://github.com/ModelArmy/adjutant.cr/blob/main/UNSUPPORTED.md) explains what is excluded and why.
