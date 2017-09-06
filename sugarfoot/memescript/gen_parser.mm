.preamble(ometa, ometa_tr, ometa_base, io)
 ometa : meme:ometa;
 ometa_tr : meme:ometa_tr;
 ometa_base : meme:ometa_base;
 io : meme:io;
.code

gen: fun(grammar_in_file_path, grammar_out_file_path, OMeta, OMetaTranslator) {
  io.print("=== processing " + grammar_in_file_path);
  var text = io.read_file(grammar_in_file_path);
  var maybe_ast = ometa_base.parse(text, OMeta, :mm_module);
  io.print(maybe_ast.toSource);
  if (maybe_ast[0]) {
    io.print("parse error: " + maybe_ast[0].toString);
  } else {
    io.print("\n\ntranslating...\n\n");
    maybe_ast = ometa_base.parse([maybe_ast[1]], OMetaTranslator, :mm_module);
    if (maybe_ast[0]) {
      io.print("translation error: " + maybe_ast[0].toString);
    } else {
      io.write_file(grammar_out_file_path, maybe_ast[1]);
      io.print("Wrote to " + grammar_out_file_path);
    }
  }
}

main: fun() {
  var name = argv()[1];
  gen("compiler/" + name + ".g", "compiler/" + name + ".mm", ometa.OMeta, ometa_tr.OMetaTranslator);
}

.endcode
