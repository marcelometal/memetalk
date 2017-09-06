meme foo
requires test

main: fun() {
  var f1 = fun() {
    var z = 0;
    return fun(k) { z = z + k; z };
  };
  var f2 = fun() {
    var z = 0;
    return fun(k) { z = z + k; z };
  };

  var f3 = f1();
  var f4 = f2();
  test.assertEqual(f3(10), 10, "local f1::z receives 10");
  test.assertEqual(f3(10), 20, "local f1::z receives 20");

  test.assertEqual(f4(10), 10, "local f2::z receives 10");
  test.assertEqual(f4(10), 20, "local f2::z receives 20");
}

