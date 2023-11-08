# Demo

## Why is Erlang referenced by a Mix release?

Enter the dev shell:

```console
$ nix develop
```

Build the Mix release provided by this flake:

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

# 1. Try to search Erlang references without searching binary. And, as expected, nothing will be found.
$ rg "/nix/store/.*/erlang" result --files-with-matches

# 2. But, when searching binaries, something is found.
$ rg "/nix/store/.*/erlang" result --files-with-matches --binary
result/lib/elixir-1.15.7/ebin/elixir_parser.beam

# 3. Try to inspect the binary file with `strings`. And as we can see, Erlang is referenced.
$ strings result/lib/elixir-1.15.7/ebin/elixir_parser.beam | grep -i erlang
o/nix/store/g46c3h8lf3dxx5z7f8fmjvqfy0xdv9f6-erlang-25.3.2.7/lib/erlang/lib/parsetools-2.4.1/include/yeccpre.hrl
erlang
```

Then, due to [Automatic Runtime Dependencies](https://nixos.org/guides/nix-pills/automatic-runtime-dependencies#automatic-runtime-dependencies), Erlang is always included as runtime dependency.
