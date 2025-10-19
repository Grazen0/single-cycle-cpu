# Izayoi

Una FPU (floating-point unit) diseñada en Verilog como parte del proyecto de mi
curso de Arquitectura de Computadoras.

## Uso

> [!TIP]
> Si usas Nix, puedes entrar a un shell de desarrollo con todas las dependencias
> necesarias ejecutando `nix-shell`.

Este proyecto se puede compilar y ejecutar con [GNU Make] e [Icarus Verilog] con el siguiente
comando:

```bash
make run TB=<nombre-del-testbench>
```

Por ejemplo, ejecutar este comando con `TB=float_alu/add_single_tb` compilará y
ejecutará el testbench en `tb/float_alu/add_single_tb.v`. Puedes ver todos los
testbenches disponibles [aquí][testbenches].

Todos los testbenches generan un archivo `dump.vcd` en la raíz del proyecto.
Este archivo contiene waveforms que se pueden visualizar con [GTKWave] con el
siguiente comando:

```bash
gtkwave dump.vcd
```

Alternativamente, puedes simplemente compilar, ejecutar y abrir los waveforms
con el siguiente comando:

```bash
make wave TB=<nombre-del-testbench>
```

[gnu make]: https://www.gnu.org/software/make/
[icarus verilog]: https://steveicarus.github.io/iverilog/
[gtkwave]: https://gtkwave.sourceforge.net/
[testbenches]: https://github.com/Grazen0/izayoi/tree/main/tb
