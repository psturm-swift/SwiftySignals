# SwiftySignals (Draft)

[![Build Status][image-1]][1] [![][image-2]][2] [![Swift Version][image-3]][3]

## Author
Patrick Sturm, psturm.mail@googlemail.com

## License
SwiftySignals is available under the MIT license. See the LICENSE file for more info.

## Introduction
SwiftySignals started as a simple framework with only a few classes. Up to SwiftySignals 2 concurrency was completely ignored and left to the user. With SwiftySignals 3 the API becomes more flexible and thread safe. Concurrency is now supported widely.
SwiftySignals 3 implements now the observer pattern and builds upon Apple’s dispatching framework.

## Basic concept
The basic concept of SwiftySignals are observables and observers. Observables are able to send messages and observers are able to receive and to process messages. In general you never need to define observables or observers by yourself. You only need to deal with helper classes. There are mainly two types of helper classes in SwiftySignals:

1. Message sources
2. Modifiers

Message sources have one or more observables. Modifiers are both - observers and observables. Modifiers can be connected to an observable. They are able to filter, map, discard and generate messages. As modifiers are observables themselves, modifiers can be connected to a modifier chain. A message starts at a message source and is send along the modifier chains.

Class `Signal<T>` is the simplest implementation of a message source. A signal can be used to send a message of type `T`. To do so, the function `Signal<T>.fire(with: T)` can be used. If a message is fired, then it is send to all modifiers connected to `Signal<T>.fired` which is called the end point. 

Connecting modifiers to signals is quite easy. Let´s say, we want to print the message when it is fired. For that purpose we could use the modifier `then` to connect to the signal’s endpoint `fired`:

	let signal = Signal<Int>(value: 15)
	let observables = ObservableCollection()
	signal
	    .fired
	    .then { print($0) }
	    .append(to: observables)
	signal.fire(with: 20)

Important to note is, that modifier chain needs to be stored somewhere. If this is not done, then the modifier chain is deleted immediately due to automatic reference counting. However, modifiers can be appended to an observable collection to keep them alive. In this case the modifier chain is destroyed along with the observable collection.

## Available message sources
In SwiftySignals there a few message sources defined.

### Signals
Signals are of class `Signal<T>`. A signal has a function `fire(with message: T)` that sends a message to all observables which connected to the signal’s endpoint `fired`.

### Properties
Properties are of class `Property<T>`. A property has an attribute `value` of type `T`. Whenever the value is modified, the new value is send to the property’s endpoint `didSet`. Properties are thread safe. That means reading from and writing to the property’s value is allowed from all threads. But be aware the reading is a blocking command, that might cause issues in some situations.

	let property = Property<Int>(value: 0)
	let observables = ObservableCollection()
	
	property
	    .didSet
	    .then { print("Value changed to \($0)") }
	    .append(to: observables)
	
	for i in 0..<10 {
	    property.value += 1
	}

### Once-Only-Timer
Once-Only-Timers are of class `OnceOnlyTimer`. Once-Only-Timers can be seen as time triggered signals with message type `void`. The timer is started by the function `fire(after: Measurement<UnitDuration>)`. If the given time in seconds has expired the Once-Only-Timer sends a message to all observes connected to endpoint `fired`. Each call to `fire(after:)` will invalide the timer first.

	let timer = OnceOnlyTimer()
	let observables = ObservableCollection()
	
	timer
	    .fired
	    .then { print("Waited for 10 seconds.") }
	    .append(to: observables)
	
	timer.fire(after: Measurement(value: 10, unit: TimeDuration.seconds))

### Periodic Timer
Periodic timers are of class `PeriodicTimer`. Periodic timers can be seen as time triggered signals with message type `Void`. The timer  is configured by its `init(interval: TimeInterval)` function and activated by `activate`. The timer is triggering continuously messages with the given time interval.

	let timer = PeriodicTimer(: 10)
	let observables = ObservableCollection()
	timer
	    .fired
	    .then {.print("Timer has been triggered") }
	    .append(to: observables)
	
	timer.activate()

## Available modifiers
Different modifiers can be connected to an endpoint. Modifiers transforms observables into different observables. As modifiers are observables as well it is possible to chain different modifiers together.
If a modifier is connected, it receives automatically the last message that was sent.

### Then modifier
The function `.then` connects a modifier that executes an action when a message of type `T` is sent. There are two possibilities to define such an action:

1. As closure with function `.then(do: (T)->Void)`
2. As instance with: `.then(call: (Object)->((T)->Void)), on: Object)`
After the message is processed by the action, it is send to all observables connected to the modifier.

	class ViewController {
	    private let property = Property<Int>(value: 56)
	    private let obersables = ObservableCollection()
	
	    override func viewDidLoad() {
	        property
	            .didSet
	            .then(call: ViewController.update, on: self)
	        property.value = 67
	    }
	
	    func update(value: Int) {
	        print("Value = \(value)")
	    }
	}

### Filter modifier
The function `.filter(predicate: (T)->Bool)` connects a modifier that checks if the message fulfills a predicate. If the predicate returns `true`, the message is sent to all observables connected to the modifier. If the predicate return `false`instead, the message is discarded.

	let property = Property(value: 45)
	let observables = Observables()
	
	property
	    .didSet
	    .filter { $0 >= 100 }
	    .then { print("Value \($0) is larger or equal than 100") }
	    .append(to: observables)

### Map modifier
The function `.map(transform: (T)->S)` connects a modifier that transforms an incoming message of type `T` to `S`. The transformed message is sent to all observables connected to the modifier.

	let property = Property(value: 100)
	property
	    .didSet
	    .map { 2 * $0 }
	    .then { print($0) }
	    .append(to: observables)

### Throttle modifier
The function `.throttle(pause: Measurement<UnitDuration>)` connects a modifier that discards messages if they are sent to fast. There needs to be a at least a defined pause between two message so that none of them are discarded.

### Discard modifier
The function `.discard(first n: Int)` connects a modifier that discards the first n messages. All other message after that are sent to the connected modifiers.

### Distinct modifier
The function `.distinct()` connects a modifier that discards a message if the previous passed message is equal. This modifiers is only available for comparable message types.

## Concurrency
Each message source and each modifier use its own dispatch queue for synchronization. Closures defined by the user, like closures used in `then`, `filter` and `map` are executed on the main queue by default. However, this behavior can be changed by function `.dispatch` which comes in two flavors:

1. `.dispatch(to queue: DispatchQueue)`
2. `.dispatch(qos: DispatchQoS)` 

The first version delegates all closures to the given. The second version delegates all closures to a global dispatch queue with the given quality of service class.

If the closures should be executed in synchronization queue of the modifier, then you can use function `.noDispatch()`.

	let property = Property(value: 50)
	let observables = Observables()
	
	property
	    .didSet
	    .dispatch(qos: DispatchQoS.userInitiated)
	    .then { print("I am running on a global queue.") }
	    .dispatch(qos: DispatchQoS.main)
	    .then { print("I am running on the main queue.") }
	    .append(to: observables)

[1]:	https://travis-ci.org/psturm-swift/SwiftySignals
[2]:	https://cocoapods.org/pods/SwiftySignals "CocoaPods"
[3]:	https://swift.org "Swift"

[image-1]:	https://travis-ci.org/psturm-swift/SwiftySignals.svg?branch=master
[image-2]:	https://img.shields.io/cocoapods/v/SwiftySignals.svg "Version CocoaPods"
[image-3]:	https://img.shields.io/badge/swift-version%203-blue.svg