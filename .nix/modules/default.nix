{ config, pkgs, ... }:

{
  imports = [
    ./customize
    ./program
    ./system
    ./utility
  ];
}