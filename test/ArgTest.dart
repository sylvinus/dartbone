import 'package:unittest/unittest.dart';


bool _call(f,args) {
  if (args.length==0) return f();
  if (args.length==1) return f(args[0]);
}

class MyClass {
    
  func1([arg1]) {
    if (false) return this;
    if (?arg1) return true;
    return false;
  }
  
  func2([arg1]) {
    if (false) return false;
    if (?arg1) return true;
    return false;
  }

}

main() {
  

  test("opt arg bug - succeeds",() {
    
    var K = new MyClass();
    expect(K.func2(),isFalse);
    expect(K.func2("@sylvinus"),isTrue);
    
    expect(_call(K.func2,[]),isFalse);
    expect(_call(K.func2,["@sylvinus"]),isTrue);
    
    
  });
  
  test("opt arg bug - fails",() {
    
    var K = new MyClass();
    expect(K.func1(),isFalse);
    expect(K.func1("@sylvinus"),isTrue);
    
    expect(_call(K.func1,[]),isFalse);
    expect(_call(K.func1,["@sylvinus"]),isTrue);
    
    
  });
  
  
}
