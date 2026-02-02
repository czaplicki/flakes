{
  description = "Personal flake collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ysh-lsp.url = "github:czaplicki/oils/master?dir=editors/vscode-ysh";
    tree-sitter-ysh.url = "path:./tree-sitter-ysh";
  };
  outputs = inputs@{self, ...}: {

    packages = inputs.ysh-lsp.packages
            // inputs.tree-sitter-ysh.packages;

    overlays.default = final: prev: {
      ysh-lsp = self.packages.${prev.system}.ysh-lsp;
      tree-sitter-grammars = prev.tree-sitter-grammars // {
        tree-sitter-ysh = self.packages.${final.system}.tree-sitter-ysh;
      };
    };
  };
}
