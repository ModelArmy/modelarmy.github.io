---
title: Cordon
summary: A Crystal shard for running shell commands inside a platform-native sandbox, with a configurable access policy.
kinds: [library, cli]
status: active
repo: ModelArmy/cordon.cr
---

Software that runs other software normally hands the child everything the parent can reach: the home directory, SSH keys, the network. That is true of an agent harness executing system commands chosen by an LLM, and of a build step running a downloaded script. Every major operating system provides a way to manage and prevent that, but each in its own dialect:

- Linux: Bubblewrap flags
- macOS: Seatbelt profiles
- Windows 11: a process security environment

{{< diagram src="overview" alt="Cordon turns a platform-agnostic Policy, through a platform-specific Runner, into a native sandbox invocation that runs the child process." float="right">}}

Learning, writing and testing all three has little to do with the thing you are building. Cordon is a portable translation layer for running commands more safely. You describe what a process may read, write and reach, and Cordon turns that into the native sandbox for the host.

## What you get

**One policy, every platform.** The same few lines run on each supported system.

```crystal
policy = Cordon::Policy.build do |p|
  p.read_only "/opt/mytools"
  p.read_write "/tmp/workspace"
end
result = Cordon.run(["/opt/mytools/some-tool", "--flag"], policy)
```

**Nothing unless granted.** An empty policy allows no paths, no network and no extra environment variables. It does not even allow the command you asked to run: naming a binary is not permission to execute it. Presets for Homebrew, system binaries, Ruby and Python (including virtualenvs and version managers) are merged in rather than listed by hand, and they only ever add permissions.

**Proof that it works on this host.** An installed sandbox tool is not the same as an enforcing one. Kernel settings, AppArmor profiles (Ubuntu's default restricts the user namespaces Bubblewrap needs) or a container can leave the tool present but ineffective, and some failures exit `0` without confining anything. `cordon confirm` runs real probes: a read that should be denied, one that should be allowed, and an outbound connection that should be blocked. `cordon inspect` prints the native invocation without running it, for audit.

```sh
cordon confirm
cordon run --python-venv .venv -- python3 script.py
```

## Limits

As of version 0.7.1:

- macOS and Linux are tested. Windows 11 is a preview, built on Microsoft's MXC. It needs a recent Windows 11 25H2 update, and Windows Server is not supported.
- Network access is on or off for the whole process. There is no per-host filtering.
- On macOS, a policy's `env` and `unset_env` are ignored ([#24](https://github.com/ModelArmy/cordon.cr/issues/24)).
- Cordon relies on `sandbox-exec`, which Apple has marked deprecated. It still works, but a future macOS release could remove it.
- The `cordon` command-line tool has no release binaries yet. Build it from source ([DEVELOPMENT.md](https://github.com/ModelArmy/cordon.cr/blob/main/DEVELOPMENT.md)); if you already build Crystal projects, you have what it needs.

## Next

The [README](https://github.com/ModelArmy/cordon.cr#readme) covers policies, presets and relaunching your own process inside a cordon. [DEVELOPMENT.md](https://github.com/ModelArmy/cordon.cr/blob/main/DEVELOPMENT.md) explains the design.
