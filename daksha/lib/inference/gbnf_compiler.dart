abstract final class GbnfCompiler {
  static String compile(Map<String, dynamic> schema) {
    final type = schema['type'] as String?;
    if (type != 'object') {
      throw ArgumentError(
        'Unsupported schema type: "$type". Only "object" is supported.',
      );
    }

    final rawProps = schema['properties'];
    final properties = (rawProps is Map<String, dynamic>) ? rawProps : <String, dynamic>{};

    // Build root rule inline: each key-value pair separated by commas.
    final rootParts = <String>[];
    for (final entry in properties.entries) {
      final key = entry.key;
      final propSchema = entry.value as Map<String, dynamic>? ?? {};
      final propType = propSchema['type'] as String? ?? 'string';
      final valueRule = _typeToRule(propType, key);
      // Build the grammar fragment: `"key" space ":" space <rule>`.
      // The double-quote chars around the key must appear literally so that
      // GBNF matches a JSON key including its surrounding quotes.
      const q = '"';
      rootParts.add('$q$key$q space ":" space $valueRule');
    }

    final rootBody = rootParts.join(' "," space ');
    final rootRule = 'root ::= "{" space $rootBody space "}"';

    final buffer = StringBuffer();
    buffer.writeln(rootRule);
    buffer.writeln();
    _writeBaseRules(buffer);
    return buffer.toString();
  }

  static String _typeToRule(String propType, String key) {
    switch (propType) {
      case 'string':
        return 'string';
      case 'number':
        return 'number';
      case 'integer':
        return 'integer';
      case 'boolean':
        return 'boolean';
      default:
        throw ArgumentError(
          'Unsupported property type "$propType" for key "$key".',
        );
    }
  }

  static void _writeBaseRules(StringBuffer buf) {
    buf.writeln(r'string ::= "\"" ( [^"\\] | "\\" ["\\/bfnrt] )* "\""');
    buf.writeln('number ::= [0-9]+ ("." [0-9]+)?');
    buf.writeln('integer ::= [0-9]+');
    buf.writeln('boolean ::= "true" | "false"');
    buf.writeln('space ::= " "*');
  }
}
