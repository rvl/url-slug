{
  description = "url-slug's description";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/3eb07eeafb52bcbf02ce800f032f18d666a9498d";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = nixpkgs.legacyPackages.${system};
        hp = pkgs.haskellPackages; # pkgs.haskell.packages.ghc921;
        project = returnShellEnv:
          hp.developPackage {
            inherit returnShellEnv;
            name = "url-slug";
            root = ./.;
            withHoogle = false;
            overrides = self: super: with pkgs.haskell.lib; {
              # Use callCabal2nix to override Haskell dependencies here
              # cf. https://tek.brick.do/K3VXJd8mEKO7
              relude = self.relude_1_0_0_1;
            };
            modifier = drv:
              pkgs.haskell.lib.addBuildTools drv
                (with  hp; pkgs.lib.lists.optionals returnShellEnv [
                  # Specify your build/dev dependencies here. 
                  cabal-fmt
                  cabal-install
                  ghcid
                  haskell-language-server
                  ormolu
                  pkgs.nixpkgs-fmt
                ]);
          };
      in
      {
        # Used by `nix build` & `nix run` (prod exe)
        defaultPackage = project false;

        # Used by `nix develop` (dev shell)
        devShell = project true;
      });
}
