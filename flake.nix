{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

    lsp_server = {
      url = "github:jamesnvc/lsp_server";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, lsp_server }: utils.lib.eachDefaultSystem (system:
    with import nixpkgs { inherit system; }; {
      devShells = {
        default = mkShell {
          name = "adventofcode";
          packages = [ gnumake ];
        };

        c = mkShell {
          name = "c";
          packages = [ clang-tools valgrind ];
        };

        go = mkShell {
          name = "go";
          packages = [ go gopls ];
        };

        nix = mkShell {
          name = "nix";
          packages = [ nix deadnix nil nixpkgs-fmt ];
        };

        prolog = mkShell {
          name = "prolog";
          packages = [
            (swiProlog.override {
              extraPacks = [ "'file://${lsp_server}'" ];
            })
          ];
        };
      };
    });
}
