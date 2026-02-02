
{
  description = "Tree-sitter grammar for the YSH language";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # The source for the grammar
    ysh-src = {
      url = "github:danyspin97/tree-sitter-ysh";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ysh-src }: let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # This builds the .so and collects the .scm files
        tree-sitter-ysh = pkgs.tree-sitter.buildGrammar {
          language = "ysh";
          version = "0.1.0";
          src = ysh-src;
        };
        default = self.packages.${system}.tree-sitter-ysh;
      });

    overlays.default = final: prev: {
      # Standard nixpkgs pattern: add to the tree-sitter-grammars attribute set
      tree-sitter-grammars = prev.tree-sitter-grammars // {
        tree-sitter-ysh = self.packages.${final.system}.tree-sitter-ysh;
      };
    };
  };
}
