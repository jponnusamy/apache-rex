exit_code=0

echo "[1] getting core according to core_pattern"
echo

# figure out pid of one of the childerns
main_pid=$(cat $AREX_RUN_DIR/pid)
echo "main server pid:  $main_pid"
one_child_pid=$(ps -o 'pid,ppid,command' -A | grep "$main_pid" | grep -v grep | tail -n 1 | sed 's:^\s*\([0-9]\+\).*:\1:')
echo "pid of one child: $one_child_pid"

# signal segv to that childern
kill -SEGV $one_child_pid
sleep 1

# examine coredump
if [ "$AREX_HAVE_SYSTEMD_COREDUMP" == "1" ]; then
  echo "using coredumpctl to obtain core for pid $one_child_pid"
  coredumpctl dump $one_child_pid -o $AREX_RUN_DIR/core > /dev/null 2>&1 || exit_code=1
  if [ $exit_code -eq 1 ]; then
    echo "coredumpctl dump on pid $one_child_pid was not successful"
  fi
else
  core_filename=$(echo $AREX_CORE_PATTERN | sed "s:%p:$one_child_pid:" | sed "s:%[a-zA-Z]:*:g")
  echo "using $core_filename core"
  if [ -e $core_filename ]; then
    cp $core_filename $AREX_RUN_DIR/core
  else
    echo "$core_filename does not exist"
    exit_code=1
  fi
fi

if [ -e $AREX_RUN_DIR/core ]; then
  echo
  echo 'bt' | gdb $AREX_RUN_DIR/core 2>/dev/null | grep 'in ap_run_mpm' || exit_code=1
fi

exit $exit_code