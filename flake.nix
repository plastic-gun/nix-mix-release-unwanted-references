{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: with pkgs; {
        default = mkShell {
          buildInputs = [
            elixir
            gcc
            gnumake
            cmake

            ripgrep
          ];
        };
      });

      packages = forEachSupportedSystem
        ({ pkgs }:
          with pkgs;
          let
            pname = "demo";
            version = "0.1.0";
            src = ./.;

            mixFodDeps = beamPackages.fetchMixDeps {
              pname = "${pname}-mix-deps";
              inherit src version;
              sha256 = "sha256-dN+21nzsCFMUg9Hdvn1j/XyQZeXtIeTMgsixe2hTNwg=";
            };
          in
          {
            demo = beamPackages.mixRelease {
              inherit pname version src;
              inherit mixFodDeps;

              nativeBuildInputs = [
                gcc
                cmake
              ];
            };
          });
    };
}
