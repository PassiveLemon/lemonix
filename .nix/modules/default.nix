{ config, pkgs, ... }:

{
  imports = [
    ./custom
    ./home
    ./system
  ];
}