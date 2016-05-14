.preamble(io, ometa_base)
  io: meme:io;
  ometa_base: meme:ometa_base;
  [OMetaBase, OMetaException] <= ometa_base;
.code

escaped: fun(chr) {
  if (chr == "b") { return  "\b"; }
  if (chr == "f") { return  "\f"; }
  if (chr == "n") { return  "\n"; }
  if (chr == "r") { return  "\r"; }
  if (chr == "t") { return  "\t"; }
  if (chr == "v") { return  "\v"; }
  return chr;
}


class OMeta < OMetaBase
fields: current_production, local_vars;
init new: fun(input) {
  super.new(input);
  @local_vars = [];
}
instance_method add_local_var: fun(name) {
  @local_vars.append(name);
}

// rules...
instance_method ometa: fun() {
  this._apply_with_args(:keyword, ["ometa"]);

  var name = this._apply(:identifier);
  var i = this._apply(:inheritance);

  this._apply_with_args(:token, ["{"]);

  var r = this._apply(:rules);

  this._apply_with_args(:token, ["}"]);
  return [:grammar, name, i, r];
}

instance_method keyword: fun() {
  var xs = this._apply(:anything);
  var ident = this._apply_with_args(:token, [xs]);
  this._not(fun() { this._apply(:identifier_rest) });
  return xs;
}

instance_method inheritance: fun() {
  return this._or([fun() {
                     this._apply_with_args(:token, ["<"]);
                     var ident = this._apply(:identifier);
                     return [:parent, ident]; },
                   fun() { return [:parent, "OMetaBase"]; }]);
}

instance_method rules: fun() {
  return this._many1(fun() { this._apply(:rule) });
}

instance_method rule: fun() {
  var name = this._apply(:identifier);
  @current_production = name;
  var r = this._apply_with_args(:rule_rest, [name]);
  this._apply_with_args(:token, [";"]);
  return r;
}

instance_method rule_rest: fun() {
  var name = this._apply(:anything);
  var args = null;
  var c = null;
  var ac = null;
  return this._or([
    fun() { ac = this._apply(:action);
            return [:rule, name, ac]; },
    fun() { this._apply_with_args(:token, ["="]);
            c = this._apply(:choices);
            return [:rule, name, c];},
    fun() { args = this._many1(fun() { this._apply(:binding) });
            ac = this._apply(:action);
            return [:rule, name, [:args] + args, ac];},
    fun() { args = this._many1(fun() { this._apply(:binding) });
            this._apply_with_args(:token, ["="]);
            c = this._apply(:choices);
            return [:rule, name, [:args] + args, c];}]);
}


instance_method choices: fun() {
  var x = this._apply(:choice);
  var xs = this._many(fun() { this._apply_with_args(:token, ["|"]);
                              return this._apply(:choice);}, null);
  return [:or, x] + xs;
}


instance_method choice: fun() {
  var x = null;
  return this._or([fun() { x = this._many(fun() { this._apply(:top_expression) }, null);
                           var ac = this._apply(:action);
                           return [:and] + x + [ac];},
                   fun() { x = this._many(fun() { this._apply(:top_expression) }, null);
                           return [:and] + x;}]);
}

instance_method top_expression: fun() {
  return this._or([fun() { this._apply(:bind_expression) },
                  fun() { this._apply(:repeated_expression) }]);
}

instance_method bind_expression: fun() {
  var e = this._apply(:repeated_expression);
  var b = this._apply(:binding);
  return [:bind, b, e];
}

instance_method repeated_expression: fun() {
  var e = null;
  return this._or([
    fun() { e = this._apply(:term);
            this._apply_with_args(:token, ["*"]);
            return [:many, e];},
    fun() { e = this._apply(:term);
            this._apply_with_args(:token, ["+"]);
            return [:many1, e];},
    fun() { e = this._apply(:term);
            this._apply_with_args(:token, ["?"]);
            return [:optional, e];},
    fun() { return this._apply(:term); }]);
}

instance_method term: fun() {
  var e = null;
  return this._or([fun() { this._apply_with_args(:token, ["~"]);
                           e = this._apply(:element);
                           return  [:not, e];},
                   fun() { this._apply_with_args(:token, ["&"]);
                           e = this._apply(:element);
                           return [:lookahead, e];},
                   fun() { return this._apply(:element); }]);
}

instance_method binding: fun() { //this.input
  this._apply_with_args(:token, [":"]);
  var i = this._apply(:identifier);
  this.add_local_var(i);
  return i;
}

instance_method element: fun() {
  var s = null;
  var c = null;
  return this._or([fun() { this._apply(:prod_app) },
                   fun() { this._apply(:data_element) },
                   fun() { this._apply_with_args(:token, ["?{"]);
                           s = this._apply_with_args(:until, [["}"]]).join("");
                           this._apply_with_args(:exactly, ["}"]);
                           return [:sem_pred, s];},
                   fun() { this._apply_with_args(:token, ["!{"]);
                           s = this._apply_with_args(:until, [["}"]]).join("");
                           this._apply_with_args(:token, ["}"]);
                           return [:sem_action, s];},
                   fun() { this._apply_with_args(:token, ["{"]);
                           c = this._apply(:choices);
                           this._apply_with_args(:token, ["}"]);
                           return c; }]);
}

instance_method data_element: fun() {
  return this._or([fun() { this._apply(:char_sequence) },
                   fun() { this._apply(:token_string) },
                   fun() { this._apply(:string_object) },
                   fun() { this._apply(:asymbol) },
                   fun() { this._apply(:s_expr) }]);
}

instance_method action: fun() {
  this._apply_with_args(:token, ["=>"]);
  var s = this._apply_with_args(:until, [["}",";","\n"]]).join("");
  return [:action, s];
}

instance_method prod_app: fun() {
  var p = null;
  var args = null;
  return this._or([fun() { this._apply_with_args(:keyword, ["_"]);
                           return [:apply, :anything]; },
                   fun() { this._apply_with_args(:keyword, ["$"]);
                           return [:apply, :end]; },
                   fun() { p = this._apply(:identifier);
                           this._apply_with_args(:token, ["("]);
                           args = this._apply(:prod_args);
                           this._apply_with_args(:token, [")"]);
                           return [:apply_with_args, args, p.toSymbol];},
                   fun() { p = this._apply(:identifier);
                           return [:apply, p.toSymbol];},
                   fun() { this._apply_with_args(:token, ["^"]);
                           return [:apply_super, @current_production];}]);
}

instance_method prod_args: fun() {
  var x = this._apply(:prod_arg);
  return this._many(fun() {
    this._apply_with_args(:token, [","]);
    return this._apply(:prod_arg);
  }, x);
}

instance_method prod_arg: fun() {
  return this._or([fun() { this._apply(:data_element) },
                   fun() { var i = this._apply(:identifier);
                           return [:id, i]; }]);
}

instance_method char_sequence: fun() {
  this._apply(:spaces);
  this._apply_with_args(:exactly, ["'"]);
  var cs = this._many1(fun() {
        return this._or([fun() {
                            this._not(fun() { this._apply_with_args(:exactly, ["'"]) });
                            this._apply_with_args(:exactly, ["\\"]);
                            var c = this._apply(:char);
                            return escaped(c); },
                         fun() {
                            this._not(fun() { this._apply_with_args(:exactly, ["'"]) });
                            return this._apply(:char); }]);
  });
  this._apply_with_args(:exactly, ["'"]);
  return [:seq, cs.join("")];
}

instance_method token_string: fun() {
  this._apply(:spaces);
  this._apply_with_args(:exactly, ["\""]);
  var cs = this._many1(fun() {
        return this._or([fun() {
                            this._not(fun() { this._apply_with_args(:exactly, ["\""]) });
                            this._apply_with_args(:exactly, ["\\"]);
                            var c = this._apply(:char);
                            return escaped(c); },
                         fun() {
                            this._not(fun() { this._apply_with_args(:exactly, ["\""]) });
                            return this._apply(:char); }]);
  });
  this._apply_with_args(:exactly, ["\""]);
  return [:token_string, cs.join("")];
}

instance_method string_object: fun() {
  this._apply(:spaces);
  this._apply_with_args(:exactly, ["`"]);
  var cs = this._many1(fun() {
        return this._or([fun() {
                            this._apply_with_args(:exactly, ["\\"]);
                            this._apply(:char) },
                         fun() {
                            this._not(fun() { this._apply_with_args(:exactly, ["\\"]) });
                            return this._apply(:char); }]);
  }, null);
  this._apply_with_args(:exactly, ["`"]);
  return [:token_string, cs];
}

instance_method asymbol: fun() {
  this._apply_with_args(:token, [":"]);
  var s = this._apply(:identifier);
  return [:symbol, s];
}

instance_method s_expr: fun() {
  this._apply_with_args(:token, ["["]);
  var s = this._apply(:choice);
  this._apply_with_args(:token, ["]"]);
  return [:form, s];
}

end //OMeta


.endcode
