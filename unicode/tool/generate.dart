library unicode.tool.generator;

import "dart:async";
import "dart:io";
import "package:http/http.dart" as http;
import "package:lists/lists.dart";
import "package:strings/strings.dart";
import "package:template_block/template_block.dart";

const String UNICODE_DATA_FILE = "UnicodeData.txt";

const String UNICODE_DATA_URL =
    "http://www.unicode.org/Public/UNIDATA/UnicodeData.txt";

const String VERSION = "8.0.0";

void main() {
  var resources = <String, Resource>{};
  resources[Generator.UNICODE_DATA] =
      new Resource(filename: UNICODE_DATA_FILE, url: UNICODE_DATA_URL);
  Future.wait(resources.values.map((r) => r.load())).then((_) {
    var generator = new Generator();
    var data = <String, List<String>>{};
    resources.forEach((k, v) => data[k] = v.data);
    var result = generator.generate(data);
    var script = "lib/unicode.dart";
    var file = new File(script);
    file.writeAsStringSync(result.join("\n"));
  });
}

class Categories {
  static const Categories CN = const Categories("Cn", "NOT_ASSIGNED", 0);

  static const Categories CC = const Categories("Cc", "CONTROL", 1);

  static const Categories CF = const Categories("Cf", "FORMAT", 2);

  static const Categories CO = const Categories("Co", "PRIVATE_USE", 3);

  static const Categories CS = const Categories("Cs", "SURROGATE", 4);

  static const Categories LL = const Categories("Ll", "LOWERCASE_LETTER", 5);

  static const Categories LM = const Categories("Lm", "MODIFIER_LETTER", 6);

  static const Categories LO = const Categories("Lo", "OTHER_LETTER", 7);

  static const Categories LT = const Categories("Lt", "TITLECASE_LETTER", 8);

  static const Categories LU = const Categories("Lu", "UPPERCASE_LETTER", 9);

  static const Categories MC = const Categories("Mc", "SPACING_MARK", 10);

  static const Categories ME = const Categories("Me", "ENCOSING_MARK", 11);

  static const Categories MN = const Categories("Mn", "NONSPACING_MARK", 12);

  static const Categories ND = const Categories("Nd", "DECIMAL_NUMBER", 13);

  static const Categories NL = const Categories("Nl", "LETTER_NUMBER", 14);

  static const Categories NO = const Categories("No", "OTHER_NUMBER", 15);

  static const Categories PC =
      const Categories("Pc", "CONNECTOR_PUNCTUATION", 16);

  static const Categories PD = const Categories("Pd", "DASH_PUNCTUATION", 17);

  static const Categories PE = const Categories("Pe", "CLOSE_PUNCTUATION", 18);

  static const Categories PF = const Categories("Pf", "FINAL_PUNCTUATION", 19);

  static const Categories PI =
      const Categories("Pi", "INITIAL_PUNCTUATION", 20);

  static const Categories PO = const Categories("Po", "OTHER_PUNCTUATION", 21);

  static const Categories PS = const Categories("Ps", "OPEN_PUNCTUATION", 22);

  static const Categories SC = const Categories("Sc", "CURRENCY_SYMBOL", 23);

  static const Categories SK = const Categories("Sk", "MODIFIER_SYMBOL", 24);

  static const Categories SM = const Categories("Sm", "MATH_SYMBOL", 25);

  static const Categories SO = const Categories("So", "OTHER_SYMBOL", 26);

  static const Categories ZL = const Categories("Zl", "LINE_SEPARATOR", 27);

  static const Categories ZP =
      const Categories("Zp", "PARAGRAPH_SEPARATOR", 28);

  static const Categories ZS = const Categories("Zs", "SPACE_SEPARATOR", 29);

  final int id;

  final String abbr;

  final String name;

  const Categories(this.abbr, this.name, this.id);

  static final Map<String, Categories> values = <String, Categories>{
    CN.abbr: CN,
    CC.abbr: CC,
    CF.abbr: CF,
    CO.abbr: CO,
    CS.abbr: CS,
    LL.abbr: LL,
    LM.abbr: LM,
    LO.abbr: LO,
    LT.abbr: LT,
    LU.abbr: LU,
    MC.abbr: MC,
    ME.abbr: ME,
    MN.abbr: MN,
    ND.abbr: ND,
    NL.abbr: NL,
    NO.abbr: NO,
    PC.abbr: PC,
    PD.abbr: PD,
    PE.abbr: PE,
    PF.abbr: PF,
    PI.abbr: PI,
    PO.abbr: PO,
    PS.abbr: PS,
    SC.abbr: SC,
    SK.abbr: SK,
    SM.abbr: SM,
    SO.abbr: SO,
    ZL.abbr: ZL,
    ZP.abbr: ZP,
    ZS.abbr: ZS,
  };

  String toString() => name;
}

class Generator {
  static const int MAX_VALUE = 0x10ffff;

  static const int UNICODE_LENGTH = MAX_VALUE + 1;

  static const String UNICODE_DATA = "UNICODE_DATA";

  static const String _GENERAL_CATEGORIES = "generalCategories";

  static const String _GENERATE_BOOL_GROUP = "_generateBoolGroup";

  static const String _GENERATE_CATEGORY = "_generateCategory";

  static const String _GENERATE_INT_GROUP = "_generateIntGroup";

  static const String _GENERATE_INT_MAPPING = "_generateIntMapping";

  static const String _LOWERCASE = "lowercase";

  static const String _TITLECASE = "titlecase";

  static const String _TO_CASE = "_toCase";

  static const String _TO_RUNE = "toRune";

  static const String _TO_RUNES = "toRunes";

  static const String _UPPERCASE = "uppercase";

  static final String _templateLibrary = '''
// This library was created by the tool.
// Source: $UNICODE_DATA_URL
// Unicode Version: $VERSION

library {{NAME}};

{{#DIRECTIVES}}
{{#CONSTANTS}}
{{#VARIABLES}}
{{#METHODS}}
''';

  static final String _templateMethodGenerateBoolGroup = '''
SparseBoolList $_GENERATE_BOOL_GROUP(List<int> data) {
  var list = new SparseBoolList();
  list.length = $UNICODE_LENGTH;
  var length = data.length;
  for (var i = 0; i < length; i += 2) {
    var start = data[i + 0];
    var end = data[i + 1];
    list.addGroup(new GroupedRangeList<bool>(start, end, true));
  }

  list.freeze();
  return list;
}
''';

  static final String _templateMethodGenerateCategory = '''
SparseBoolList $_GENERATE_CATEGORY(int category) {
  var list = new SparseBoolList();
  list.length = $UNICODE_LENGTH;
  for (var group in $_GENERAL_CATEGORIES.groups) {
    if (group.key == category) {
      list.addGroup(new GroupedRangeList<bool>(group.start, group.end, true));
    }
  }

  list.freeze();
  return list;
}
''';

  static final String _templateMethodGenerateIntGroup = '''
SparseList<int> $_GENERATE_INT_GROUP(List<int> data, bool isCompressed) {
  if (isCompressed) {
    data = GZIP.decoder.convert(data);
  }
  var list = new SparseList<int>(defaultValue: 0);
  list.length = $UNICODE_LENGTH;
  var length = data.length;
  var start = 0;
  var end = 0;
  for (var i = 0; i < length; i+= 3) {
    start += data[i + 0];
    end += data[i + 1];
    var key = data[i + 2];
    list.addGroup(new GroupedRangeList<int>(start, end, key));
  }

  list.freeze();
  return list;
}
''';

  static final String _templateMethodGenerateIntMapping = '''
Map<int, int> $_GENERATE_INT_MAPPING(List<int> data, bool isCompressed) {
  if (isCompressed) {
    data = GZIP.decoder.convert(data);
  }
  var map = new HashMap<int, int>();
  var length = data.length;
  var key = 0;
  var value = 0;
  for (var i = 0; i < length; i+= 2) {
    key += data[i + 0];
    value += data[i + 1];
    map[key] = value;
  }

  return new UnmodifiableMapView<int, int>(map);
}
''';

  static final String _templateMethodIsCategory = '''
bool is{{NAME}}(int character) => {{CHARACTER_SET}}[character];
''';

  static final String _templateMethodToCase = '''
String $_TO_CASE(String string, Map<int, int> mapping) {
  var runes = toRunes(string);
  var length = runes.length;
  for (var i = 0; i < length; i++) {
    var character = mapping[runes[i]];
    if (character != null) {
      runes[i] = character;
    }
  }
  return new String.fromCharCodes(runes);
}
''';

  static final String _templateMethodToRune = '''
int $_TO_RUNE(String string) {
  if (string == null) {
    throw new ArgumentError("string: \$string");
  }

  var length = string.length;
  if (length == 0) {
    throw new StateError("An empty string contains no elements.");
  }

  var start = string.codeUnitAt(0);
  if (length == 1) {
    return start;
  }

  if ((start & 0xFC00) == 0xD800) {
    var end = string.codeUnitAt(1);
    if ((end & 0xFC00) == 0xDC00) {
      return (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
    }
  }

  return start;
}
''';

  static final String _templateMethodToRunes = '''
List<int> $_TO_RUNES(String string) {
  if (string == null) {
    throw new ArgumentError("string: \$string");
  }

  var length = string.length;
  if (length == 0) {
    return const <int>[];
  }

  var runes = <int>[];
  runes.length = length;
  var i = 0;
  var pos = 0;
  for ( ; i < length; pos++) {
    var start = string.codeUnitAt(i);
    i++;
    if ((start & 0xFC00) == 0xD800 && i < length) {
      var end = string.codeUnitAt(i);
      if ((end & 0xFC00) == 0xDC00) {
        runes[pos] = (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
        i++;
      } else {
        runes[pos] = start;
      }
    } else {
      runes[pos] = start;
    }
  }

  runes.length = pos;
  return runes;
}
''';

  static final String _templateMethodToXxxCase = '''
String {{NAME}}(String string) => $_TO_CASE(string, {{MAPPING}});
''';

  static final String _templateCharacterSet = '''
final SparseBoolList {{NAME}} = $_GENERATE_CATEGORY({{ID}});
''';

  static final String _templateMapping = '''
final Map<int, int> {{NAME}} = $_GENERATE_INT_MAPPING({{DATA}}, {{IS_COMRESSED}});
''';

  static final String _templateSparseListBool = '''
final SparseBoolList {{NAME}} = $_GENERATE_BOOL_GROUP({{DATA}});
''';

  static final String _templateSparseListInt = '''
final SparseList<int> {{NAME}} = $_GENERATE_INT_GROUP({{DATA}}, {{IS_COMRESSED}});
''';

  /**
   * This bug present in Dart VM since 8 Sep 2014
   */
  bool _bugInDartGzip;

  SparseList<int> _characters;

  Map<Categories, SparseBoolList> _categories;

  List<List<String>> _constants;

  List<List<String>> _methods;

  Map<String, Map<int, int>> _caseMapping;

  List<List<String>> _variables;

  List<String> generate(Map<String, List<String>> data) {
    _caseMapping = <String, Map<int, int>>{};
    _characters = new SparseList<int>(defaultValue: 0);
    _categories = <Categories, SparseBoolList>{};
    _constants = <List<String>>[];
    _methods = <List<String>>[];
    _variables = <List<String>>[];
    var characters = _parseUnicodeData(data[Generator.UNICODE_DATA]);
    _build(characters);
    _generateConstants();
    _generateVariables();
    _generateMethods();
    return _generateLibrary("unicode");
  }

  void _build(List<Character> characters) {
    _caseMapping[_LOWERCASE] = <int, int>{};
    _caseMapping[_TITLECASE] = <int, int>{};
    _caseMapping[_UPPERCASE] = <int, int>{};
    var length = characters.length;
    for (var category in Categories.values.values) {
      var list = new SparseBoolList();
      list.length = UNICODE_LENGTH;
      _categories[category] = list;
    }

    for (var i = 0; i < length; i++) {
      var character = characters[i];
      if (character == null) {
        continue;
      }
      var code = character.code;
      var category = Categories.values[character.category];
      if (category == null) {
        throw new StateError(
            "Unknown character category: ${character.category}");
      }

      _categories[category][character.code] = true;
      // Case mapping
      var lowercase = character.lowercase;
      var titlecase = character.titlecase;
      var uppercase = character.uppercase;
      if (lowercase != null) {
        _caseMapping[_LOWERCASE][code] = lowercase;
      }

      if (titlecase != null) {
        _caseMapping[_TITLECASE][code] = titlecase;
      }

      if (uppercase != null) {
        _caseMapping[_UPPERCASE][code] = uppercase;
      }
    }

    for (var category in _categories.keys) {
      var characters = _categories[category];
      for (var group in characters.groups) {
        var group2 =
            new GroupedRangeList<int>(group.start, group.end, category.id);
        _characters.addGroup(group2);
      }
    }
  }

  List<int> _compressGroups(List<int> groups) {
    var data = <int>[];
    var deltaStart = 0;
    var deltaEnd = 0;
    var start = 0;
    var end = 0;
    // Compression phase #1
    for (var i = 0; i < groups.length; i += 3) {
      deltaStart = groups[i] - start;
      deltaEnd = groups[i + 1] - end;
      start = start + deltaStart;
      end = end + deltaEnd;
      data.add(deltaStart);
      data.add(deltaEnd);
      data.add(groups[i + 2]);
    }

    // Compression phase #2
    var compressed = GZIP.encoder.convert(data);
    var uncompressed = GZIP.decoder.convert(compressed);
    var length = data.length;
    _bugInDartGzip = false;
    for (var i = 0; i < length; i++) {
      if (data[i] != uncompressed[i]) {
        _bugInDartGzip = true;
        break;
      }
    }

    if (_bugInDartGzip) {
      compressed = data;
    }

    return compressed;
  }

  List<int> _compressMapping(List<int> mapping) {
    var data = <int>[];
    var deltaKey = 0;
    var deltaValue = 0;
    var key = 0;
    var value = 0;
    // Compression phase #1
    for (var i = 0; i < mapping.length; i += 2) {
      deltaKey = mapping[i] - key;
      deltaValue = mapping[i + 1] - value;
      key = key + deltaKey;
      value = value + deltaValue;
      data.add(deltaKey);
      data.add(deltaValue);
    }

    // Compression phase #2
    var compressed = GZIP.encoder.convert(data);
    var uncompressed = GZIP.decoder.convert(compressed);
    var length = data.length;
    _bugInDartGzip = false;
    for (var i = 0; i < length; i++) {
      if (data[i] != uncompressed[i]) {
        _bugInDartGzip = true;
        break;
      }
    }

    if (_bugInDartGzip) {
      compressed = data;
    }

    return compressed;
  }

  void _generateConstants() {
    var strings = <String>[];
    for (var category in Categories.values.values) {
      var name = category.name;
      var id = category.id;
      strings.add("const int $name = $id;");
    }

    strings.add("");
    _constants.add(strings);
  }

  List<String> _generateLibrary(String name) {
    var block = new TemplateBlock(_templateLibrary);
    block.assign("NAME", name);
    block.assign("#DIRECTIVES", "import \"dart:collection\";");
    block.assign("#DIRECTIVES", "import \"dart:io\";");
    block.assign("#DIRECTIVES", "import \"package:lists/lists.dart\";");
    block.assign("#DIRECTIVES", "");
    block.assign("#CONSTANTS", _constants);
    block.assign("#METHODS", _methods);
    block.assign("#VARIABLES", _variables);
    return block.process();
  }

  void _generateMethodGenerateBoolGroup() {
    var block = new TemplateBlock(_templateMethodGenerateBoolGroup);
    _methods.add(block.process());
  }

  void _generateMethodGenerateCategory() {
    var block = new TemplateBlock(_templateMethodGenerateCategory);
    _methods.add(block.process());
  }

  void _generateMethodGenerateIntGroup() {
    var block = new TemplateBlock(_templateMethodGenerateIntGroup);
    _methods.add(block.process());
  }

  void _generateMethodGenerateIntMapping() {
    var block = new TemplateBlock(_templateMethodGenerateIntMapping);
    _methods.add(block.process());
  }

  void _generateMethods() {
    _generateMethodIsCategory();
    _generateMethodToXxxCase();
    _generateMethodToRune();
    _generateMethodToRunes();
    _generateMethodGenerateBoolGroup();
    _generateMethodGenerateCategory();
    _generateMethodGenerateIntGroup();
    _generateMethodGenerateIntMapping();
    _generateMethodToCase();
  }

  void _generateMethodIsCategory() {
    var blockIsCategory = new TemplateBlock(_templateMethodIsCategory);
    var categories = Categories.values;
    for (var category in categories.values) {
      var block = blockIsCategory.clone();
      var name = camelize(category.name);
      block.assign("NAME", name);
      block.assign("CHARACTER_SET", _getCharacterSetName(category));
      _methods.add(block.process());
    }
  }

  void _generateMethodToCase() {
    var block = new TemplateBlock(_templateMethodToCase);
    _methods.add(block.process());
  }

  void _generateMethodToRune() {
    var block = new TemplateBlock(_templateMethodToRune);
    _methods.add(block.process());
  }

  void _generateMethodToRunes() {
    var block = new TemplateBlock(_templateMethodToRunes);
    _methods.add(block.process());
  }

  void _generateMethodToXxxCase() {
    var block = new TemplateBlock(_templateMethodToXxxCase);
    for (var key in _caseMapping.keys) {
      var mapping = _getSimpleCaseMappingName(key);
      var block1 = block.clone();
      var name = "to_${key}";
      name = camelize(name, true);
      block1.assign("NAME", name);
      block1.assign("MAPPING", mapping);
      _methods.add(block1.process());
    }
  }

  void _generateVariableCategories() {
    var block = new TemplateBlock(_templateSparseListInt);
    var data = <int>[];
    for (var group in _characters.groups) {
      data.add(group.start);
      data.add(group.end);
      data.add(group.key);
    }

    var compressed = _compressGroups(data);
    block.assign("IS_COMRESSED", !_bugInDartGzip);
    block.assign("DATA", "[${compressed.join(", ")}]");
    block.assign("NAME", _GENERAL_CATEGORIES);
    _variables.add(block.process());
  }

  void _generateVariables() {
    _generateVariableCategories();
    _generateVariableCharacterSet();
    _generateVariableSimpleCaseMapping();
  }

  void _generateVariableCharacterSet() {
    var block = new TemplateBlock(_templateCharacterSet);
    for (var category in _categories.keys) {
      var block1 = block.clone();
      block1.assign("NAME", _getCharacterSetName(category));
      block1.assign("ID", category.id);
      _variables.add(block1.process());
    }
  }

  void _generateVariableSimpleCaseMapping() {
    var block = new TemplateBlock(_templateMapping);
    for (var name in _caseMapping.keys) {
      var data = <int>[];
      var map = _caseMapping[name];
      for (var key in map.keys) {
        data.add(key);
        data.add(map[key]);
      }

      var compressed = _compressMapping(data);
      var block1 = block.clone();
      block1.assign("IS_COMRESSED", !_bugInDartGzip);
      block1.assign("DATA", "[${compressed.join(", ")}]");
      block1.assign("NAME", _getSimpleCaseMappingName(name));
      _variables.add(block1.process());
    }
  }

  String _getCharacterSetName(Categories category) {
    var name = category.name;
    name = "${category.name}_Characters";
    name = camelize(name, true);
    return name;
  }

  String _getSimpleCaseMappingName(String name) {
    name = "simple_${name}_mapping";
    name = camelize(name, true);
    return name;
  }

  List<Character> _parseUnicodeData(List<String> lines) {
    var characters = new List(UNICODE_LENGTH);
    for (var line in lines) {
      var parts = line.split(";");
      var index = int.parse(parts[0], radix: 16);
      var character = new Character(parts);
      characters[index] = new Character(parts);
    }

    return characters;
  }
}

class Character {
  int code;

  List<String> data;

  String category;

  int uppercase;

  int titlecase;

  int lowercase;

  Character(this.data) {
    code = int.parse(data[0], radix: 16);
    category = data[2];
    if (!data[12].isEmpty) {
      uppercase = int.parse(data[12], radix: 16);
    }

    if (!data[13].isEmpty) {
      lowercase = int.parse(data[13], radix: 16);
    }

    if (!data[14].isEmpty) {
      titlecase = int.parse(data[14], radix: 16);
    }
  }
}

class Resource {
  List<String> data;

  String filename;

  String url;

  Resource({this.filename, this.url});

  Future<List<String>> load() {
    var file = new File(filename);
    if (file.existsSync()) {
      return file.readAsLines().then((result) {
        data = result;
        return data;
      });
    }

    return http.read(Uri.parse(url)).then((string) {
      string = string.replaceAll("\r\n", "\n");
      string = string.replaceAll("\r", "\n");
      data = string.split("\n");
      if (data.last.isEmpty) {
        data.removeLast();
      }

      return data;
    });
  }
}
