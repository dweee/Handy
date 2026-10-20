{
  description = "Handy - offline speech-to-text for Linux and macOS";

  inputs = {
    # Match the consuming fleet pin so native CI tests the same toolchain.
    nixpkgs.url = "github:NixOS/nixpkgs/55bfb4d7437bd4e09ab7cba58a43bd68eb310044";
    bun2nix = {
      url = "github:nix-community/bun2nix/2.0.8";
      inputs.nixpkgs.follows = "nixpkgs";
      # 2.0.8 evaluates every system's formatter, even for Linux consumers.
      # nixpkgs 26.11 no longer supports x86_64-darwin (bun2nix#98).
      inputs.systems.url = "github:nix-systems/triplet";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      bun2nix,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ bun2nix.overlays.default ];
        };
      withPackage = module: { lib, pkgs, ... }: {
        imports = [ module ];
        programs.handy.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.handy;
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        rec {
          handy = pkgs.callPackage ./nix/package.nix { src = self; };
          default = handy;
        }
      );

      checks = forAllSystems (system: {
        inherit (self.packages.${system}) handy;
      });

      nixosModules.default = withPackage ./nix/module.nix;
      darwinModules.default = withPackage ./nix/darwin-module.nix;

      homeManagerModules.default = { lib, pkgs, ... }: {
        imports = [ ./nix/hm-module.nix ];
        services.handy.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.handy;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          package = self.packages.${system}.handy;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ package ];
            packages = [
              pkgs.rustc
              pkgs.cargo
              pkgs.rust-analyzer
            ];
            env = package.devEnv;
            shellHook = ''
              echo "Run 'bun install' then 'bun run tauri dev' to start Handy."
            '';
          };
        }
      );
    };
}
