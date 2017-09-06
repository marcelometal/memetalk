.preamble(io, ometa_base)
 io : meme:io;
 ometa_base: meme:ometa_base;
 [OMetaBase, OMetaStream, OMetaException] <= ometa_base;
.code

ometa_basic_tutorial_1: fun() {
  //examples of basic rules available in ometa_base

  //* ometa_base.parse() is a convenient entry point for parsing.

  //signature: ometa_base.parse(data, class, rule): [maybe_error, result]
  //  - data: is usually either a string or a list of arbitrary objects.
  //  - class: the ometa class to use for parsing
  //  - rule: the name of the entry point rule as a symbol

  //rules:

  //*anything
  var res = ometa_base.parse("xyz", OMetaBase, :anything);
  io.print(res.toSource); //*[null, "x"]

  //*end with empty input:
  res = ometa_base.parse("", OMetaBase, :end);
  io.print(res.toSource); //*[null, true]

  //*end with input:
  res = ometa_base.parse("x", OMetaBase, :end);
  io.print(res.toSource); //*["parse error 1:1", null]

  //*number
  res = ometa_base.parse([10, "hi"], OMetaBase, :number);
  io.print(res.toSource); //*[null, 10]

  //*string: head (i.e. "x") is a string object
  res = ometa_base.parse("xyz", OMetaBase, :string);
  io.print(res.toSource); //*[null, "x"]

  //*string: head (i.e. "hi") is a string object
  res = ometa_base.parse(["hi", 10], OMetaBase, :string);
  io.print(res.toSource); //*[null, "hi"]

  //*symbol
  res = ometa_base.parse([:hi, 10], OMetaBase, :symbol);
  io.print(res.toSource); //*[null, :hi]

  //*char
  res = ometa_base.parse("xyz", OMetaBase, :char);
  io.print(res.toSource); //*[null, "x"]

  //*char: head (i.e. "hi") is not of size 1
  res = ometa_base.parse(["hi", 10], OMetaBase, :char);
  io.print(res.toSource); //*["parse error 1:1", null]

  //*space
  res = ometa_base.parse("\txyz", OMetaBase, :space);
  io.print(res.toSource); //*[null, "	"]

  //*spaces: defined as `spaces*` (i.e. zero or more :space)
  res = ometa_base.parse("\n\t   xyz", OMetaBase, :spaces);
  io.print(res.toSource); //[null, "\n	   "]

  //...so it also matches empty
  res = ometa_base.parse("", OMetaBase, :spaces);
  io.print(res.toSource); //[null, ""]

  //*digit
  res = ometa_base.parse("321", OMetaBase, :digit);
  io.print(res.toSource); //*[null, "3"]

  //*digits
  res = ometa_base.parse("321xyz", OMetaBase, :digits);
  io.print(res.toSource); //*[null, "321"]

  //*lower
  res = ometa_base.parse("xyz", OMetaBase, :lower);
  io.print(res.toSource); //*[null, "x"]

  //... fails with upper, of course
  res = ometa_base.parse("XYZ", OMetaBase, :lower);
  io.print(res.toSource); //*["parse error: 1:2\n", null]

  //*upper
  res = ometa_base.parse("XYZ", OMetaBase, :upper);
  io.print(res.toSource); //*[null, "X"]

  //*letter: defined as `upper | lower`
  res = ometa_base.parse("XYZ", OMetaBase, :letter);
  io.print(res.toSource); //*[null, "X"]


  //*letter_or_digit: as the name suggests, defined as `letter | digit`
  res = ometa_base.parse("321", OMetaBase, :letter_or_digit);
  io.print(res.toSource); //*[null, "3"]

  //*identifier_first: defined as `letter | '_'`
  res = ometa_base.parse("_xyz", OMetaBase, :identifier_first);
  io.print(res.toSource); //*[null, "_"]

  //*identifier_rest: defined as `'_' | letter_or_digit`
  res = ometa_base.parse("321", OMetaBase, :identifier_rest);
  io.print(res.toSource); //*[null, "3"]

  //*identifier: `spaces identifier_first:x {>identifier_rest}*:y => x+y.join("")`
  res = ometa_base.parse("   _x2y3z abc", OMetaBase, :identifier);
  io.print(res.toSource); //*[null, "_x2y3z"]



  //-----------------------
  io.print("The remaining rules in OMetaBase have arity > 1.");
  //We can use parse_with_args and :apply rule to use them
  //signature: apply_with_args(input, class, rule, [args]): [maybe_error, res]


  //*apply(rule): rule()
  res = ometa_base.parse_with_args("xyz", OMetaBase, :apply, [:char]);
  io.print(res.toSource); //*[null, "x"]

  //*exactly(expected): expected
  res = ometa_base.parse_with_args("xyz", OMetaBase, :exactly, ["x"]);
  io.print(res.toSource); //*[null, "x"]

  //...failing
  res = ometa_base.parse_with_args("321", OMetaBase, :exactly, ["x"]);
  io.print(res.toSource); //["parse error: 1:2\n", null]

  //*first_and_rest(rule1, rule2): defined as `rule1 rule2*`
  //  -since this is an abstract rule that can be applied to
  //   other types than strings, it doesn't join() the results.
  res = ometa_base.parse_with_args("a321", OMetaBase,
                                   :first_and_rest, [:letter, :digit]);
  io.print(res.toSource); //[null, ["a", "3", "2", "1"]]

  //...with lists of arbitrary objects
  res = ometa_base.parse_with_args(["3",2,1,0], OMetaBase,
                                   :first_and_rest, [:digit, :number]);
  io.print(res.toSource); //[null, ["3", 2, 1, 0]]


  //*seq(a1, a2, ...an): a1 a2 .... an
  //  this rule "spreads" the args as a sequence of patterns.
  //  e.g. seq('a', 'b') becomes the rule that matches 'a' followed by 'b'
  // -arg to seq() must understand .each()
  res = ometa_base.parse_with_args("x1y", OMetaBase,
                                   :seq, ["x1"]);
  io.print(res.toSource); //[null, ["x", "1"]]


  //...failing
  res = ometa_base.parse_with_args("x1y", OMetaBase,
                                   :seq, ["x2"]);
  io.print(res.toSource); //["parse error: 1:3\n", null]


  //...on lists
  res = ometa_base.parse_with_args([:x, 3, :y, "xyz"], OMetaBase,
                                   :seq, [[:x, 3, :y]]);
  io.print(res.toSource); //[null, [:x, 3, :y]]


  //*token(expected): defined as `spaces seq(expected)`
  res = ometa_base.parse_with_args("x1yabc", OMetaBase,
                                   :token, ["x1y"]);
  io.print(res.toSource); //[null, "x1y"]


  //*keyword(expected): defined as `token(expected) ~identifier_rest`
  res = ometa_base.parse_with_args("class Foo", OMetaBase,
                                   :keyword, ["class"]);
  io.print(res.toSource); //[null, "class"]


  //..failing, since "class" is folllowed by "e", an `identifier_rest`
  res = ometa_base.parse_with_args("classe", OMetaBase,
                                   :keyword, ["class"]);
  io.print(res.toSource); //["parse error: 1:6\n", null]

}

ometa_basic_tutorial_2: fun() {
  //A "lower level" API of ometa is using the class and methods themselves.
  //apply()ing consumes successively data from input.
  //Notice that apply raises OMetaException in match failure.

  var input = OMetaStream.with_data("   xyz abc");
  var parser = OMetaBase.new(input);
  parser.prepend_input(:identifier);
  var res = parser.apply();
  io.print(res.toSource); //"xyz"

  parser.prepend_input(:identifier);
  res = parser.apply();
  io.print(res.toSource); //"abc"

  //dealing with failure...
  parser.prepend_input(:identifier); //no more identifiers left on input
  try {
    res = parser.apply();
  } catch(OMetaException e) {
    io.print("can't apply identifier again: " + input.format_error);
  }
}

main: fun() {
  ometa_basic_tutorial_1();
  ometa_basic_tutorial_2();
}

.endcode
