# Mocha
### Objective-C / JavaScript Bridge and Scripting Environment


Mocha is a runtime that bridges JavaScript to Objective-C. It is built on top of JavaScriptCore, the component of WebKit responsible for parsing and evaluating JavaScript code, and BridgeSupport, which enables libraries to expose the definition of their C structures and functions for use at run-time (as opposed to compile-time).


## Usage

Instances of the `Mocha` class are representations of a runtime. A runtime can be used either through shared instance (returned from `+sharedRuntime`) or by creating an instance by calling `-init`.


## Values and Boxed Objects

When arguments are passed between the Objective-C and JavaScript sides of the bridge they may be implicitly converted to an appropriate type counterpart or boxed within an opaque proxy object. The following type conventions are in effect when moving between each side of the bridge:

### Objective-C to JavaScript
- `nil` is converted to `null`
- `MOUndefined` is converted to `undefined`
- `char*` is converted to `String`
- **Objective-C methods** are converted to `MOMethod`, and are callable
- **Blocks** are boxed within an opaque `Object` type, and are callable
- **C functions** are boxed within an opaque `Object` type, and are callable
- **C structs** are boxed within an opaque `Object` type, allowing direct access to members in a dictionary-like manner.
- **C numeric primitives** (`int`, `long`, `short`, `char`, `float`, `double`, etc.) are converted to `Number`
- `bool` and `_Bool` are converted to `Boolean`
- **Pointers** are boxed within an opaque `Object` type
- **All other Objective-C objects** are boxed within an opaque `Object` type. This type can be converted to `String` or `Number` from within JavaScript. `NSString` instances will convert to `String` appropriately. `NSNumber` instances will convert to `Number` appropriately. All other conversions will use the `-description` method of the `NSObject` subclass.

Note: `BOOL`, unlike `bool`, is converted to `Number`, as `BOOL` is typedef'd as an `unsigned char` in Objective-C.

### JavaScript to Objective-C
- `null` is converted to `nil` (when bare) or `NSNull` (when placed in a container)
- `undefined` is converted to `MOUndefined`
- `String` is converted to `NSString` or `char*`, depending on context
- `Number` is converted to `NSNumber` or a **C numeric primitive**, depending on context
- `Boolean` is converted to `NSNumber`, `bool`, or `_Bool`, depending on context
- `Array` is converted to `NSArray`
- **JavaScript functions** are boxed within an opaque class
- **All boxed types** are unboxed
- All other pure `Object` types are converted to `NSDictionary`


## Callables

### Functions, Methods, and Blocks… Oh My!

All three of these constructs are automatically converted across the bridge. The specifics of how each of them are boxed is different, but the end result is the same: All three are available to be called from within the runtime as if they were a normal JavaScript function.


#### Example:
<pre>
// ObjC
typedef NSString * (^UppercaseBlock)(NSString *);
UppercaseBlock toUppercaseBlock = [myObject toUppercaseBlock];
toUppercaseBlock(@"Hello, World!");
>>> "HELLO, WORLD!"

// JavaScript
var toUppercaseBlock = myObject.toUppercaseBlock();
toUppercaseBlock("Hello, World!");
>>> "HELLO, WORLD!"
</pre>


### Arguments

Arguments to boxed callables are automatically converted when crossing the bridge. Care is taken to automatically allocate storage space for return values and maintain type consistency between the C, Objective-C, and JavaScript layers.

Callables that return other callables (e.g. a block that returns another block) or take callables as arguments also work as expected.

Variable-argument functions work as expected. Objective-C methods that require a terminating sentinel (through the `NS_REQUIRES_NIL_TERMINATION` compiler attribute) **do not** require a trailing `null`.

#### Example:
<pre>
// ObjC
NSArray *array = [NSArray arrayWithObjects:first, second, third, nil];

// JavaScript
var array = NSArray.arrayWithObjects_(first, second, third);
</pre>

Since JavaScript is a dynamic, weak, duck typed language, type safety is key. Mocha will throw an exception if a callable receives more or fewer arguments than is expected, but the actual type of those arguments is mostly left up to the user. The runtime will attempt to convert the JavaScript arguments to the appropriate type as best it can.

**This is an important note:** While normal JavaScript functions can have optional arguments, callables provided from the bridge must receive the exact number of arguments that are expected. (Except in the case of variadic functions, in which case the *minimum* number of arguments needed for calling are required.)


### Objective-C Selectors

Objective-C methods are exposed as properties of the object's opaque JavaScript proxy. When a method is invoked, it is automatically converted to the appropriate selector on the Objective-C side of the bridge, and all arguments are converted to the appropriate types.

Method name conversion follow a similar pattern to PyObjC. The following steps are taken when converting a selector name to the JavaScript property name:
- All colons are converted to underscores.
- Each component of the selector is concatenated into a single string with no separation.

As such, a selector such as `executeOperation:withObject:error:` is converted to the function name `executeOperation_withObject_error_()`. The reverse is done to convert the property name back into an Objective-C selector.

If you wish to change this behavior (for example, to shorten an Objective-C method name for ease of use), you can. Use the `+selectorForMochaPropertyName:` method, defined within a category on NSObject. Objects implementing this method can return the selector for a give JavaScript property name, which will cause the runtime to forward invocations of that property to the appropriate method selector.

#### Example:
<pre>
// ObjC
@implementation MyClass
…

+ (SEL)selectorForMochaPropertyName:(NSString *)propertyName; {
    if ([propertyName isEqualToString:@"someMethod") {
        return @selector(someMethodTakingArgument:otherArgument:)
    }
    return [super selectorForMochaPropertyName:propertyName];
}

@end

// JavaScript
myObject.someMethod(argument, otherArgument);
</pre>


### Objective-C Properties

Objective-C properties behave as they should on the JavaScript side of the bridge. Invoking a property will immediately return its value (as opposed to methods, which return a callable object). A property can also be set using the normal setter syntax. For this to work, the property must be declared using the Objective-C @property syntax.

#### Example:
<pre>
// JavaScript
myObject.name;
>>> "Foobar"

myObject.name = "Baz";

myObject.name;
>>> "Baz";
</pre>


### Exposing Objective-C methods

By default, all methods and properties of an Objective-C object crossing the bridge are available to be invoked. If you wish to specifically exclude methods from invocation on the JavaScript side of the bridge, use the `+isSelectorExcludedFromMochaScript:` method. Objects implementing this method can return `YES` for any selector that should not be invoked from the bridge.

#### Example:
<pre>
// ObjC
@implementation MyClass
…

+ (BOOL)isSelectorExcludedFromMochaScript:(SEL)selector {
    if (selector == @selector(someMethod)) {
        return YES;
    }
    return [super isSelectorExcludedFromMochaScript:selector];
}

@end

// JavaScript
var result = myObject.someMethod();
>>> "MOJavaScriptException: ReferenceError: Can't find variable: someMethod"
</pre>


## Frameworks

Frameworks that expose BridgeSupport information (as all public OS X frameworks do) can be imported through the use of the `framework` built-in function.

#### Example:
<pre>
AVAsset.assetWithURL_(url);
>>> "MOJavaScriptException: ReferenceError: Can't find variable: AVAsset"

framework('AVFoundation');

AVAsset.assetWithURL_(url);
>>> "&lt;AVURLAsset: 0x7fe803ce8340&gt;"
</pre>

On OS X, the following frameworks are imported automatically: Foundation, CoreGraphics.


## Globals

### Global Objects

Arbitrary Objective-C objects and methods can be exposed as global objects to the runtime without needing to declare BridgeSupport information. The `Mocha` class is a fully Key-Value Coding compliant container for just this purpose. Calling `-valueForKey:` and `-setValue:forKey:` exposes an object to the runtime, assuming it can be boxed as an appropriate JavaScript type (see above).

#### Example:
<pre>
// ObjC
Mocha *runtime = [Mocha sharedRuntime];
MyClass *object = [[[MyClass alloc] init];
[runtime setValue:object forKey:@"MyObject"];

// JavaScript
var result = MyObject.someMethod();
</pre>

### Global Functions

To expose arbitrary global functions to the runtime, use the `MOMethod` class. Instances of the class keep reference to a target object and Objective-C selector, which can be invoked dynamically by the runtime whenever the method is called on the JavaScript side of the bridge. Like all other objects, methods can be exposed using the `-valueForKey:` and `-setValue:forKey:` methods of the `Mocha` class.

#### Example:
<pre>
// ObjC
Mocha *runtime = [Mocha sharedRuntime];
MOMethod *method = [MOMethod methodWithTarget:myObject selector:@selector(someMethod)];
[runtime setValue:method forKey:@"someMethod"];

// JavaScript
var result = someMethod();
</pre>


## Pointers

Some C functions and Cocoa methods expect pointers to types. This introduces an issue to bridged languages that do not have the concept of pointers, like JavaScript. The runtime solves this by exposing a mechanism for creating pointers to values explicitly.

Creating a pointer will wrap a value in an opaque container, which will be passed properly to functions and methods which expect a pointer type.

Pointer arguments typically come in one of three flavors:
- `in`, where the value is simply passed by reference
- `out`, where the function or method may modify the value of the pointer on output
- `inout`, a combination of **in** and **out**

### In Arguments

In arguments are just normal by-reference value arguments. As such, the runtime handles these transparently. If a function or method expects a pointer to an NSRect structure, you can pass it along like so:

#### Example
<pre>
// ObjC
@interface MyClass : NSObject
- (CGFloat)getWidthOfRect:(const NSRect *)rect;
@end

// JavaScript
var rect = NSMakeRect(0.0, 0.0, 100.0, 100.0:
var ptr = MOPointer.alloc().initWithValue_(rect);

myObject.getWidthOfRect_(ptr);
>>> 100.0;
</pre>


### Out Arguments

Out arguments are commonly used to return more than one value from a function or method. Cocoa uses this paradigm often to return error objects in the case where an operation fails.

NSScanner also uses this paradigm for its scanning methods. The -scanFloat: method returns a BOOL indicating whether a value was successfully scanned. The argument passed is a pointer to a value that will be modified on the method's return.

#### Example
<pre>
// JavaScript
var scanner = NSScanner.alloc().initWithString_("3.14159");
var ptr = MOPointer.alloc().init();

scanner.scanFloat_(ptr);

ptr.value();
>>> 3.14159
</pre>


### Inout arguments

Inout argument don't require anything special. They are just a combination of the two previous types of arguments.


## Object Subscripting

Objects that support indexed-access (acting as array-types) or keyed-access (acting as dictionary-types) can support the JavaScript subscripting syntax for accessing values.

### Indexed Subscripting

Implementing `-objectForIndexedSubscript:` allows an object to use the `object[idx]` syntax for read-only access to values. For read-write access, you should also implement the `-setObject:forIndexedSubscript:` method. Both of these methods are declared within an informal protocol defined in MochaRuntime.h.

`NSArray` and `NSMutableArray`, and `NSOrderedSet` and `NSMutableOrderedSet` automatically adopt this syntax (through a swizzled category on 10.7 and before, or through automatically supporting the Objective-C indexed subscripting syntax on 10.8+).

### Keyed Subscripting

Implementing `-objectForKeyedSubscript:` allows an object to use the `object['key']` syntax for read-only access to values. For read-write access, you should also implement the `-setObject:forKeyedSubscript:` method. Both of these methods are declared within an informal protocol defined in MochaRuntime.h.

`NSDictionary` and `NSMutableDictionary` automatically adopt this syntax (through a swizzled category on 10.7 and before, or through automatically supporting the Objective-C keyed subscripting syntax on 10.8+).


## Introspecting the Objective-C Runtime

Mocha adds several facilities for introspecting the Objective-C runtime. The built-in object `objc` can be used to query various attributes about the Objective-C runtime. Use the `-classes` method to get a list of classes registered with the runtime, or `-protocols` method to get a list of protocols registered with the runtime.

An NSObject category is also added by the Mocha runtime to add additional introspection abilities to class objects. Use the `+mocha` method on any class object to get an MOClassDescription object, which is used in describing the class's abilities and layout.

MOClassDescription gives access to a class's instance variables, class and instance methods, properties and conformed protocols. Use the `+ancestors` method to get a list of a class's superclass chain. Use the `+classMethods`, `+instanceMethods`, `+properties`, and `+protocols` methods to query information about a class's class methods, instance methods, properties, and protocols, respectively. Note that these methods only return methods, properties and protocols defined by the class itself. As a convenience, Mocha also provides the following methods to query for the entire superclass chain: `+classMethodsWithAncestors`, `+instanceMethodsWithAncestors`, `+propertiesWithAncestors`, and `+protocolsWithAncestors`.

In addition, MOClassDescription has the ability to add methods to existing classes, or even to define and register completly new classes from within the Mocha runtime.

Facilities are also provided for introspecting Objective-C protocols through the MOProtocolDescription class in a similar way to class introspection. Similarly, new protocols can be defined and existing protocols can be amended.


## Exceptions

Exceptions in Objective-C code can be automatically caught by JavaScript exception handlers. The value of the `err` argument within the `try {} catch (err) {}` block will be a boxed `NSException` instance.

JavaScript exceptions that are uncaught will be converted to `NSException` objects with a name of `MOJavaScriptException`. They can be caught in an Objective-C `@try {} @catch (NSException *e) {}` block just like any other exception.

Mocha exceptions that do not originate from within the JavaScript environment carry the name `MORuntimeException`, and generally indicate a more serious failure caused by an issue within the runtime.


## mocha: The Mocha Interpreter

`mocha` is the command-line interpreter for Mocha. It has two modes: script and interactive. Its scripting mode is similar to `python` and `ruby`. Its interactive mode is similar to `python`, `irb`, and `jsc`.

### Interactive

Interactive mode adds the following set of built-in functions:
- `exit()` – Exits the interpreter
- `gc()` – Instructs the JavaScript garbage collector to perform a collection
- `checkSyntax(string)` – Validates the syntax of `string`, returning a `Boolean`

### Scripting

You can use `mocha` the same way you use other scripting envorinments. Add a shebang declaration to the top of a script to enable its use on the command line, like so:

### Example
<pre>
#!/usr/local/bin/mocha

var d = {};
d['foo'] = 'bar';
d['baz'] = 1.0;
d['bin'] = ['foo', 'bar', 'baz'];

print(d);
</pre>


## Using Mocha with OS X

To use Mocha in your OS X project, follow these steps:

1. Add the **Mocha project** to your project (by dragging the *.xcodeproj file to your Frameworks group in Xcode).
2. Open your target's **Build Phases**, and under the **Link Binary With Libraries** build phase, click Add and choose **Mocha.framework** from the workspace.
3. Build!


## Using Mocha with iOS

Mocha works with iOS, too! libMocha is a static library built for iOS targets. To use libMocha in your project, follow these steps:

1. Add the **Mocha project** to your project (by dragging the *.xcodeproj file to your Frameworks group in Xcode).
2. Open your target's **Build Phases**, and under the **Link Binary With Libraries** build phase, click Add and choose **libMocha** from the workspace.
3. Next, add the following system libraries the same way: **libstdc++.dylib**, **libicucore.dylib**.
4. Open your target's **Build Settings** and add **-ObjC** to your **Other Linker Flags**.
5. Under your **Header Search Paths** add **${BUILT_PRODUCTS_DIR}/usr/local/include** and **"${SRCROOT}/(path to Mocha's source folder)/libMocha (iOS)/JavaScriptCore"**
6. Build!


## To Do's

The following items are currently on the docket for future development:

- ~~iOS Support~~ (Added 5/20/12)
- ~~Runtime support for creating and modifying Objective-C classes~~ (Added 6/13/12)
- Objective-J/JSTalk-style syntax for defining Objective-C classes and categories


## Code Usage

Mocha utilizes code and ideas from the following projects:

- PyObjC (http://pyobjc.sourceforge.net/, MIT license)
- JSCocoa (http://inexdo.com/JSCocoa, MIT license)
- JavaScriptCore (http://www.webkit.org/projects/javascript/index.html, WebKit license).
- libffi-iphone (https://github.com/parmanoir/libffi-iphone, MIT license)
- JavaScriptCore-iOS (http://www.phoboslab.org/log/2011/06/javascriptcore-project-files-for-ios, WebKit license).

Files are marked appropriately when code it utilized in complete or near-complete duplicate from these awesome projects.


## License

Copyright 2012 Logan Collins

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.