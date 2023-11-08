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
            ripgrep
          ];
        };
      });

      packages = forEachSupportedSystem
        ({ pkgs }:
          let
            pname = "demo";
            version = "0.1.0";
            src = ./.;
          in
          {
            demo = pkgs.beamPackages.mixRelease {
              inherit pname version src;
            };
          });
    };
}
