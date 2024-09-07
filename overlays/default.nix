{ inputs, ... }:
let
  config = {
    allowUnfree = true;
  };
in
{
  packages = final: prev: {
    # Overlay use of a package on the nixos-(stable) branch. Mainly used for the system part of the setup.
    stable = import inputs.nixos { inherit (prev) system config; };
    # Overlay use of a package on the nixpkgs-unstable branch. Mainly used for the user part of the setup.
    unstable = import inputs.nixpkgs { inherit (prev) system config; };
    # Overlay use of a package on the master branch. Only used for packages that are not yet in the unstable or stable branch.
    master = import inputs.master { inherit (prev) system config; };
    # Overlay use of a package on a previous nixos-(stable) branch. Only used for packages that are broken or removed in newer branches.
    old = import inputs.nixos-old { inherit (prev) system config; };
    # Overlay use of a broken package.
    broken = import inputs.nixpkgs { 
      inherit (prev) system;
      config = prev.config // { allowBroken = true; };
    };
  };
}

