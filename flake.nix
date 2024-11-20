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
          overlays = [
            (final: prev: {
              python311Packages = prev.python311Packages.override {
                # Use 'overrides' instead of 'packageOverrides'
                overrides = self: super: {
                  # Disable tests for websockets
                  websockets = super.websockets.overrideAttrs (oldAttrs: {
                    doCheck = false;
                  });
                };
              };
            })
          ];
        };

        # Use python from python311Packages instead of python311Full
        python = pkgs.python311Packages.python;

        pythonEnv = python.withPackages (ps: with ps; [
          pandas
          matplotlib
          numpy
          scipy
          jupyterlab  # Include JupyterLab in pythonEnv
          ipykernel   # Include ipykernel to register kernels
        ]);
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv    # Ensure pythonEnv is first
            qt5.qtwayland
			firefox # Just in case brave breaks
          ];

          # Optional: Automatically register the kernel
          shellHook = ''
            python -m ipykernel install --user --name=python-env --display-name="Python (Env)"
          '';
        };
      }
    );
}
