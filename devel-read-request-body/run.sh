exit_code=0

echo "[1] echo request body"
curl -s -X POST -d 'This is content of a request body.' http://localhost:$AREX_PORT/body-echo \
 > $AREX_RUN_DIR/out

grep 'Read: 34 bytes'                     $AREX_RUN_DIR/out || exit_code=1
grep 'This is content of a request body.' $AREX_RUN_DIR/out || exit_code=1

exit $exit_code
