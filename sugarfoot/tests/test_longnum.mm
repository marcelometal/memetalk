meme foo
requires test

// -- module functions --

test_long_sums: fun() {
  test.assertEqual(4611686018427387901 + 1, 4611686018427387902, "int sum");
  test.assert((4611686018427387903 + 1) > 4611686018427387903, "longnum sum"); //compiler can't handle LongNum literals yet
}

test_sum_overflow: fun() {
  //testing sum overflow
  var long = 4611686018427387903 + 1; //a LongNum
  var too_long = 0;
  try {
    too_long = long + long;
    test.assert(false, "sum should raise overflow");
  } catch(Overflow e) {
    //
  }
  test.assertEqual(too_long, 0, "sum overflow raised");
}

test_sub_overflow: fun() {
  //testing sub overflow
  var long = -4611686018427387903 - 2;  //a LongNum
  var long2 =  4611686018427387903 + 1; //a LongNum
  var too_long = 0;
  try {
    too_long = long - long2;
    test.assert(false, "sub should raise overflow");
  } catch(Overflow e) {
    //
  }
  test.assertEqual(too_long, 0, "sub overflow raised");
}

test_masking_64bits: fun() {
  //test or'ing a long number with most significant biton
  var long = -4611686018427387903 - 1; //a LongNum
  var flag = long * 2;                 //0x8000000000000000
  test.assertEqual(1 | flag , flag + 1, "setting significant bit");
}

main: fun() {
  test_long_sums();
  test_sum_overflow();
  test_sub_overflow();
  test_masking_64bits();
}
