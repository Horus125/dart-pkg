import 'package:stack_trace/stack_trace.dart';

void main() {
  var st = """
#0      main.<anonymous closure>.<anonymous closure> (file:///usr/local/google/home/nweiz/goog/pkg/json_rpc_2/test/client/stream_test.dart:98:24)
<asynchronous suspension>
#1      Declarer.test.<anonymous closure>.<anonymous closure> (package:test/src/backend/declarer.dart:124:19)
<asynchronous suspension>
#2      Invoker.waitForOutstandingCallbacks.<anonymous closure>.<anonymous closure> (package:test/src/backend/invoker.dart:204:17)
<asynchronous suspension>
#3      _rootRun (dart:async/zone.dart:1150)
#4      _CustomZone.run (dart:async/zone.dart:1026)
#5      _CustomZone.runGuarded (dart:async/zone.dart:924)
#6      runZoned (dart:async/zone.dart:1501)
#7      Invoker.waitForOutstandingCallbacks.<anonymous closure> (package:test/src/backend/invoker.dart:201:7)
#8      _rootRun (dart:async/zone.dart:1150)
#9      _CustomZone.run (dart:async/zone.dart:1026)
#10     runZoned (dart:async/zone.dart:1503)
#11     Invoker.waitForOutstandingCallbacks (package:test/src/backend/invoker.dart:200:5)
#12     Declarer.test.<anonymous closure> (package:test/src/backend/declarer.dart:122:29)
<asynchronous suspension>
#13     Invoker._onRun.<anonymous closure>.<anonymous closure>.<anonymous closure> (package:test/src/backend/invoker.dart:341:23)
<asynchronous suspension>
#14     Future.Future.<anonymous closure> (dart:async/future.dart:158)
#15     StackZoneSpecification._run (package:stack_trace/src/stack_zone_specification.dart:185:15)
#16     StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:97:48)
#17     _rootRun (dart:async/zone.dart:1146)
#18     _CustomZone.run (dart:async/zone.dart:1026)
#19     _CustomZone.runGuarded (dart:async/zone.dart:924)
#20     _CustomZone.bindCallback.<anonymous closure> (dart:async/zone.dart:951)
#21     StackZoneSpecification._run (package:stack_trace/src/stack_zone_specification.dart:185:15)
#22     StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:97:48)
#23     _rootRun (dart:async/zone.dart:1150)
#24     _CustomZone.run (dart:async/zone.dart:1026)
#25     _CustomZone.runGuarded (dart:async/zone.dart:924)
#26     _CustomZone.bindCallback.<anonymous closure> (dart:async/zone.dart:951)
#27     Timer._createTimer.<anonymous closure> (dart:async-patch/timer_patch.dart:16)
#28     _Timer._runTimers (dart:isolate-patch/timer_impl.dart:385)
#29     _Timer._handleMessage (dart:isolate-patch/timer_impl.dart:414)
#30     _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:148)""";
    print(new Trace.parse(st));
}
