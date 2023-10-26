## Instructions for Using CRIU C API (Cross Compile)

In this tutorial, we will demonstrate how you can use CRIU's C API to checkpoint/restore within your C program. We will use Simple Loop Counter program as an example. CRIU's repository has more examples of how to use C API under [test/others/libcriu](https://github.com/checkpoint-restore/criu/tree/criu-dev/test/others/libcriu). The examples we use in this tutorial are located under [test/simpleloop/clib](../../test/simpleloop/clib).

To add CRIU C API to your program:

1. Add [lib.c](../../test/simpleloop/clib/lib.c) and [lib.h](../../test/simpleloop/clib/lib.h) to the directory of your C program and include `lib.h` and `criu.h` in the header of your program, i.e., `#include "criu.h"` and
`#include "lib.h"`. Please see [loop_counter_dump.c](../../test/simpleloop/clib/loop_counter_dump.c) as an example. This program starts a Simple Loop Counter and will checkpoint itself when the counter hits `3`, and then will checkpoint again when the counter hits `5`. After the second checkpoint, the program will be killed by using API `criu_set_leave_running(false)`. A list of supported C API can be found on CRIU's website [here](https://criu.org/API_compliance).

2. Modify the makefile [Makefile-CC](../../test/simpleloop/clib/Makefile-CC) to add the name of your C program that you want to compile with the CRIU C API support, e.g., `TESTS += loop_counter_dump` will cross compile [loop_counter_dump.c](../../test/simpleloop/clib/loop_counter_dump.c). The default  [Makefile-CC](../../test/simpleloop/clib/Makefile-CC) will cross compile our Simple Loop Counter examples [loop_counter_dump.c](../../test/simpleloop/clib/loop_counter_dump.c) and [loop_counter_restore.c](../../test/simpleloop/clib/loop_counter_restore.c).

3. On your host, run [./build_clib_tests.sh](../../test/simpleloop/clib/build_clib_tests.sh) to cross compile your C program with the C API support. This will generate the executable to run on HPSC-QEMU. For example, the default scripts without your modifications will generate the executables of `loop_counter_dump.c` and `loop_counter_restore.c`.

4. Follow [CRIU's getting started page](./get_started.md) to set up CRIU on HPSC-QEMU.

5. Now you can run your C program with CRIU C API support on HPSC-QEMU! For example, you can run the executable `./loop_counter_dump` and `./loop_counter_restore` (generated in Step 3) located under `/mnt/test/simpleloop/clib` on HPSC-QEMU. The expected outputs are shown below.

**Output of ./loop_counter_dump**

```sh
[root@hpsc:/mnt/test/simpleloop/clib]
# ./loop_counter_dump
Directory 'output' created.
current pid = 476
CRIU Testing counter = 1
CRIU Testing counter = 2
CRIU Testing counter = 3
Start checkpointing...
Success! :) Checkpoint saved to directory: output
CRIU Testing counter = 4
CRIU Testing counter = 5
Start checkpointing...
Killed
```

**Output of ./loop_counter_restore**

```sh
[root@hpsc:/mnt/test/simpleloop/clib]
# ./loop_counter_restore
--- Restore from images dir: output ---
CRIU Testing counter = 6
--- Restored pid is: 476 ---
[root@hpsc:/mnt/test/simpleloop/clib]
# CRIU Testing counter = 7
CRIU Testing counter = 8
CRIU Testing counter = 9
CRIU Testing counter = 10
CRIU Testing counter = 11
......
```