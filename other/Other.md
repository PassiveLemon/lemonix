Eval time tool by llakala:
```
nix shell nixpkgs#nixVersions.latest nixpkgs#inferno --command sh -c "nix eval .#nixosConfigurations.silver.config.system.build.toplevel --eval-profiler flamegraph && inferno-flamegraph --width 10000 < nix.profile > nixos.svg && firefox nixos.svg"
```

