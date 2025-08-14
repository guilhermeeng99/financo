// ignore_for_file: unnecessary_brace_in_string_interps, prefer_final_locals, cascade_invocations, prefer_final_in_for_each, omit_local_variable_types, unnecessary_raw_strings, depend_on_referenced_packages
import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  final directory = Directory.current;
  final libFolder = Directory(p.join(directory.path, 'lib/screens'));
  final filePaths = <String>[];
  await for (final entity in libFolder.list(recursive: true)) {
    if (entity is File) {
      final relativePath = p.relative(entity.path, from: libFolder.path);
      if (relativePath.endsWith('_screen.dart')) {
        filePaths.add(relativePath.replaceAll(r'\', '/'));
      }
    }
  }
  List<String> paths = filePaths;
  // List<String> paths = [
  //   'example/tela_um.dart',
  //   'abc/tela_um.dart',
  //   'abc/tela_dois.dart',
  //   'def/tela_tres.dart',
  //   'def/tela_quatro.dart',
  //   'def/screens/ghi/tela_cinco.dart',
  //   'def/screens/ghi/tela_seis.dart',
  //   'def/screens/ghi/screens/jkl/tela_sete.dart',
  //   'def/screens/ghi/screens/jkl/tela_oito.dart',
  //   'def/screens/ghi/screens/jkl/tela_nove.dart',
  // ];

  Node root = Node('');

  for (String path in paths) {
    List<String> segments =
        path.split('/').where((segment) => segment != 'screens').toList();
    Node current = root;

    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i];

      if (segment.endsWith('_screen.dart')) {
        current.pages.add(segment.replaceAll('_screen.dart', ''));
      } else {
        Node? child = current.findChild(segment);
        if (child == null) {
          child = Node(segment);
          current.children.add(child);
        }
        current = child;
      }
    }
  }

  printNode(root);

  _generateFile(root);
}

extension IterableX<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

void printNode(Node node, [int level = 0]) {
  String indent = '  ' * level;
  // ignore: avoid_print
  print(
    '$indent${node.name} (${node.pages.length} pages: ${node.pages.join(', ')})',
  );
  for (Node child in node.children) {
    printNode(child, level + 1);
  }
}

String toValidDartClassName(String name) {
  try {
    return name.split('_').map((part) {
      return part[0].toUpperCase() + part.substring(1);
    }).join();
  } catch (e) {
    return name;
  }
}

String toValidDartVariableName(String name) {
  String fixedName = name;
  try {
    fixedName = fixedName.split('_').map((part) {
      return part[0].toUpperCase() + part.substring(1);
    }).join();
    return fixedName[0].toLowerCase() + fixedName.substring(1);
  } catch (e) {
    return fixedName;
  }
}

class Node {
  Node(this.name);

  String name;

  List<String> pages = [];

  List<Node> children = [];

  Node? findChild(String name) {
    return children.firstWhereOrNull((child) => child.name == name);
  }

  void generate(
    StringBuffer buffer, {
    bool isRoot = false,
    String oldName = 'AppRoutes',
    String oldRoute = '',
  }) {
    // String nextOldRoute = oldRoute; // Remova a atribuição redundante.
    String className = toValidDartClassName(name);
    String routeClassName = '$oldName${className}';

    if (isRoot) {
      buffer.writeln(
        '// ignore_for_file: avoid_field_initializers_in_const_classes, subtype_of_disallowed_type\n',
      );
      buffer.writeln('$routeClassName get ro => $routeClassName.instance;');
      buffer.writeln('class $routeClassName {');
      buffer.writeln('const $routeClassName._();\n');
      buffer.writeln(
        '  static const $routeClassName instance = $routeClassName._();\n',
      );
    } else {
      buffer.writeln('class $routeClassName {');
      buffer.writeln('const $routeClassName();\n');
    }

    // Atualize os caminhos para evitar duplicação.
    for (String page in pages) {
      String pageClassName = toValidDartVariableName(page);
      String route = '$oldRoute/${name.isNotEmpty ? name : ""}';
      if (toValidDartVariableName(className) == pageClassName) {
        pageClassName = 'route';
      } else {
        route = '$route/$page';
      }
      buffer.writeln("  final String $pageClassName = '$route/';");
    }

    for (Node child in children) {
      String childClassName = toValidDartClassName(child.name);
      String childRouteClassName = '$routeClassName${childClassName}';
      buffer.writeln(
        '  final $childRouteClassName ${toValidDartVariableName(child.name)} = const $childRouteClassName();',
      );
    }
    buffer.writeln('}');

    for (Node child in children) {
      child.generate(
        buffer,
        oldName: '$oldName$className',
        oldRoute: '${oldRoute}${name.isNotEmpty ? "/$name" : ""}',
      );
    }
  }
}

void _generateFile(Node root) {
  final outputFile = File('lib/app/app_routes.dart');
  final buffer = StringBuffer();
  root.generate(buffer, isRoot: true);
  outputFile.writeAsStringSync(buffer.toString());
  final fullFilePath = outputFile.absolute.path;
  Process.runSync('dart format $fullFilePath', [], runInShell: true);
}
