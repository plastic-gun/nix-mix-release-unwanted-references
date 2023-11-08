# Demo

## About the demo app

The demo app is highly customized for demonstrating following issues. Its Mix release will include three types of files:

1. text files
2. `.beam` binary files
3. other binary files

## Usage

Enter the dev shell:

```console
$ nix develop
```

## Lab 1: Why is Erlang referenced by a Mix release?

### Let's see why

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

# 1. Try to search Erlang references without searching binary. And, as expected, nothing will be found.
$ rg "/nix/store/.*/erlang" result --files-with-matches

# 2. But, when searching binaries, something is found.
$ rg "/nix/store/.*/erlang" result --files-with-matches --binary
result/lib/elixir-1.15.7/ebin/elixir_parser.beam
result/lib/floki-0.35.2/ebin/floki_selector_lexer.beam
result/lib/fast_html-2.2.0/priv/fasthtml_worker.dSYM/Contents/Resources/DWARF/fasthtml_worker

# 3. Try to inspect .beam binary file with `strings`. And as we can see, Erlang is referenced.
$ strings result/lib/elixir-1.15.7/ebin/elixir_parser.beam | grep -i erlang
o/nix/store/g46c3h8lf3dxx5z7f8fmjvqfy0xdv9f6-erlang-25.3.2.7/lib/erlang/lib/parsetools-2.4.1/include/yeccpre.hrl
erlang

# 4. Try to inspect other binary file with `strings`. And as we can see, Erlang is referenced.
$ strings result/lib/fast_html-2.2.0/priv/fasthtml_worker.dSYM/Contents/Resources/DWARF/fasthtml_worker | grep -i erlang
/nix/store/g46c3h8lf3dxx5z7f8fmjvqfy0xdv9f6-erlang-25.3.2.7/lib/erlang/erts-13.2.2.4/../lib/erl_interface-5.3.2/include
```

Due to [Automatic Runtime Dependencies](https://nixos.org/guides/nix-pills/automatic-runtime-dependencies#automatic-runtime-dependencies), Erlang is always included as a runtime dependency.

### Can we substitute Erlang related nix store path in the generated files?

We mentioned three types of files above:

1. text files - it's easy to substitute them, and [current implementation](https://github.com/NixOS/nixpkgs/blob/d9cc44b51e9b333fd67e2c77eda010cc6c9552cc/pkgs/development/beam-modules/mix-release.nix#L148) takes effects on them.
2. `.beam` binary files - it's hard to substitute them, because `.beam` is special, you can't use `patchelf`, or `bbe` on them directly.
3. other binary files - `bbe` works on them. We can use something like this:

```bash
for file in $(rg "${erlang}/lib/erlang" "$out" --files-with-matches --binary --iglob '!*.beam'); do
  echo "removing reference to erlang in $file"
  # use bbe to substitute strings in binary files, because using substituteInPlace
  # on binaries will raise errors
  bbe -e "s|${erlang}/lib/erlang|$out|" -o "$file".tmp "$file"
  rm -f "$file"
  mv "$file".tmp "$file"
done
```

In a nutshell, we can't substitute Erlang related nix store path in _all the generated files_, in an easy way.

So, it seems that **we can't remove Erlang reference from Mix release closure**.
