{
  pkgs ? import <nixpkgs> { },
}:
let
  riscvPackages = import <nixpkgs> {
    crossSystem.config = "riscv32-unknown-none-elf";
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    gtkwave
    iverilog
    xxd

    glibc_multi
    riscvPackages.buildPackages.binutils
    riscvPackages.buildPackages.gcc
  ];
}
