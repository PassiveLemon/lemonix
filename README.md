# lemondots </br>
To be used on a NixOS system. </br>

The organization is more focused on system configurations rather than individual modules. Each host will have its configuration.nix (default.nix) as an extension to hardware modules and the lowest level system options. </br>

Next up is system.nix which contains the more root part of the system. It contains packages that are critical to almost any created user or manage the root of the system prior to user configurations. </br>

Last is the (user/s).nix. They simply just contain the options that manage most of the visual functionalities that a specific user may need. </br>

I'll try to use flakes to manage the hosts and users automatically in the future but I am waiting until they reach stable before I do that. For now, unused files are marked with .dis (short for discontinued.). They were created when I was testing stuff but stopped using. </br>

The modules are configs for other things that would complicate the host configs. Mainly just for modules that are imported and not from the flake. </br>

Pkgs are just my custom packages. </br>

<img src="desktop.png"> </br>
I will update the image every so often. </br>