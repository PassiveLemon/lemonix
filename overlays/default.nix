{ inputs, system, lib, ... }:
# Automatically create a package namespace for each input, if it outputs any
let
  inherit (lib) filterAttrs attrNames genAttrs;

  hasPackages = input: (input ? "packages") && (input.packages ? ${system});
  hasLegacyPackages = input: (input ? "legacyPackages") && (input.legacyPackages ? ${system});
  hasAnyPackages = input: (hasPackages input) || (hasLegacyPackages input);

  getPackages = input:
    if hasPackages input
    then input.packages.${system}
    else input.legacyPackages.${system};

  packages = final: prev:
    let filtered = filterAttrs (_: input: hasAnyPackages input) inputs;
    in genAttrs (attrNames filtered) (name: getPackages inputs.${name});
in
{
  nixpkgs = {
    overlays = [
      packages
    ];
  };
}

