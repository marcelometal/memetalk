meme foo
requires test

main: fun() {
  var z = 9;
  var f = fun() {
    var y = 10;
    return fun(x) { z + x + y };
  };
  var w = fun() {
    var z = 1000;
    return z;
  };
  var j = w();
  var k = x(f);
  test.assertEqual(x(f), 29, "Shadowing identifier with nested closures");
}

x: fun(g) {
  return g()(10);
}
