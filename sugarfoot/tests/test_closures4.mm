meme foo
requires test

// -- module functions --

main: fun() {
  var f = fun() {
    var y = 10;
    return fun(x) { x + y };
  };
  var k = x(f);
  test.assertEqual(k, 20, "manipulating returned closure");
}

x: fun(g) {
  return g()(10);
}

// -- module classes --
