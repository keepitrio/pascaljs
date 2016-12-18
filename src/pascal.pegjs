{
  // --- Utils -------
  function to_str(x) {
      return x.join('');
  }
  function nth(arr, n) {
      var results = [];
      for (var i = 0; i < arr.length; i++) {
          results.push(arr[i][n]);
      }
      return results;
  }
  function buildList(first, rest, n, joiner, join_translation) {
    var results = first ? [first] : [];
    for (var i = 0; i < rest.length; i++) {
      if (joiner) {
        var j = rest[i][joiner];
        if (j in join_translation) {
          results.push(join_translation[j]);
        } else {
          results.push(j);
        }
      }
      results.push(rest[i][n]);
    }
    return results.join(' ');
  }
}

program
  = "program" _ identifier ";" _ root:block "."  { return root; }

block
  = d:declarations "begin" _ s:statements _ "end" { return {'declarations': d, 'statements': s}; }

statements
  = all:(statement ";" _)*  { return nth(all, 0); }

declarations 
  = procs:(procedure_declaration / function_declaration)* vars:vars? { return {'procedures': procs, 'variables': vars}; }

// PROCEDURE DECLARATION
procedure_declaration 
  = "procedure" _ name:identifier "(" args:argument_list_declaration ")" _ ";" _ block:block ";" _ { return {'name': name, 'arguments': args, 'block': block, 'ret': false}; }

function_declaration 
  = "function" _ name:identifier "(" args:argument_list_declaration ")" _ ":" _ type ";" _ block:block ";" _ { return {'name': name, 'arguments': args, 'block': block, 'ret': true}; }

argument_list_declaration
  = first:argument_declaration? rest:("," _ argument_declaration)* { return [first].concat(nth(rest, 2)); }

argument_declaration
  = first:identifier rest:("," _ identifier)* ":" _ type { return [first].concat(nth(rest, 2)); }

// VARIABLE DECLARATION
vars
  = "var" _ vars:var+ { return vars; } 
  
var
  = variable_name:identifier ":" _ type ";" _ { return variable_name; }

type "type"
  = identifier

// STATEMENTS
statement
  = compound / procedure_call / assignment / if_stmt / for

compound
  = "begin" _ stmts:statements _ "end" { return {'statement': 'compound', 'statements': stmts}; }

assignment
  = variable_name:identifier _ ":=" _ value:expression { return {'statement': 'assignment', 'to': variable_name, 'from': value}; }

procedure_call
  = procedure:identifier _ "(" args:argument_list ")"  { return {'statement': 'call', 'target': procedure, 'arguments': args}; }

argument_list
  = first:argument? rest:("," _ argument)* { return [first].concat(nth(rest, 2)); }

argument
  = expression

if_stmt
  = "if" _ e:expression _ "then" _ stmt1:statement _ "else" _ stmt2:statement { return {'statement': 'if', 'condition': e, 'then': stmt1, 'else': stmt2}; }

for
  = "for" _ variable:identifier _ ":=" _ start:expression _ direction:("to" / "downto") _ stop:expression _ "do" _ stmt:statement { return {'statement': 'for', 'variable': variable, 'start': start, 'stop': stop, 'direction': direction, 'do': stmt }; }

// HERE GOES EXPRESSOINS
function_call "function call"
  = func:identifier _ "(" args:argument_list ")"  { return func + '(' + args + ')'; }

expression "expression"
  = comparision / or_expr

comparision
  = a:or_expr _ "=" _ b:or_expr { return [a, '==', b].join(''); }
  / a:or_expr _ "<>" _ b:or_expr { return [a, '!=', b].join(''); }
  / a:or_expr _ ">=" _ b:or_expr { return [a, '>=', b].join(''); }
  / a:or_expr _ "<=" _ b:or_expr { return [a, '<=', b].join(''); }
  / a:or_expr _ ">" _ b:or_expr { return [a, '>', b].join(''); }
  / a:or_expr _ "<" _ b:or_expr { return [a, '<', b].join(''); }

or_expr 
  = first:and_expr rest:( _ ("or" / "+") _ and_expr )* { return buildList(first, rest, 3,  1, {'or': '||'}); }

and_expr
  = first:base_expr rest:( _ ("and" / "*") _ base_expr )* { return buildList(first, rest, 3,  1, {'and': '&&'}); }

base_expr
  = primary / "(" _ expression _ ")" { return text(); }

primary
  = function_call / literal / variable

variable "variable"
  = variable_name:identifier 

identifier "identifier"
   = [A-Za-z][A-Za-z0-9]* { return text(); } 

// LITERALS

literal "literal"
  = string_literal / boolean_literal / integer_literal

string_literal
  = "'" [A-Za-z0-9 ,;:+/=<>]* "'"  { return text(); }

boolean_literal
  = "true" / "false"

integer_literal
  = [0-9]+ { return text(); }

_ "whitespace"
  = [ \t\n\r]* { return '' }
