{
  mkShell,

  riscvPackages,

  gtkwave,
  iverilog,
  xxd,
  bear,
}:
mkShell {
  hardeningDisable = [
    "relro"
    "bindnow"
  ];

  packages = [
    gtkwave
    iverilog
    xxd
    bear

    riscvPackages.binutils
    riscvPackages.gcc
    (riscvPackages.newlib-nano.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
        riscvPackages.gcc
        riscvPackages.binutils
      ];
    }))
  ];
}
