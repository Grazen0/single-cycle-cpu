{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
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
          riscvPackages = import nixpkgs {
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
          devShells.default = pkgs.callPackage ./shell.nix { inherit riscvPackages; };
        };
    };
}
