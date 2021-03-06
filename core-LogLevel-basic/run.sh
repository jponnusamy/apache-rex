exit_code=0

echo "[1] LogLevel setting depending on %{REMOTE_ADDR}"
curl -s http://localhost:$AREX_PORT/ > /dev/null
if [ $AREX_APACHE_VERSION -ge 20400 ]; then
  grep 'http:trace[1-8]' $AREX_RUN_DIR/error_log || exit_code=1
else
  grep '\[debug\]' $AREX_RUN_DIR/error_log || exit_code=1
fi

exit $exit_code

