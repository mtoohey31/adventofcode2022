{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

    lean4 = {
      url = "github:leanprover/lean4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, lean4 }:
    utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; }; {
        devShells = {
          default = mkShell {
            name = "adventofcode";
            packages = [ gnumake ];
          };

          c = mkShell {
            name = "c";
            packages = [ clang-tools valgrind man-pages man-pages-posix ];
          };

          go = mkShell {
            name = "go";
            packages = [ go gopls ];
          };

          lean4 = mkShell {
            name = "lean4";
            packages = [ lean4.packages.${system}.lean-all ];
          };

          nim = mkShell {
            name = "nim";
            packages = [ nim nimlsp ];
          };

          nix = mkShell {
            name = "nix";
            packages = [ nix deadnix nil nixpkgs-fmt ];
          };

          prolog = mkShell {
            name = "prolog";
            packages = [ swiProlog ];
          };

          rust = mkShell {
            name = "rust";
            packages = [ cargo rustc rust-analyzer rustfmt ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        };
      });
}
