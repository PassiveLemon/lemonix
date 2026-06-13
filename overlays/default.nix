{ inputs, system, ... }: {
  packages = final: prev: {
    # Overlay use of a package on the nixos-(stable) branch. Mainly used for the system part of the setup.
    stable = import inputs.nixos { inherit system; };
    # Overlay use of a package on the nixpkgs-unstable branch. Mainly used for the user part of the setup.
    unstable = import inputs.nixpkgs { inherit system; };
    # Overlay use of a package on the master branch. Only used for packages that are not yet in the unstable or stable branch.
    master = import inputs.master { inherit system; };
    # Overlay use of a package on the previous release.
    old = import inputs.nixos-old { inherit system; };
  };
}

