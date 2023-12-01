# Demo

- This branch is a solution for the issues shown in `main` branch of this repo.
- This branch is using a Nixpkgs which is patched with <https://github.com/NixOS/nixpkgs/pull/271288>.

## Usage

Enter the dev shell:

```console
$ nix develop
```

After entering the dev shell, build the Mix release provided by this flake:

```console
$ nix build '.#demo'
```

Search the files that references Erlang in nix store:

```console
# beamPackages.mixRelease is searching the Erlang references in this way:
#
#   rg "${erlang}/lib/erlang" "$out" --files-with-matches
#
# It seems good, but it won't search the references in binaries.
#
# References:
# + https://github.com/plastic-forks/nixpkgs/blob/aef16f9cb42290dca27588d6229a668740a79296/pkgs/development/beam-modules/mix-release.nix#L150
#

# 1. Try to search Erlang references without searching binary.
$ rg "/nix/store/.*/erlang" result --files-with-matches
result/erts-13.2.2.4/bin/start

# Comments:
# That's expected. Because <https://github.com/NixOS/nixpkgs/blob/fcbfef1e431e5fcdd400a7650b04a11699ebdb38/pkgs/development/beam-modules/mix-release.nix#L139> is removed by the commit <https://github.com/NixOS/nixpkgs/commit/993c8f162dec33b826fd0eaf4f80b6284e0e5e63>.
# We can add it later.


# 2. When searching binaries, something is found.
$ rg "/nix/store/.*/erlang" result --files-with-matches --binary
result/lib/elixir-1.15.7/ebin/elixir_parser.beam
result/erts-13.2.2.4/bin/start

# Comments:
# All the dependecies like floki, or fast_html, don't contain references to erlang. Because
# they have been compiled in deterministic way. THIS IS GOOD!
# But, Elixir isn't compiled in a determinstic way. That's why it is still listed here.


# 3. Try to inspect .beam binary file with `strings`. And as we can see, Erlang is referenced.
$ strings result/lib/elixir-1.15.7/ebin/elixir_parser.beam | grep -i erlang
o/nix/store/g46c3h8lf3dxx5z7f8fmjvqfy0xdv9f6-erlang-25.3.2.7/lib/erlang/lib/parsetools-2.4.1/include/yeccpre.hrl
erlang
```

Due to [Automatic Runtime Dependencies](https://nixos.org/guides/nix-pills/automatic-runtime-dependencies#automatic-runtime-dependencies), Erlang is always included as a runtime dependency.

## What we should do?

1. add the [logic for `result/erts-13.2.2.4/bin/start`](https://github.com/NixOS/nixpkgs/blob/fcbfef1e431e5fcdd400a7650b04a11699ebdb38/pkgs/development/beam-modules/mix-release.nix#L139) back.
2. build Elixir in deterministic way.

Then, it should work as we expected. ;)
