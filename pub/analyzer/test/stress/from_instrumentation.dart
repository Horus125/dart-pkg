import 'dart:io';

import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

main() {
  AnalysisContext context = AnalysisEngine.instance.createAnalysisContext();
  context.sourceFactory = new SourceFactory(
      [new DartUriResolver(DirectoryBasedDartSdk.defaultSdk)]);
  context.analysisOptions =
      new AnalysisOptionsImpl.from(context.analysisOptions)
        ..incremental = true
        ..finerGrainedInvalidation = true;

  Source source = new FileBasedSource(new JavaFile(
      '/Users/scheglov/Source/Dart/sdk.git/sdk/pkg/analyzer/test/stress/from_instrumentation.dart'));
  context.applyChanges(new ChangeSet()..addedSource(source));

  String text = new File('/Users/scheglov/Downloads/instrumentation.log.4')
      .readAsStringSync();
  List<String> lines = text.split('\n');
  const String prefix =
      '"method"::"analysis.updateContent","params"::{"files"::{"/Users/brianwilkerson/src/dart/sdk/sdk/pkg/analyzer/lib/src/dart/sdk/sdk.dart"::{"type"::"add","content"::"';
  for (String line in lines) {
    int index = line.indexOf(prefix);
    int index2 = line.indexOf('"}}},"clientRequestTime"::');
    if (index != -1 && index2 != -1) {
      String code = line.substring(index + prefix.length, index2);
      code = code.replaceAll(r'\n', '\n');
      code = code.replaceAll(r'::', ':');
      code = code.replaceAll(r'\"', '"');
      var lineId = line.substring(0, index);
      print(lineId);
      if (lineId.contains('"774"')) {
        new File('/Users/scheglov/Downloads/code_774.dart')
            .writeAsStringSync(code);
      }
      if (lineId.contains('"776"')) {
        new File('/Users/scheglov/Downloads/code_776.dart')
            .writeAsStringSync(code);
      }
      if (lineId.contains('"780"')) {
        new File('/Users/scheglov/Downloads/code_780.dart')
            .writeAsStringSync(code);
      }
      context.setContents(source, code);
    }
  }
}

void performPendingAnalysisTasks(AnalysisContext context,
    [int maxTasks = 1000000]) {
  for (int i = 0; context.performAnalysisTask().hasMoreWork; i++) {
    if (i > maxTasks) {
      throw new StateError('Analysis did not terminate.');
    }
  }
}
