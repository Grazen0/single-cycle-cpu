{
  pkgs ? import <nixpkgs> { },
}:
let
  riscvPkgs = import <nixpkgs> {
    crossSystem.config = "riscv32-unknown-none-elf";
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    gtkwave
    iverilog
    xxd

    bear
    glibc_multi
    riscvPkgs.buildPackages.binutils
    riscvPkgs.buildPackages.gcc
  ];
}
