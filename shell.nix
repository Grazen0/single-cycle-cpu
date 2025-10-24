{
  mkShell,

  riscvPackages,

  bear,
  glibc_multi,
  gtkwave,
  iverilog,
  xxd,
}:
mkShell {
  hardeningDisable = [
    "relro"
    "bindnow"
  ];

  packages = [
    bear
    glibc_multi
    gtkwave
    iverilog
    xxd

    riscvPackages.buildPackages.binutils
    riscvPackages.buildPackages.gcc
    riscvPackages.newlib-nano
  ];
}
