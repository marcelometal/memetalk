meme foo
requires test

main: fun() {
  test.assertEqual(X.new().bla(), 10, "Closure accessing instance field");
}

class X
fields: bla;
init new: fun() {
  var f = fun() {
    @bla = 10;
  };
  f();
}

instance_method bla: fun() {
  return @bla;
}

end
