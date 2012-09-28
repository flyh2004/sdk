// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test the feature where the native string declares the native method's name.

@native("*A")
class A {
  @native('fooA')
  int foo();
}

@native("*B")
class B extends A  {
  @native('fooB')
  int foo();
}

@native makeA();
@native makeB();

@native("""
// This code is all inside 'setup' and so not accesible from the global scope.
function inherits(child, parent) {
  if (child.prototype.__proto__) {
    child.prototype.__proto__ = parent.prototype;
  } else {
    function tmp() {};
    tmp.prototype = parent.prototype;
    child.prototype = new tmp();
    child.prototype.constructor = child;
  }
}
function A(){}
A.prototype.fooA = function(){return 100;};
function B(){}
inherits(B, A);
B.prototype.fooB = function(){return 200;};

makeA = function(){return new A};
makeB = function(){return new B};
""")
void setup();

testDynamic() {
  var things = [makeA(), makeB()];
  var a = things[0];
  var b = things[1];

  Expect.equals(100, a.foo());
  Expect.equals(200, b.foo());

  expectNoSuchMethod((){ a.fooA(); }, 'fooA should be invisible on A');
  expectNoSuchMethod((){ b.fooA(); }, 'fooA should be invisible on B');

  expectNoSuchMethod((){ a.fooB(); }, 'fooB should be absent on A');
  expectNoSuchMethod((){ b.fooB(); }, 'fooA should be invisible on B');
}

testTyped() {
  A a = makeA();
  B b = makeB();

  Expect.equals(100, a.foo());
  Expect.equals(200, b.foo());
}

main() {
  setup();

  testDynamic();
  testTyped();
}

expectNoSuchMethod(action, note) {
  bool caught = false;
  try {
    action();
  } catch (ex) {
    caught = true;
    Expect.isTrue(ex is NoSuchMethodError, note);
  }
  Expect.isTrue(caught, note);
}
