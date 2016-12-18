// Emits js from pascal ast    

function emit_raw(js) {
  console.log(js);
}

function emit_statement(stmt) {
  switch (stmt.statement) {
    case 'compound':
      emit_raw('{');
      emit_statements(stmt.statements);
      emit_raw('}');
      break;
    case 'call':
      emit_raw(stmt.target + '(' + stmt.arguments.join(', ') + ');');
      break;
    case 'assignment':
      emit_raw(stmt.to + ' = '  + stmt.from);
      break;
    case 'for':
      var update = stmt.direction == "to" ? (stmt.variable+'++') : (stmt.variable+'--');
      var stop_criterion = stmt.direction == "to" ? (stmt.variable + '<=' + stmt.stop ) : (stmt.variable+'>='+stmt.stop);
      emit_raw('for (' + stmt.variable + '=' + stmt.start + '; ' + stop_criterion + '; ' + update + ') {');
      emit_statement(stmt.do)
      emit_raw('}');
      break;
    case 'if':
      emit_raw('if (' + stmt.condition + ')');
      emit_statement(stmt.then);
      emit_raw('else');
      emit_statement(stmt.else);
      break;
    default:
      throw "Unknown statement: " + stmt.statement;
  }
}

function emit_statements(statements) {
  for (var i = 0; i < statements.length; i++)
  {
    emit_statement(statements[i]);
  }
}

function emit_node(node) {
  var v = node.declarations.variables;
  if (v) {
    for (var i = 0; i < v.length; i++)
    {
      emit_raw("var " + v[i] + ";");
    }
  }
  var p = node.declarations.procedures;
  if (p) {
    for (var i = 0; i < p.length; i++)
    {
      var flat_args = [];
      for (var j = 0; j < p[i].arguments.length; j++) {
        flat_args = flat_args.concat(p[i].arguments[j]);
      }

      emit_raw("function " + p[i].name + "(" + flat_args.join(',') + ") {");
      if (p[i].ret) {
        emit_raw('var ' + p[i].name + ";");
        emit_node(p[i].block);
        emit_raw('return ' + p[i].name + ";");
      } else {
        emit_node(p[i].block);
      }
      emit_raw("}");
    }
  }

  emit_statements(node.statements);
}

function emit(ast) {
  // emit std unit
  emit_raw('// Genrated by pascaljs');
  emit_raw("function WriteLn() { var args = Array.prototype.slice.call(arguments); console.log(args.join('')); }");

  emit_node(ast);
}

module.exports = {
  emit:       emit
};
