.preamble(io, ometa_base, ometa, ometa_tr)
 io : meme:io;
 ometa_base: meme:ometa_base;
 ometa: meme:ometa;
 ometa_tr: meme:ometa_tr;
 [OMetaBase, OMetaStream, OMetaException] <= ometa_base;
 [OMeta] <= ometa;
 [OMetaTranslator] <= ometa_tr;
.code

//this files generates mm/calc.mm, a parser for a simple calculator.

//Usage:
//  1- compile this file and run it. Make sure mm/calc.mm was generated
//  2- compile calc.mm
//  3- Read & compile using_calc.mm, an example of how to use the calculator.

main: fun() {

  var calc_grammar_mm = [".preamble(io, ometa_base)",
                         "  io : meme:io;",
                         " ometa_base: meme: ometa_base;",
                         " [OMetaBase] <= ometa_base;",
                         ".code",
                         "class Calculator < OMetaBase",
                         "<ometa> //begin grammar rules",
                         "expr = expr:x \"+\" mul:y => x + y",
                         "     | expr:x \"-\" mul:y => x - y",
                         "     | mul;",
                         "mul = mul:x \"*\" num:y => x * y",
                         "     | num;",
                         "num = spaces digit+:xs => xs.join(\"\").toInteger;",
                         "</ometa> //end rules",
                         "end //end Calculator class",
                         ".endcode //end module"
                        ].join("\n");

  io.print("\n-------- the grammar --------");
  io.print(calc_grammar_mm);
  io.print("-----------------------------");

  var maybe_ast = ometa_base.parse(calc_grammar_mm, OMeta, :mm_module);
  if (maybe_ast[0]) {
    io.print("parse error: " + maybe_ast[0]);
  } else {
    io.print(maybe_ast.toSource); //the grammar ast
    io.print("\n\ngenerating parser module...\n\n");
    maybe_ast = ometa_base.parse([maybe_ast[1]], OMetaTranslator, :mm_module);
    if (maybe_ast[0]) {
      io.print("translation error: " + maybe_ast[0].toString);
    } else {
      io.write_file("mm/calc.mm", maybe_ast[1]);
      io.print("Wrote to mm/calc.mm");
    }
  }
}

.endcode
