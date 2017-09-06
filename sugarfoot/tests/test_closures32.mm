meme foo
requires test

a: fun() {
  return fun() { 10 }();
}

b: fun() {
  return fun() { 20; }();
}

c: fun() {
  return fun() { ^ 30; }();
}

d: fun() {
  return fun() { 40; 50 }();
}

e: fun() {
  return fun() { 60; 70; }();
}

f: fun() {
  return fun() { if (true) { 11; } else { 12; } 90 }();
}

g: fun() {
  return fun() { }();
}

main: fun() {
 test.assertEqual(a(), 10, "expr without semicol");
 test.assertEqual(b(), 20, "expr with semicol");
 test.assertEqual(c(), 30, "non local return");
 test.assertEqual(d(), 50, "multiple expr, last without semicol");
 test.assertEqual(e(), 70, "multiple expr, last with semicol");
 test.assertEqual(f(), 90, "statement and expr without semicol");
 test.assertEqual(g(), null, "empty body");
}
