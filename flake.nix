{
  description = "Personal flake collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ysh-lsp.url = "github:czaplicki/oils/master?dir=editors/vscode-ysh";
    nu-lint.url = "git+https://codeberg.org/wvhulle/nu-lint";
    tree-sitter-ysh.url = "path:./tree-sitter-ysh";

  };
  outputs = inputs@{self, ...}: let

    # Aliases -----------------------------------------------------------------
    lib = inputs.nixpkgs.lib;

    # Helpers -----------------------------------------------------------------

    # Takes a list of packages output from inputs
    # and merges to a single packages output, ignoring default pkgs
    # mergePackagesSets :: [ packagesSet ] -> packagesSet
    mergePackagesSets = let

      # Throw on invaild attrsets of packages
      # vet :: { <pkg-name> = <pkg> } -> { <pkg-name> = <pkg> }
      vet = pkgs: let
          count = builtins.length (builtins.attrNames pkgs);
        in if count == 0 then
          throw "Empty package set!"
        else if count == 1 && pkgs ? "default" then
          throw "Only contains default package!"
        else pkgs;

      # Merges a list of attsets of packages
      # mergePkgs :: [ { <pkg-name> = <pkg> } ] -> { <pkg-name> = <pkg> }
      mergePkgs = builtins.foldl' (
          acc: vlu: acc // removeAttrs (vet vlu) [ "default" ]
      ) {};

    in builtins.zipAttrsWith (_: mergePkgs);

    # Returns a new packages set only containing specified package
    # extractPackage :: string -> packagesSet -> packagesSet
    extractPackage = pkgName: builtins.mapAttrs
      (_: lib.filterAttrs (name: _: name == pkgName));

    # Renames a package in a packages set
    # renamePackage :: string -> string -> packagesSet -> packagesSet
    renamePackage = oldName: newName: let
      updateName = name: if name == oldName then newName else name;
      in  builtins.mapAttrs
      (_: lib.mapAttrs' (name: lib.nameValuePair (updateName name)));

    # Extract and exports the default package in a packages set as given name
    # Note: only the defualt package is included the returned packages set!
    # exportdefaultAs :: string -> packagesSet -> packagesSet
    exportDefaultAs = name: pkgsSet:
      renamePackage "default" name (extractPackage "default" pkgsSet);

  in {

    packages = mergePackagesSets [
      inputs.ysh-lsp.packages
      inputs.tree-sitter-ysh.packages
      (exportDefaultAs "nu-lint" inputs.nu-lint.packages)
    ];

    overlays.default = final: prev: {
      nu-lint = self.packages.${prev.system}.nu-lint;
      ysh-lsp = self.packages.${prev.system}.ysh-lsp;
      tree-sitter-grammars = prev.tree-sitter-grammars // {
        tree-sitter-ysh = self.packages.${prev.system}.tree-sitter-ysh;
      };
    };
  };
}
