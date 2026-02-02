{
  description = "Personal flake collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ysh-lsp.url = "github:czaplicki/oils/master?dir=editors/vscode-ysh";
    tree-sitter-ysh.url = "path:./tree-sitter-ysh";
  };
  outputs = inputs@{self, ...}: let

    # Takes the packages output from inputs
    # and merges to a singel packages output,
    # ingnoring default pkgs
    mergeInputPackages = let

      mergePkgs = builtins.foldl' (
          acc: vlu: acc // builtins.removeAttrs vlu [ "default" ]
      ) {};

    in builtins.zipAttrsWith (_: mergePkgs);

  in {

    packages = mergeInputPackages [
      inputs.ysh-lsp.packages
      inputs.tree-sitter-ysh.packages
    ];

    overlays.default = final: prev: {
      ysh-lsp = self.packages.${prev.system}.ysh-lsp;
      tree-sitter-grammars = prev.tree-sitter-grammars // {
        tree-sitter-ysh = self.packages.${final.system}.tree-sitter-ysh;
      };
    };
  };
}
