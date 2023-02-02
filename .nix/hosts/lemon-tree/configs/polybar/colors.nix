{ config, pkgs, ... }: {
  services.polybar.config = {
    "colors" = {
      # One Dark Pro
      odFor = "#abb2bf";
      odBac = "#282c34";

      #: black
      dBla = "#3f4451";
      lBla = "#4f5666";

      #: red
      dRed = "#e05561";
      lRed = "#ff616e";

      #: green
      dGre = "#8cc265";
      lGre = "#a5e075";

      #: yellow
      dYel = "#d18f52";
      lYel = "#f0a45d";

      #: blue
      dBlu = "#4aa5f0";
      lBlu = "#4dc4ff";

      #: magenta
      dMag = "#c162de";
      lMag = "#de73ff";

      #: cyan
      dCya = "#42b3c2";
      lCya = "#4cd1e0";

      #: white
      dWhi = "#d7dae0";
      lWhi = "#e6e6e6";
    };
  };
}