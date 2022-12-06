{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    with import nixpkgs { inherit system; }; {
      devShells = {
        default = mkShell {
          name = "adventofcode";
          packages = [ gnumake ];
        };

        c = mkShell {
          name = "c";
          packages = [ clang-tools ];
        };

        go = mkShell {
          name = "go";
          packages = [ go gopls ];
        };

        nix = mkShell {
          name = "nix";
          packages = [ nix deadnix nil nixpkgs-fmt ];
        };
      };
    });
}
