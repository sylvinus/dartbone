
import 'package:unittest/unittest.dart';
import "../dartbone.dart";


class ObjCounter extends BackboneEvents {
  int counter=0;
}

void equal(arg1,arg2,[msg]) {
  if (?msg) {
    expect(arg1,equals(arg2), reason:msg);
  } else {
    expect(arg1,equals(arg2));
  }
}

void ok(arg1) {
  expect(arg1,isTrue);
}

main() {
  
  test("on and trigger", () {
    
    var obj = new ObjCounter();

    obj.on('event', () { obj.counter += 1; });
    obj.trigger('event');
    equal(obj.counter,1,'counter should be incremented.');
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counter, 5, 'counter should be incremented five times.');
  });

  test("binding and triggering multiple events", () {

    var obj = new ObjCounter();
    
    obj.on('a b c', () { obj.counter += 1; });

    obj.trigger('a');
    equal(obj.counter, 1);
  
    print("GRIG");
    obj.trigger('a b');
    equal(obj.counter, 3);

    obj.trigger('c');
    equal(obj.counter, 4);

    obj.off('a c');
    obj.trigger('a b c');
    equal(obj.counter, 5);
  });

  test("binding and triggering with event maps", () {

    var obj = new ObjCounter();
    
    
    var increment = () {
      //Dart: can't do this?
      //this.counter += 1;
      obj.counter += 1;
    };

    obj.on({
      "a": increment,
      "b": increment,
      "c": increment
    }, obj);

    obj.trigger('a');
    equal(obj.counter, 1);

    obj.trigger('a b');
    equal(obj.counter, 3);

    obj.trigger('c');
    equal(obj.counter, 4);

    obj.off({
      "a": increment,
      "c": increment
    }, obj);
    obj.trigger('a b c');
    equal(obj.counter, 5);
  });

  test("listenTo and stopListening", () {
    var a = new ObjCounter();
    var b = new ObjCounter();
    a.listenTo(b, 'all', expectAsync0((){ ok(true); }));
    b.trigger('anything');
    a.listenTo(b, 'all', expectAsync0((){ ok(false); },0));
    a.stopListening();
    b.trigger('anything');
  });
/*
  test("listenTo and stopListening with event maps", 1, () {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    a.listenTo(b, {change: (){ ok(true); }});
    b.trigger('change');
    a.listenTo(b, {change: (){ ok(false); }});
    a.stopListening();
    b.trigger('change');
  });

  test("trigger all for each event", 3, () {
    var a, b, obj = { counter: 0 };
    _.extend(obj, Backbone.Events);
    obj.on('all', function(event) {
      obj.counter++;
      if (event == 'a') a = true;
      if (event == 'b') b = true;
    })
    .trigger('a b');
    ok(a);
    ok(b);
    equal(obj.counter, 2);
  });

  test("on, then unbind all functions", 1, () {
    var obj = { counter: 0 };
    _.extend(obj,Backbone.Events);
    var callback = () { obj.counter += 1; };
    obj.on('event', callback);
    obj.trigger('event');
    obj.off('event');
    obj.trigger('event');
    equal(obj.counter, 1, 'counter should have only been incremented once.');
  });

  test("bind two callbacks, unbind only one", 2, () {
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj,Backbone.Events);
    var callback = () { obj.counterA += 1; };
    obj.on('event', callback);
    obj.on('event', () { obj.counterB += 1; });
    obj.trigger('event');
    obj.off('event', callback);
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 2, 'counterB should have been incremented twice.');
  });

  test("unbind a callback in the midst of it firing", 1, () {
    var obj = {counter: 0};
    _.extend(obj, Backbone.Events);
    var callback = () {
      obj.counter += 1;
      obj.off('event', callback);
    };
    obj.on('event', callback);
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counter, 1, 'the callback should have been unbound.');
  });

  test("two binds that unbind themeselves", 2, () {
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj,Backbone.Events);
    var incrA = (){ obj.counterA += 1; obj.off('event', incrA); };
    var incrB = (){ obj.counterB += 1; obj.off('event', incrB); };
    obj.on('event', incrA);
    obj.on('event', incrB);
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 1, 'counterB should have only been incremented once.');
  });

  test("bind a callback with a supplied context", 1, function () {
    var TestClass = function () {
      return this;
    };
    TestClass.prototype.assertTrue = function () {
      ok(true, '`this` was bound to the callback');
    };

    var obj = _.extend({},Backbone.Events);
    obj.on('event', function () { this.assertTrue(); }, (new TestClass));
    obj.trigger('event');
  });

  test("nested trigger with unbind", 1, function () {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);
    var incr1 = (){ obj.counter += 1; obj.off('event', incr1); obj.trigger('event'); };
    var incr2 = (){ obj.counter += 1; };
    obj.on('event', incr1);
    obj.on('event', incr2);
    obj.trigger('event');
    equal(obj.counter, 3, 'counter should have been incremented three times');
  });

  test("callback list is not altered during trigger", 2, function () {
    var counter = 0, obj = _.extend({}, Backbone.Events);
    var incr = (){ counter++; };
    obj.on('event', (){ obj.on('event', incr).on('all', incr); })
    .trigger('event');
    equal(counter, 0, 'bind does not alter callback list');
    obj.off()
    .on('event', (){ obj.off('event', incr).off('all', incr); })
    .on('event', incr)
    .on('all', incr)
    .trigger('event');
    equal(counter, 2, 'unbind does not alter callback list');
  });

  test("#1282 - 'all' callback list is retrieved after each event.", 1, () {
    var counter = 0;
    var obj = _.extend({}, Backbone.Events);
    var incr = (){ counter++; };
    obj.on('x', () {
      obj.on('y', incr).on('all', incr);
    })
    .trigger('x y');
    strictEqual(counter, 2);
  });

  test("if no callback is provided, `on` is a noop", 0, () {
    _.extend({}, Backbone.Events).on('test').trigger('test');
  });

  test("remove all events for a specific context", 4, () {
    var obj = _.extend({}, Backbone.Events);
    obj.on('x y all', () { ok(true); });
    obj.on('x y all', () { ok(false); }, obj);
    obj.off(null, null, obj);
    obj.trigger('x y');
  });

  test("remove all events for a specific callback", 4, () {
    var obj = _.extend({}, Backbone.Events);
    var success = () { ok(true); };
    var fail = () { ok(false); };
    obj.on('x y all', success);
    obj.on('x y all', fail);
    obj.off(null, fail);
    obj.trigger('x y');
  });

  test("off is chainable", 3, () {
    var obj = _.extend({}, Backbone.Events);
    // With no events
    ok(obj.off() === obj);
    // When removing all events
    obj.on('event', (){}, obj);
    ok(obj.off() === obj);
    // When removing some events
    obj.on('event', (){}, obj);
    ok(obj.off('event') === obj);
  });

  test("#1310 - off does not skip consecutive events", 0, () {
    var obj = _.extend({}, Backbone.Events);
    obj.on('event', () { ok(false); }, obj);
    obj.on('event', () { ok(false); }, obj);
    obj.off(null, null, obj);
    obj.trigger('event');
  });

  test("once", 2, () {
    // Same as the previous test, but we use once rather than having to explicitly unbind
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj, Backbone.Events);
    var incrA = (){ obj.counterA += 1; obj.trigger('event'); };
    var incrB = (){ obj.counterB += 1; };
    obj.once('event', incrA);
    obj.once('event', incrB);
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 1, 'counterB should have only been incremented once.');
  });

  test("once variant one", 3, () {
    var f = (){ ok(true); };

    var a = _.extend({}, Backbone.Events).once('event', f);
    var b = _.extend({}, Backbone.Events).on('event', f);

    a.trigger('event');

    b.trigger('event');
    b.trigger('event');
  });

  test("once variant two", 3, () {
    var f = (){ ok(true); };
    var obj = _.extend({}, Backbone.Events);

    obj
      .once('event', f)
      .on('event', f)
      .trigger('event')
      .trigger('event');
  });

  test("once with off", 0, () {
    var f = (){ ok(true); };
    var obj = _.extend({}, Backbone.Events);

    obj.once('event', f);
    obj.off('event', f);
    obj.trigger('event');
  });

  test("once with event maps", () {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);

    var increment = () {
      this.counter += 1;
    };

    obj.once({
      a: increment,
      b: increment,
      c: increment
    }, obj);

    obj.trigger('a');
    equal(obj.counter, 1);

    obj.trigger('a b');
    equal(obj.counter, 2);

    obj.trigger('c');
    equal(obj.counter, 3);

    obj.trigger('a b c');
    equal(obj.counter, 3);
  });

  test("once with off only by context", 0, () {
    var context = {};
    var obj = _.extend({}, Backbone.Events);
    obj.once('event', (){ ok(false); }, context);
    obj.off(null, null, context);
    obj.trigger('event');
  });

  test("Backbone object inherits Events", () {
    ok(Backbone.on === Backbone.Events.on);
  });

  asyncTest("once with asynchronous events", 1, () {
    var func = _.debounce(() { ok(true); start(); }, 50);
    var obj = _.extend({}, Backbone.Events).once('async', func);

    obj.trigger('async');
    obj.trigger('async');
  });

  test("once with multiple events.", 2, () {
    var obj = _.extend({}, Backbone.Events);
    obj.once('x y', () { ok(true); });
    obj.trigger('x y');
  });

  test("Off during iteration with once.", 2, () {
    var obj = _.extend({}, Backbone.Events);
    var f = (){ this.off('event', f); };
    obj.on('event', f);
    obj.once('event', (){});
    obj.on('event', (){ ok(true); });

    obj.trigger('event');
    obj.trigger('event');
  });

  test("`once` on `all` should work as expected", 1, () {
    Backbone.once('all', () {
      ok(true);
      Backbone.trigger('all');
    });
    Backbone.trigger('all');
  });
*/
}
