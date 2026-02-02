{
  description = "Personal flake collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ysh-lsp.url = "github:czaplicki/oils/master?dir=editors/vscode-ysh";
  };
  outputs = {self, nixpkgs, ysh-lsp, ...}: {

    packages = ysh-lsp.packages;

    overlays.default = final: prev: {
      ysh-lsp = self.packages.${prev.system}.ysh-lsp;
    };
  };
}
