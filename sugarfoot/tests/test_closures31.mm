meme foo
requires test

class X
fields: a,b, c;
init new: fun(a,b,c) {
  @a = a;
  @b = b;
  @c = c;
  var x = fun() { }; //using env
}
instance_method a: fun() { return @a; }
instance_method b: fun() { return @b; }
instance_method c: fun() { return @c; }
end

main: fun() {
  var x = X.new(4,5,6);
  test.assertEqual(x.a, 4, "x.a from env");
  test.assertEqual(x.b, 5, "x.b from env");
  test.assertEqual(x.c, 6, "x.c from env");
}
