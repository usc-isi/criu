#!/bin/bash

# set -x

MAIN_DIR=$(dirname "$0")
OUTPUT_DIR="${MAIN_DIR}/output"

rm -r -f "${OUTPUT_DIR}"

echo "== Run tests"
export LD_LIBRARY_PATH="${MAIN_DIR}/../../../lib/c:${MAIN_DIR}:${LD_LIBRARY_PATH}"
export PATH="/mnt/criu:${PATH}"
which criu

ln -s "${MAIN_DIR}/../../../lib/c/libcriu.so" libcriu.so.2
cp libcriu.so.2 /usr/lib

RESULT=0

run_test() {
	TEST_DIR="${OUTPUT_DIR}/$1"
	TEST_LOG="${TEST_DIR}/test.log"
	DUMP_LOG="${TEST_DIR}/dump.log"
	RESTORE_LOG="${TEST_DIR}/restore.log"
	echo "== Test $1"
	echo "TEST DIR is: ${TEST_DIR}"
	mkdir -p "${TEST_DIR}"
	if ! setsid ./"$1" "/mnt/criu/criu" "${TEST_DIR}" < /dev/null &>> "${TEST_LOG}"; then
			echo "$1: FAIL"
			echo "** Output of .${TEST_LOG}"
			cat "${TEST_LOG}"
			echo "---------------"
			if [ -f "${DUMP_LOG}" ]; then
				echo "** Contents of dump.log"
				cat "${DUMP_LOG}"
				echo "---------------"
			fi
			if [ -f "${RESTORE_LOG}" ]; then
				echo "** Contents of restore.log"
				cat "${RESTORE_LOG}"
				echo "---------------"
			fi
			RESULT=1
		fi
}

run_test test_sub
run_test test_self
run_test test_notify
if [ "$(uname -m)" = "x86_64" ]; then
	# Skip this on aarch64 as aarch64 has no dirty page tracking
	run_test test_iters
	run_test test_pre_dump
fi
run_test test_errno
run_test test_join_ns
if criu check --feature mem_dirty_track > /dev/null; then
	export CRIU_FEATURE_MEM_TRACK=1
fi
if criu check --feature uffd-noncoop > /dev/null; then
	export CRIU_FEATURE_LAZY_PAGES=1
fi
if criu check --feature pidfd_store > /dev/null; then
	export CRIU_FEATURE_PIDFD_STORE=1
fi
run_test test_feature_check

echo "== Tests done"

[ "${RESULT}" -eq 0 ] && echo "Success" || echo "FAIL"
exit "${RESULT}"
