meme foo
requires ometa_base
where
  ometa_base = central:memescript/ometa_base
import OMetaBase from ometa_base

class MemeScriptTranslator < OMetaBase
fields: proc;
init new: fun(proc, input) {
  super.new(input);
  @proc = proc;
}

instance_method start: fun() {
  var modobj = null;
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:module]);
      this._apply(:anything);
      modobj = @proc.new_module();
      this._apply_with_args(:meta_section, [modobj]);
      this._apply_with_args(:requirements_section, [modobj]);
      this._apply_with_args(:code_section, [modobj]);});
  }]);
}
instance_method meta_section: fun() {
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:meta]);
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:meta_var, [modobj]);}, null);});});
  }]);
}
instance_method meta_var: fun() {
  var key = null;
  var val = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      key = this._apply(:anything);
      val = this._apply(:anything);});
    return modobj.add_meta(key, val);
  }]);
}
instance_method requirements_section: fun() {
  var params = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:requirements]);
      params = this._apply(:module_params);
      modobj.set_params(params);
      this._form(fun() {
        this._apply_with_args(:exactly, [:default-locations]);
        this._form(fun() {
          this._many(fun() {
            this._apply_with_args(:default_location, [modobj]);}, null);});});
      this._form(fun() {
        this._apply_with_args(:exactly, [:imports]);
        this._form(fun() {
          this._many(fun() {
            this._apply_with_args(:module_import, [modobj]);}, null);});});});
  }]);
}
instance_method module_params: fun() {
  var xs = null;
  return this._or([fun() {
    this._form(fun() {
      xs = this._many(fun() {
        this._apply(:anything);}, null);});
    return xs;
  }]);
}
instance_method default_location: fun() {
  var mod = null;
  var path = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      mod = this._apply(:anything);
      path = this._apply(:anything);});
    return modobj.add_default_location(mod, path);
  }]);
}
instance_method module_import: fun() {
  var name = null;
  var from = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      name = this._apply(:anything);
      from = this._apply(:anything);});
    return modobj.add_import(name, from);
  }]);
}
instance_method code_secion: fun() {
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:code]);
      this._not(fun() {
        this._not(fun() {
          this._form(fun() {
            this._many(fun() {
              this._apply_with_args(:load_top_level_name, [modobj]);}, null);});});});
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:definition, [modobj]);}, null);});});
  }]);
}
instance_method load_top_level_name: fun() {
  var name = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:class]);
      this._form(fun() {
        name = this._apply(:anything);
        this._apply(:anything);});
      this._many(fun() {
        this._apply(:anything);}, null);});
    return modobj.add_top_level_name(name);
  }, fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:object]);
      name = this._apply(:anything);
      this._many(fun() {
        this._apply(:anything);}, null);});
    return modobj.add_top_level_name(name);
  }, fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:fun]);
      name = this._apply(:anything);
      this._many(fun() {
        this._apply(:anything);}, null);});
    return modobj.add_top_level_name(name);
  }]);
}
instance_method definition: fun() {
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._apply_with_args(:function_definition, [modobj]);
  }, fun() {
    this._apply_with_args(:class_definition, [modobj]);
  }, fun() {
    this._apply_with_args(:object_definition, [modobj]);
  }]);
}
instance_method function_definition: fun() {
  var ast = null;
  var name = null;
  var p = null;
  var fnobj = null;
  var uses_env = null;
  var bproc = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    this._form(fun() {
      this._apply_with_args(:exactly, [:fun]);
      name = this._apply(:anything);
      p = this._apply(:params);
      fnobj = modobj.new_function(name, p);
      fnobj.set_line(ast);
      uses_env = this._apply(:anything);
      fnobj.uses_env(uses_env);
      bproc = fnobj.body_processor;
      this._form(fun() {
        this._apply_with_args(:exactly, [:body]);
        this._apply_with_args(:body, [bproc]);});});
    fnobj.set_text(ast.text);
  }]);
}
instance_method class_definition: fun() {
  var name = null;
  var parent = null;
  var fields_list = null;
  var klass = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:class]);
      this._form(fun() {
        name = this._apply(:anything);
        parent = this._apply(:anything);});
      this._form(fun() {
        this._apply_with_args(:exactly, [:fields]);
        fields_list = this._apply(:anything);});
      klass = modobj.new_class(name, parent, fields_list);
      this._apply_with_args(:constructors, [klass]);
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:instance_method, [klass]);}, null);});
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:class_method, [klass]);}, null);});});
  }]);
}
instance_method constructor: fun() {
  var ast = null;
  var name = null;
  var fnobj = null;
  var p = null;
  var uses_env = null;
  var bproc = null;
  var klass = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    this._form(fun() {
      this._apply_with_args(:exactly, [:ctor]);
      name = this._apply(:anything);
      fnobj = klass.new_ctor(name);
      p = this._apply_with_args(:fparams, [fnobj]);
      fnobj.set_params(p);
      fnobj.set_line(ast);
      uses_env = this._apply(:anything);
      fnobj.uses_env(uses_env);
      bproc = fnobj.body_processor;
      this._form(fun() {
        this._apply_with_args(:exactly, [:body]);
        this._apply_with_args(:body, [bproc]);});});
    fnobj.set_text(ast.text);
  }]);
}
instance_method constructors: fun() {
  var klass = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:ctors]);
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:constructor, [klass]);}, null);});});
  }, fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:ctors]);
      this._form(fun() {
});});
  }]);
}
instance_method instance_method: fun() {
  var ast = null;
  var name = null;
  var fnobj = null;
  var p = null;
  var uses_env = null;
  var bproc = null;
  var klass = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    this._form(fun() {
      this._apply_with_args(:exactly, [:fun]);
      name = this._apply(:anything);
      fnobj = klass.new_instance_method(name);
      p = this._apply_with_args(:fparams, [fnobj]);
      fnobj.set_params(p);
      fnobj.set_line(ast);
      uses_env = this._apply(:anything);
      fnobj.uses_env(uses_env);
      bproc = fnobj.body_processor;
      this._form(fun() {
        this._apply_with_args(:exactly, [:body]);
        this._apply_with_args(:body, [bproc]);});});
    fnobj.set_text(ast.text);
  }]);
}
instance_method class_method: fun() {
  var ast = null;
  var name = null;
  var fnobj = null;
  var p = null;
  var uses_env = null;
  var bproc = null;
  var klass = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    this._form(fun() {
      this._apply_with_args(:exactly, [:fun]);
      name = this._apply(:anything);
      fnobj = klass.new_class_method(name);
      p = this._apply_with_args(:fparams, [fnobj]);
      fnobj.set_params(p);
      fnobj.set_line(ast);
      uses_env = this._apply(:anything);
      fnobj.uses_env(uses_env);
      bproc = fnobj.body_processor;
      this._form(fun() {
        this._apply_with_args(:exactly, [:body]);
        this._apply_with_args(:body, [bproc]);});});
    fnobj.set_text(ast.text);
  }]);
}
instance_method fparams: fun() {
  var x = null;
  var obj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:params]);
      this._form(fun() {
        x = this._many(fun() {
          this._apply_with_args(:fparam, [obj]);}, null);});});
    return x;
  }]);
}
instance_method fparam: fun() {
  var x = null;
  var obj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:var-arg]);
      x = this._apply(:anything);
      obj.set_vararg(x);});
    return x;
  }, fun() {
    this._apply(:anything);
  }]);
}
instance_method params: fun() {
  var x = null;
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:params]);
      this._form(fun() {
        x = this._many(fun() {
          this._apply(:param);}, null);});});
    return x;
  }]);
}
instance_method param: fun() {
  var x = null;
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:var-arg]);
      x = this._apply(:anything);});
    return x;
  }, fun() {
    this._apply(:anything);
  }]);
}
instance_method object_definition: fun() {
  var name = null;
  var obj = null;
  var modobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:object]);
      name = this._apply(:anything);
      obj = modobj.new_object(name);
      this._form(fun() {
        this._many1(fun() {
          this._apply_with_args(:obj_slot, [obj]);});});
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:obj_function, [obj]);}, null);});});
  }]);
}
instance_method obj_slot: fun() {
  var obj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:slot]);
      this._apply_with_args(:obj_slot_value, [obj]);});
  }]);
}
instance_method obj_slot_value: fun() {
  var name = null;
  var x = null;
  var obj = this._apply(:anything);
  return this._or([fun() {
    name = this._apply(:anything);
    this._form(fun() {
      this._apply_with_args(:exactly, [:literal-number]);
      x = this._apply(:anything);});
    return obj.add_slot_literal_num(name,x);
  }, fun() {
    name = this._apply(:anything);
    this._form(fun() {
      this._apply_with_args(:exactly, [:literal-string]);
      x = this._apply(:anything);});
    return obj.add_slot_literal_string(name,x);
  }, fun() {
    name = this._apply(:anything);
    this._form(fun() {
      this._apply_with_args(:exactly, [:literal]);
      this._apply_with_args(:exactly, [:null]);});
    return obj.add_slot_literal_null(name);
  }, fun() {
    name = this._apply(:anything);
    this._form(fun() {
      this._apply_with_args(:exactly, [:literal-array]);
      x = this._form(fun() {
        this._many(fun() {
          this._apply(:anything);}, null);});});
    return obj.add_slot_literal_array(name, x);
  }, fun() {
    name = this._apply(:anything);
    this._form(fun() {
      this._apply_with_args(:exactly, [:literal-dict]);
      x = this._many(fun() {
        this._apply(:anything);}, null);});
    return obj.add_slot_literal_dict(name, x);
  }, fun() {
    name = this._apply(:anything);
    x = this._apply(:anything);
    return obj.add_slot_ref(name, x);
  }]);
}
instance_method obj_function: fun() {
  var obj = this._apply(:anything);
  return this._or([fun() {
    this._apply_with_args(:constructor, [obj]);
  }, fun() {
    this._apply_with_args(:function_definition, [obj]);
  }]);
}
instance_method body: fun() {
  var name = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
  }, fun() {
    this._form(fun() {
      this._form(fun() {
        this._apply_with_args(:exactly, [:primitive]);
        this._form(fun() {
          this._apply_with_args(:exactly, [:literal-string]);
          name = this._apply(:anything);});});
      this._many(fun() {
        this._apply(:anything);}, null);});
    return fnobj.set_primitive(name);
  }]);
}
instance_method exprs: fun() {
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
  }]);
}
instance_method expr_elif: fun() {
  var lb_next = null;
  var lb_jmp = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:elif]);
      this._apply_with_args(:expr, [fnobj]);
      lb_next = fnobj.emit_jz(null);
      this._form(fun() {
        this._many(fun() {
          this._apply_with_args(:expr, [fnobj]);}, null);
        lb_jmp = fnobj.emit_jmp(null);});});
    lb_next.as_current();
    return lb_jmp;
  }]);
}
instance_method stm: fun() {
  var id = null;
  var s = null;
  var arity = null;
  var name = null;
  var e = null;
  var lb_next = null;
  var lb_end = null;
  var lbs_end = null;
  var lbcond = null;
  var lbend = null;
  var label_begin_try = null;
  var end_pos = null;
  var label_begin_catch = null;
  var cp = null;
  var v = null;
  var lhs = null;
  var f = null;
  var x = null;
  var p = null;
  var fnobj = this._apply(:anything);
  var ast = this._apply(:anything);
  return this._or([fun() {
    this._apply_with_args(:exactly, [:var-def]);
    id = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_var_decl(ast, id);
  }, fun() {
    this._apply_with_args(:exactly, [:end-body]);
    return fnobj.emit_end_body(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:return]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_return_top(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:return-null]);
    return fnobj.emit_return_null(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:return-top]);
    return fnobj.emit_return_top(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:non-local-return]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_non_local_return(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:super-ctor-send]);
    s = this._apply(:anything);
    arity = this._apply_with_args(:args, [fnobj]);
    return fnobj.emit_super_ctor_send(ast, s, arity);
  }, fun() {
    this._apply_with_args(:exactly, [:send-or-local-call]);
    name = this._apply(:anything);
    arity = this._apply_with_args(:args, [fnobj]);
    return fnobj.emit_send_or_local_call(ast, name, arity);
  }, fun() {
    this._apply_with_args(:exactly, [:super-send]);
    arity = this._apply_with_args(:args, [fnobj]);
    return fnobj.emit_super_send(ast, arity);
  }, fun() {
    this._apply_with_args(:exactly, [:send]);
    e = this._apply(:anything);
    s = this._apply(:anything);
    arity = this._apply_with_args(:args, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_send(ast, s, arity);
  }, fun() {
    this._apply_with_args(:exactly, [:call]);
    e = this._apply(:anything);
    arity = this._apply_with_args(:args, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_call(ast, arity);
  }, fun() {
    this._apply_with_args(:exactly, [:expression]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_pop(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:not]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_unary(ast,"!");
  }, fun() {
    this._apply_with_args(:exactly, [:negative]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_unary(ast,"neg");
  }, fun() {
    this._apply_with_args(:exactly, [:bit-neg]);
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_unary(ast,"~");
  }, fun() {
    this._apply_with_args(:exactly, [:and]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"and");
  }, fun() {
    this._apply_with_args(:exactly, [:or]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"or");
  }, fun() {
    this._apply_with_args(:exactly, [:+]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"+");
  }, fun() {
    this._apply_with_args(:exactly, [:-]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"-");
  }, fun() {
    this._apply_with_args(:exactly, [:*]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"*");
  }, fun() {
    this._apply_with_args(:exactly, [:/]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"/");
  }, fun() {
    this._apply_with_args(:exactly, [:&]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"&");
  }, fun() {
    this._apply_with_args(:exactly, [:|]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"|");
  }, fun() {
    this._apply_with_args(:exactly, [:<]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"<");
  }, fun() {
    this._apply_with_args(:exactly, [:<<]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"<<");
  }, fun() {
    this._apply_with_args(:exactly, [:>>]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,">>");
  }, fun() {
    this._apply_with_args(:exactly, [:<=]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"<=");
  }, fun() {
    this._apply_with_args(:exactly, [:>]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,">");
  }, fun() {
    this._apply_with_args(:exactly, [:>=]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,">=");
  }, fun() {
    this._apply_with_args(:exactly, [:==]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"==");
  }, fun() {
    this._apply_with_args(:exactly, [:!=]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_binary(ast,"!=");
  }, fun() {
    this._apply_with_args(:exactly, [:if]);
    this._apply_with_args(:expr, [fnobj]);
    lb_next = fnobj.emit_jz(null);
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);
      lb_end = fnobj.emit_jmp(null);});
    lb_next.as_current();
    this._form(fun() {
      lbs_end = this._many(fun() {
        this._apply_with_args(:expr_elif, [fnobj]);}, null);});
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
    lb_end.as_current();
    lbs_end.map(fun(x) { x.as_current()});
  }, fun() {
    this._apply_with_args(:exactly, [:while]);
    lbcond = fnobj.current_label(false);
    this._apply_with_args(:expr, [fnobj]);
    lbend = fnobj.emit_jz(null);
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
    fnobj.emit_jmp_back(lbcond.as_current());
    return lbend.as_current();
  }, fun() {
    this._apply_with_args(:exactly, [:try]);
    label_begin_try = fnobj.current_label(true);
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
    end_pos = fnobj.emit_catch_jump();
    label_begin_catch = fnobj.current_label(true);
    cp = this._apply(:catch_decl);
    fnobj.bind_catch_var(cp[1]);
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
    return fnobj.emit_try_catch(label_begin_try, label_begin_catch, end_pos, cp[0]);
  }, fun() {
    this._apply_with_args(:exactly, [:=]);
    this._form(fun() {
      this._apply_with_args(:exactly, [:id]);
      v = this._apply(:anything);});
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_local_assignment(ast, v);
  }, fun() {
    this._apply_with_args(:exactly, [:=]);
    this._form(fun() {
      this._apply_with_args(:exactly, [:index]);
      lhs = this._apply(:anything);
      this._apply_with_args(:expr, [fnobj]);});
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,lhs]);
    return fnobj.emit_index_assignment(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:=]);
    this._form(fun() {
      this._apply_with_args(:exactly, [:field]);
      f = this._apply(:anything);});
    this._apply_with_args(:expr, [fnobj]);
    return fnobj.emit_field_assignment(ast, f);
  }, fun() {
    this._apply_with_args(:exactly, [:literal-number]);
    x = this._apply(:anything);
    return fnobj.emit_push_num_literal(ast, x);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:this]);
    return fnobj.emit_push_this(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:literal-string]);
    x = this._apply(:anything);
    return fnobj.emit_push_str_literal(ast, x);
  }, fun() {
    this._apply_with_args(:exactly, [:literal-symbol]);
    x = this._apply(:anything);
    return fnobj.emit_push_sym_literal(ast, x);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:null]);
    return fnobj.emit_push_null(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:true]);
    return fnobj.emit_push_true(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:false]);
    return fnobj.emit_push_false(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:module]);
    return fnobj.emit_push_module(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:literal]);
    this._apply_with_args(:exactly, [:context]);
    return fnobj.emit_push_context(ast);
  }, fun() {
    this._apply_with_args(:exactly, [:id]);
    name = this._apply(:anything);
    return fnobj.emit_push_var(ast, name);
  }, fun() {
    this._apply_with_args(:exactly, [:field]);
    name = this._apply(:anything);
    return fnobj.emit_push_field(ast, name);
  }, fun() {
    this._apply_with_args(:exactly, [:literal-array]);
    e = this._apply(:anything);
    this._apply_with_args(:exprs, [fnobj,e]);
    return fnobj.emit_push_list(ast, e.size);
  }, fun() {
    this._apply_with_args(:exactly, [:literal-dict]);
    p = this._apply_with_args(:dict_pairs, [fnobj]);
    return fnobj.emit_push_dict(ast, p.size);
  }, fun() {
    this._apply_with_args(:exactly, [:index]);
    e = this._apply(:anything);
    this._apply_with_args(:expr, [fnobj]);
    this._apply_with_args(:expr, [fnobj,e]);
    return fnobj.emit_push_index(ast);
  }]);
}
instance_method expr: fun() {
  var ast = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    this._form(fun() {
      this._apply_with_args(:stm, [fnobj,ast]);});
  }, fun() {
    this._apply_with_args(:funliteral, [fnobj]);
  }]);
}
instance_method catch_decl: fun() {
  var type = null;
  var id = null;
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:catch]);
      this._form(fun() {
        this._apply_with_args(:exactly, [:id]);
        type = this._apply(:anything);});
      id = this._apply(:anything);});
    return [type, id];
  }, fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:catch]);
      id = this._apply(:anything);});
    return [null, id];
  }]);
}
instance_method dict_pairs: fun() {
  var e = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    e = this._many(fun() {
      this._or([fun() {
        this._form(fun() {
          this._apply_with_args(:exactly, [:pair]);
          this._apply_with_args(:expr, [fnobj]);
          this._apply_with_args(:expr, [fnobj]);});
      }]);}, null);
    return e;
  }]);
}
instance_method funliteral: fun() {
  var ast = null;
  var p = null;
  var fn = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    ast = this._form(fun() {
      this._apply_with_args(:exactly, [:fun-literal]);
      p = this._apply(:params);
      fn = fnobj.new_closure(p);
      fn.set_line(ast);
      this._form(fun() {
        this._apply_with_args(:exactly, [:body]);
        this._form(fun() {
          this._many(fun() {
            this._apply_with_args(:expr, [fn]);}, null);});});});
    fn.set_text(ast.text);
    return fnobj.emit_push_closure(ast, fn);
  }]);
}
instance_method cfunliteral: fun() {
  var ast = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    ast = this.input.head();
    fnobj.set_line(ast);
    this._form(fun() {
      this._many(fun() {
        this._apply_with_args(:expr, [fnobj]);}, null);});
    return fnobj;
  }]);
}
instance_method args: fun() {
  var arity = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:args]);
      this._form(fun() {
});});
    return 0;
  }, fun() {
    this._form(fun() {
      this._apply_with_args(:exactly, [:args]);
      arity = this._apply_with_args(:arglist, [fnobj]);});
    return arity;
  }]);
}
instance_method arglist: fun() {
  var x = null;
  var fnobj = this._apply(:anything);
  return this._or([fun() {
    x = this._form(fun() {
      this._many1(fun() {
        this._apply_with_args(:expr, [fnobj]);});});
    return x.size;
  }]);
}


end //MemeScriptTranslator
