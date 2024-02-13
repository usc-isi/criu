<!--- (c) 2023 Microchip Technology Inc. --->
<!--- SPDX-License-Identifier: MIT --->

# Instructions for Cross Compiling CRIU & Running CRIU on HPSC-QEMU Debian image

[CRIU](https://criu.org/Main_Page) is a widely-adopted software that offers checkpoint/restore functionalities for Linux systems. These functionalities are critical to ensure the fault tolerence of the system, enabling the rollback to a previous checkpointed state in the event of a failure.

In this instruction, we will demonstrate how to use CRIU to checkpoint/restore (C/R) a Simple Loop Counter program on HPSC-QEMU Debian image via two methods: (1) CRIU's command line and (2) CRIU's C API to C/R within the program.


## Cross Compiling CRIU

Please make sure that you have the following dependencies installed on your host machine.

::::{tab-set}
:::{tab-item} RHEL equivalent
```bash
# note: you may need elevated permissions to execute these commands (e.g. sudo yum <command>).
$ yum install -y protobuf protobuf-c python3-protobuf asciidoc
$ yum install -y https://repo.almalinux.org/almalinux/9/CRB/x86_64/os/Packages/protobuf-compiler-3.14.0-13.el9.x86_64.rpm
$ yum install -y https://repo.almalinux.org/almalinux/9/CRB/x86_64/os/Packages/protobuf-c-compiler-1.3.3-13.el9.x86_64.rpm
$ yum install -y https://repo.almalinux.org/almalinux/9/CRB/x86_64/os/Packages/protobuf-devel-3.14.0-13.el9.x86_64.rpm
$ yum install -y https://repo.almalinux.org/almalinux/9/CRB/x86_64/os/Packages/protobuf-c-devel-1.3.3-13.el9.x86_64.rpm
$ yum install -y https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/zlib-1.2.11-40.el9.x86_64.rpm
$ yum install -y https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/Packages/zlib-devel-1.2.11-40.el9.x86_64.rpm
```
:::
:::{tab-item} Ubuntu 
```bash
# note: you may need elevated permissions to execute these commands (e.g. sudo apt <command>).
$ apt-get update -y
$ apt-get install libprotobuf-dev libprotobuf-c-dev protobuf-c-compiler protobuf-compiler python3-protobuf --no-install-recommends
$ apt-get install asciidoc --no-install-recommends
```
:::
::::

HPSC supports two options when cross compiling CRIU.

1. Cross compile CRIU with its required dependency libraries listed below.
	- `protobuf`
	- `protobuf-C`
	- `libnet`
	- `libcap`
	- `libnl`
2. Cross compile CRIU with both required and optional dependency libraries. The optional dependency libraries HPSC supports are listed below. See [CRIU's website](https://criu.org/Installation) for details on what purposes these optional dependency libraries serve.
	- `libbsd`, and its required dependency library `libmd`
	- `iproute2`
	- `libaio`
	- `libnftable`, and its required dependency libraries `libnftnl, libmnnl, libgmp, libedit, libncurses`
	- `libgnutls`, and its required dependency libraries `libnettle`

### Cross Compiling CRIU with Required Libraries

Run `hpsc_build_all.sh` and select option `1`. This script includes building CRIU's required dependency libraries and building CRIU to generate CRIU binary.

   ```bash
	cd hpsc-criu/scripts/hpsc-CC
	./hpsc_build_all.sh
	running script: hpsc_build_all.sh
	Please make your selection on 1 or 2 below.
	1 - cross compile CRIU with only required packages (~10min)
	2 - cross compile CRIU with required and optional packages (~30min)
	# Please input 1 and press enter
	...
	LINK     lib/c/built-in.o
	LINK     lib/c/libcriu.so
	LINK     lib/c/libcriu.a
	GEN      lib/pycriu/images/magic.py
   ```

The generated CRIU binary will be in `hpsc-criu/criu`.

```bash
	-rwxr-xr-x. 1 c63246 proj_hpsc_bby 6231K Sep  7 15:40 ../../criu/criu*
```

### Cross Compiling CRIU with Required & Optional Libraries (Recommended)

Run `hpsc_build_all.sh` and select option `2`. This script includes building CRIU's required & optional dependency libraries and building CRIU to generate CRIU binary.

   ```bash
	cd hpsc-criu/scripts/hpsc-CC
	./hpsc_build_all.sh
	running script: hpsc_build_all.sh
	Please make your selection on 1 or 2 below.
	1 - cross compile CRIU with only required packages (~10min)
	2 - cross compile CRIU with required and optional packages (~30min)
	# Please input 2 and press enter
	...
 	LINK     lib/c/built-in.o
 	LINK     lib/c/libcriu.so
 	LINK     lib/c/libcriu.a
	GEN      lib/pycriu/images/magic.py
   ```

The generated CRIU binary will be in `hpsc-criu/criu`.

```bash
	-rwxr-xr-x. 1 c63246 proj_hpsc_bby 6401K Feb  12 15:07 ../../criu/criu*
```


## Running CRIU on HPSC-QEMU

### Simple Loop Counter Demo

In order to run CRIU for Simple Loop Counter demo in HPSC-QEMU, we need the following items where `a.` and `b.` are generated from [Cross Compiling CRIU](#Cross-Compiling-CRIU) steps above.

```bash
    a. CRIU binary
    b. RISC-V dependency libararies ($INSTALL_DIR/riscv64_pb_install/lib/*, see hpsc-criu/scripts/hpsc-CC/config.sh for more details on $INSTALL_DIR)
    c. hpsc-criu/test/simpleloop/simple_loop_counter.sh 
    d. hpsc-criu/scripts/hpsc-CC/run_criu.sh
```

To run Simle Loop Counter demo in HPSC-QEMU (assuming you are already logged into HPSC-QEMU Debian evinronment), follow the steps below.

:::{note}
Do not use the minicom to run the checkpoint and restore demo. Use `ssh` sessions instead. For details on how to run `ssh` sessions on HPSC-QEMU, please refer to the [Getting Started with HPSC](getting_started) page.
:::


1. Create two new `ssh` sessions to HPSC-QEMU.
- In a new terminal:

	```bash
	# run it on your host
	cd hpsc
	make run_cluster0_ssh
	```
- In a second new terminal:
	
	```bash
	# run it on your host
	ssh -p <QEMU port number that you see from make run_cluster0_ssh connection> root@localhost
	```

2. Use the following command to transfer the hpsc-criu build artifacts after logging in to your HPSC-QEMU session:

	```bash
	# run it on HPSC-QEMU
	sshfs -o allow_other,default_permissions <host user ID>@10.0.2.2:<path to hpsc-criu> /mnt

	```

3. Set up HPSC-QEMU environment to run CRIU by running the command below.

	```bash
	# run it on HPSC-QEMU
	cd /mnt/scripts/hpsc-CC
	bash setup_qemu.sh

	```

<!-- 	```bash
	cp -rn /mnt/build/criu-dependencies/riscv64_pb_install/lib/* /usr/lib/
	mkdir -p /usr/lib64
	cp -rn /mnt/build/criu-dependencies/riscv64_pb_install/lib64/* /usr/lib64/

	```
 -->
4. In one of the `ssh` sessions, run the Simple Loop Counter program.

	```bash
	# run it on HPSC-QEMU ssh session #1
	cd /mnt/test/simpleloop
	./simple_loop_counter.sh
	```

5. From the second `ssh` terminal, find the process id of the running `simple_loop_counter.sh` program using `ps aux` command. With the known `pid`, we can checkpoint the Simple Loop Counter program.
	
	```bash
	# run it on HPSC-QEMU ssh session #2
	ps aux | grep simple_loop
	```


6. Run CRIU program to checkpoint and restore the Simple Loop Counter process.

	```bash
	# run it on HPSC-QEMU ssh session #2
	cd /mnt/scripts/hpsc-CC
	bash run_criu.sh

	```

:::{note}
The CRIU binary path is hard-coded in run_criu.sh to be run from `/scripts/hpsc-CC` directory.
If you want to execute `run_criu.sh` script from a different directory, make sure that the CRIIU binary path is updated in `/scripts/hpsc-CC/run_criu.sh`.
:::

7. Follow the instructions on the terminal when prompted. 

	The CRIU program offers two options when checkpointing:
	- a. checkpoint while leaving the program running
	- b. checkpoint and then kill the program

	If running option (a.), please make sure the program is killed before restoring it (e.g., using `kill -9 <process id>`). The restored program will have the same process id as the original program being checkpointed, thus the original program needs to be killed before CRIU can restore it.

:::{note}
If the same directory is used for multiple checkpoint operations, the checkpoint will be overwritten to the very last checkpoint.
If you want to checkpoint multiple times while the simple_loop_counter program is running, use a different directory for each checkpoint operation. 
This way, you will be able to restore the program from multiple checkpoint locations.
:::

### Checkpoint & Restore Your Own Program using CRIU CLI

The steps above in the [Simple Loop Counter Demo](#Simple-Loop-Counter-Demo) can be repeated to C/R the program of your choice. Instead of running `simple_loop_counter.sh` demo, you can run your own program and follow the same steps above with your program's `<process id>` to C/R using `run_criu.sh`.

The `run_criu.sh` script is a wrapper of CRIU's key command line options for demonstration purpose. You can modify it to support more options that are included CRIU's CLI options, or run CRIU as a standalone command line tool by running CRIU binary located in `/mnt/criu/criu`. For more details on CRIU's CLI options, please refer to [CRIU's website](https://criu.org/CLI).

## Using CRIU's C API

HPSC also supports C/R with CRIU's [C API library](https://criu.org/C_API) so that you can C/R within your C program. This section will demonstrate how to checkpoint a Simple Loop Counter C program using `criu_dump()` API, and restore it using `criu_restore()` API. CRIU's Github repository has more examples of how to use C API under [test/others/libcriu](https://github.com/checkpoint-restore/criu/tree/criu-dev/test/others/libcriu). 

In order to run CRIU's C API demo in HPSC-QEMU, we need the following items where `a.` and `b.` are generated from [Cross Compiling CRIU](#Cross-Compiling-CRIU) steps above.

```bash
    a. CRIU binary
    b. RISC-V dependency libararies ($INSTALL_DIR/riscv64_pb_install/lib/*, see hpsc-criu/scripts/hpsc-CC/config.sh for more details on $INSTALL_DIR)
    c. hpsc-criu/test/simpleloop/clib/build_clib_tests.sh
    d. hpsc-criu/test/simpleloop/clib/lib.c
    e. hpsc-criu/test/simpleloop/clib/lib.h
    f. hpsc-criu/test/simpleloop/clib/loop_counter_dump.c
    g. hpsc-criu/test/simpleloop/clib/loop_counter_restore.c
    h. hpsc-criu/test/simpleloop/clib/Makefile-CC
```

To run CRIU's C API demo, follow the steps below.

1. Cross Compile CRIU's C API demo programs `loop_counter_dump.c` and `oop_counter_restore.c` with C API support on your host.

	```bash
	# run it on your host
	cd test/simpleloop/clib
	./build_clib_tests.sh
	```

This will generate the RISC-V executables to run on HPSC-QEMU, namely, `loop_counter_dump` and `loop_counter_restore`.

2. Follow the steps in [Running CRIU on HPSC-QEMU](#Running-CRIU-on-HPSC-QEMU) to set up your HPSC-QEMU environment to run CRIU with one `ssh` session. We recommend following the [Simple Loop Counter Demo](#Simple-Loop-Counter-Demo) first to get yourself familiar with HPSC-QEMU's set up for CRIU.


3. In the `ssh` sesstion, your can run the RISC-V executables generated above to automatically C/R Simple Loop Counter programs with C API support now!

	```bash
	# run it on HPSC-QEMU
	cd test/simpleloop/clib
	./build_clib_tests.sh
	```


	@yixue, check if c api works when only using required packages.