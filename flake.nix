{
  description = "Handy - offline speech-to-text for Linux and macOS";

  inputs = {
    # Pin the native toolchain used by package consumers.
    nixpkgs.url =
      "github:NixOS/nixpkgs/efdabaf43b366580e8d0320b57c4cbaa6939acd6";
    bun2nix = {
      url = "github:nix-community/bun2nix/c843f477b15f51151f8c6bcc886954699440a6e1";
      inputs.nixpkgs.follows = "nixpkgs";
      # 2.0.8 evaluates every system's formatter, even for Linux consumers.
      # nixpkgs 26.11 no longer supports x86_64-darwin (bun2nix#98).
      inputs.systems.url = "github:nix-systems/triplet";
    };
  };

  outputs = { self, nixpkgs, bun2nix, }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ bun2nix.overlays.default ];
        };
      withPackage = module:
        { lib, pkgs, ... }: {
          imports = [ module ];
          programs.handy.package = lib.mkDefault
            self.packages.${pkgs.stdenv.hostPlatform.system}.handy;
        };
    in {
      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in rec {
          handy = pkgs.callPackage ./nix/package.nix {
            src = pkgs.lib.cleanSourceWith {
              src = self;
              filter = path: _type:
                !(builtins.elem (baseNameOf path) [
                  ".github"
                  "ci"
                  ".fork-ci.json"
                  "flake.nix"
                  "flake.lock"
                  "nix"
                ]);
            };
          };
          default = handy;
        });

      checks =
        forAllSystems (system: { inherit (self.packages.${system}) handy; });

      nixosModules = rec {
        handy = withPackage ./nix/module.nix;
        default = handy;
      };
      darwinModules = rec {
        handy = withPackage ./nix/darwin-module.nix;
        default = handy;
      };

      homeManagerModules.default = { lib, pkgs, ... }: {
        imports = [ ./nix/hm-module.nix ];
        services.handy.package =
          lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.handy;
      };

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          package = self.packages.${system}.handy;
        in {
          default = pkgs.mkShell {
            inputsFrom = [ package ];
            packages = [ pkgs.rustc pkgs.cargo pkgs.rust-analyzer ];
            env = package.devEnv
              // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
                # Unpatched development sources still dlopen these by soname.
                LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
                  pkgs.libayatana-appindicator
                  pkgs.vulkan-loader
                ];
                XDG_DATA_DIRS =
                  "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.hicolor-icon-theme}/share";
              };
            shellHook = ''
              echo "Run 'bun install' then 'bun run tauri dev' to start Handy."
            '';
          };
        });
    };
}
