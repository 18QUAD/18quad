C:\Users\narus\rennda_app\functions\index.js
  11:1   error  This line has a length of 91. Maximum allowed is 80  max-len
  21:1   error  This line has a length of 84. Maximum allowed is 80  max-len
  25:10  error  There should be no space after '{'                   object-curly-spacing
  25:39  error  There should be no space before '}'                  object-curly-spacing
  43:34  error  There should be no space after '{'                   object-curly-spacing
  43:54  error  There should be no space before '}'                  object-curly-spacing

✖ 6 problems (6 errors, 0 warnings)
  4 errors and 0 warnings potentially fixable with the `--fix` option.

node:events:496
      throw er; // Unhandled 'error' event
      ^

Error: spawn npm --prefix "%RESOURCE_DIR%" run lint ENOENT
    at notFoundError (C:\Users\narus\AppData\Roaming\npm\node_modules\firebase-tools\node_modules\cross-spawn\lib\enoent.js:6:26)
    at verifyENOENT (C:\Users\narus\AppData\Roaming\npm\node_modules\firebase-tools\node_modules\cross-spawn\lib\enoent.js:40:16)
    at cp.emit (C:\Users\narus\AppData\Roaming\npm\node_modules\firebase-tools\node_modules\cross-spawn\lib\enoent.js:27:25)
    at ChildProcess._handle.onexit (node:internal/child_process:293:12)
Emitted 'error' event on ChildProcess instance at:
    at cp.emit (C:\Users\narus\AppData\Roaming\npm\node_modules\firebase-tools\node_modules\cross-spawn\lib\enoent.js:30:37)
    at ChildProcess._handle.onexit (node:internal/child_process:293:12) {
  code: 'ENOENT',
  errno: 'ENOENT',
  syscall: 'spawn npm --prefix "%RESOURCE_DIR%" run lint',
  path: 'npm --prefix "%RESOURCE_DIR%" run lint',
  spawnargs: []
}

Node.js v22.14.0

Error: functions predeploy error: Command terminated with non-zero exit code 1

Having trouble? Try firebase [command] --help