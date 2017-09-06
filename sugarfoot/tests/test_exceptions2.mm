meme foo
requires test


// -- module functions --

i: fun(fn) {
  fn(1);
}

main: fun() {
  var a = 0;
  var fn = fun(x) { a = a + x; };
  try {
    i(fn);
  } catch(Exception e) {
    test.assert(false, "Shouldn't execute catch");
  }
  test.assertEqual(a, 1, "Executing code after try/catch");
}

// -- module classes --

class MyException
fields: x;
init new: fun(x) {
  @x = x;
}

instance_method throw: fun() {
   <primitive "exception_throw">
}

instance_method x: fun() {
  return @x;
}

class_method throw: fun(x) {
  var self = MyException.new(x);
  self.throw();
}

end //exceptions2:MyException
