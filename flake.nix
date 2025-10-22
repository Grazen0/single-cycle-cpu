{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-old.url = "github:nixos/nixpkgs?ref=facbbae4b7cb818569024a7bd1dbddf1bbdd4c35";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-old,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        {
          self',
          pkgs,
          system,
          ...
        }:
        let
          riscvCross = import nixpkgs-old {
            inherit system;
            crossSystem = {
              config = "riscv32-none-elf";
              libc = "newlib-nano";
              abi = "ilp32";
              gcc = {
                arch = "rv32i";
                abi = "ilp32";
              };
            };
          };
        in
        {
          devShells.default = pkgs.callPackage ./shell.nix {
            riscvPackages = riscvCross.buildPackages;
          };
        };
    };
}
