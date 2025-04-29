{ runCommand }:

runCommand "canokey-udev-rules" { } ''
  install -D -m444 ${./69-canokey.rules} $out/lib/udev/rules.d/69-canokey.rules
''
