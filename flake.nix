{
  description = "PHY407 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        python = pkgs.python3Full;
        pythonEnv = python.withPackages (ps: with ps; [
          pandas
          matplotlib
          numpy
          scipy
        ]);
      in
      {
        devShell = pkgs.mkShell {
          # Place pythonEnv first to ensure its bin directory is first in PATH
          buildInputs = with pkgs; [
            pythonEnv
            jupyter
            qt5.qtwayland
          ];
        };
      }
    );
}
