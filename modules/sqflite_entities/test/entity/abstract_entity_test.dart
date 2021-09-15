import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';

class _Foo extends AbstractEntity {}
class _Bar extends AbstractEntity {}

void main() {
  var f1 = _Foo();
  var f2 = _Foo();
  var b1 = _Bar();

  setUp(() {
    f1 = _Foo();
    f2 = _Foo();
    b1 = _Bar();
  });

  test('Null is never equal', () {
    expect(_Foo() == _Foo(), isFalse);

    final f = _Foo();
    f.id = 1;
    expect(_Foo() == f, isFalse);
  });

  test('Foo equal test', () {
    expect(f1 == f1, isTrue);
    expect(f1 == f2, isFalse);

    f1.id = 1;
    expect(f1 == f1, isTrue);

    f2.id = 1;
    expect(f1 == f2, isTrue);

    f2.id = 2;
    expect(f1 == f2, isFalse);
  });

  test('Text equal to other entity', () {
    expect(f1 == b1, isFalse);

    f1.id = 1;
    b1.id = 1;
    expect(f1 == b1, isFalse);
  });
}