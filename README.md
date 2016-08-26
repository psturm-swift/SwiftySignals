# SwiftySignals

[![Build Status][image-1]][1] [![][image-2]][2]

## Author
Patrick Sturm, psturm.mail@googlemail.com

## License
SwiftySignals is available under the MIT license. See the LICENSE file for more info.

## Introduction
SwiftySignals provides a simple API to send and react to application messages.
There are three basic concepts involved:
- *Events:* You can subscribe handler function to an event. The functions will be called if the event is fired. An event can have up to one message argument.
- *Message*: Messages are instances of an arbitrary type.
- *Slot:* Slots receive messages in the first place and hand them over to a connected user defined function. The user defined function can be executed on any dispatch queue.
The concept can be considered as a specific implementation of the observer pattern.
SwiftySignals provides already some classes which make use of event:
- *Signal:* A signal triggers an event and sends out a message.
- *Property:* A property stores a value of arbitrary type and fires an event if the value has been changed.
- *Timer:* A timer can be configured to fire an event after a certain amount of time.
- *PeriodicTimer:* A periodic timer fires an event periodically configured by an interval.

## Tutorial
Let’s consider a class representing a temperature sensor. The class has a instance function `updateTemperature()` which reads out the current temperature and sends its value via a signal to all its connected receivers. A receiver could be anything like a view controller which displays the temperature in a view or a controller that triggers an alert if the temperature is too low or too high.

The class `TemperatureSensor` could be implemented like this:

	class TemperatureSensor {
	    static shared = TemperatureSensor()
	    let signalTemperature = Signal<Temperature>()
	
	    func updateTemperature() {
	        let currentTemperature = readTemperature()
	        signalTemperature.fire(with: currentTemperature)
	    }
	}

### Defining a signal
In SwiftySignals a signal is an instance of

	class Signal<Message>

Along with the definition of a signal, you need to define the type of the message, the signal will send out. There is no restriction on the message type. Also `Void` is a valid message type.

In our example we define the signal as:

	let signalTemperature = Signal<Temperature>()

The update function will send the current temperature by calling the function `Signal<Message>.fire(with:)`

	signalTemperature.fire(with: currentTemperature)

### Connecting a instance function to a signal
To react on a message we need to connect at least one receiver to the signal. In our example we will define a view controller as receiver which will display the current temperature.
The best place to connect the view controller as receiver is its `viewDidLoad()` function.  Now we need to call `Signal.fired.then(on:call:)`. Parameter `on:` defines the receiver object and `call:` the instance function that should be invoked on the receiver. Such a function needs to have one parameter for the message.

	class TemperatureVC: NSViewController {
	    override func viewDidLoad() {
	        TemperatureSensor.shared
	                .signalTemperature
	                .fired
	                .then(
	                    on: self, 
	                    call: TemperatureVC.newTemperatureArrived
	                )
	            }
	
	        private func newTemperatureArrived(value: Temperature) {
	            // Update views here
	        }
	}

The connection between view controller and signal lives until either the signal or the receiver is destroyed.
As soon you connect a function to a signal, your function will get the last fired message, if the signal has been fired previously.

### Manual disconnect the receiver from the signal
The `then(on:call:)` function returns a so called slot. By invaliding the slot, you can unsubscribe from the signal manually.
t
	let slot = TemperatureSensor.shared
	                .signalTemperature
	                .fired
	                .then(
	                    on: self, 
	                    call: TemperatureVC.newTemperatureArrived
	                )
	
	slot.invalidate() // Disconnect the receiver

### Connecting closures to a signal
Alternatively you could connect a closure instead of an instance method to the signal. However, also in this case you need a receiver object to determine the lifetime of the subscription. This receiver object is given along with the message to your closure:

	class TemperatureVC: NSViewController {
	    override func viewDidLoad() {
	        TemperatureSensor.shared
	            .signalTemperature
	            .fired
	            .then(with: self) { (receiver, temperature) in
	                /* receiver === self */
	                receiver.newTemperatureArrived(temperature)
	            }
	    }
	}

*Warning:* You should never use a strong reference to self within these closures to avoid strong-reference-cycles. This is the reason for having the receiver object as first closure argument.

### SwiftySignals and Grand Central Dispatch
If you fire a signal on the main thread, then the connected function are called immediately by default. If you trigger a signal on another thread than the main thread, then your receiver function will be process on the main dispatch queue.

This behavior can be modified per subscription. For this purpose you can call `then` with the additional parameter `invoke` that defines the `InvocationPolicy`.

	enum InvocationPolicy {
	    case Immediately
	    case OnMainThreadASAP /* Default behaviour */
	    case OnMainQueue
	    case WithLowPriority
	    case WithNormalPriority
	    case WithHighPriority
	    case OnQueue(dispatch_queue_t)
	}

With an invocation policy you steer in which context a connected function is called:
- `Immediately`: The connected function will be executed in the same thread as the signal was fired.
- `OnMainQueue`: The connected function is delegated to the main queue.
- `OnMainThreadASAP`: If the signal is fired on the main thread, then the connected function is called immediately. If the signal is fired on another thread than the main thread, then the subscribed function is delegated to the main queue.
- `WithLowPriority`: The subscribed function will be executed on a global concurrent queue with low priority.
- `WithMediumPriority`: The subscribed function will be executed on a global concurrent queue with medium priority.
- `WithHighPriority`: The subscribed function will be executed on a global concurrent queue with high priority.
- `OnQueue(dispatch_queue_t)`: The subscribed function will be executed on the given queue.

### Thread Safety
In the current version instances of `Signal<MessageType>` are not thread-safe. Thus only one thread, preferable the main thread, is allowed to access the signal. This restriction might become obsolete in the future.

### Properties
A property is of type `Property<T>`. It stores a value `Property<T>.value` of type `T` and has an embedded event `Property<T>.didSet`
 
If you set a new value to `Property<T>.value` then the embedded event is fired automatically. You can subscribe your functions directly to the event `didSet`.

	class Model {
	    static let shared = Model()
	    let temperature = Property<Temperature>(value: 56°C)
	}
	
	class TemperatureVC: NSViewController {
	    var temperatureValue: Temperature? = nil
	
	    override func init() {
	        Model.shared
	            .temperature
	            .didSet
	            .then(
	                on: self, 
	                call: TemperatureVC.setNewTemperature
	            )
	    }
	
	    func setNewTemperature(value: Temperature) {
	        temperatureValue = value
	    }
	}

By calling then the function `setNewTemperature` is called by the current value of the property.

### Defining a timer that fires once
A `OnceOnlyTimer` has an embedded event `OnceOnlyTimer.fired` which will fire after a given time. The timer can be started with the function `OnceOnlyTimer.fireAfter(seconds:)`

	class TemperatureSensor {
	    let timer = OnceOnlyTimer()
	
	    override func viewDidLoad() {
	        timer
	            .fired
	            .then(
	                on: self, 
	                call: TemperatureSensor.updateTemperature
	            )
	
	        timer.fireAfter(seconds: 600)
	    }
	}

The timer can be stopped by calling `OnceOnlyTimer.invalidate()`. When the timer has fired it will never fire again unless you call explicitly `OnceOnlyTimer.fireAfter(seconds:)` again.

### Defining a periodic timer
The `PeriodicTimer` is a timer which is called regularly in intervals. 

	class TemperatureSensor {
	    let timer = PeriodicTimer()
	
	    override func viewDidLoad() {
	        timer
	            .fired
	            .then(
	                on: self, 
	                call: TemperatureSensor.updateTemperature
	            )
	
	        timer.interval = 600
	        timer.activate()
	    }
	}

You can change the fire interval by setting `PeriodicTimer.interval` to the interval length in seconds. The timer needs to be started by `PeriodicTimer.activate()`.

### Filter messages
A filter can be added to each subscription. Therefore the event provides the function `filter(predicate:)`

	class TemperatureAlert {
	    override func viewDidLoad() {
	        TemperatureSensor.shared
	            .signalTemperature
	            .fired
	            .filter({ $0 > 30.0 })
	            .then(
	                on: self,
	                call: TemperatureAlert.tooHigh
	            )
	    }
	
	    func tooHigh(temperature: Temperature) {
	        // Show alert
	    }
	}

[1]:	https://travis-ci.org/psturm-swift/SwiftySignals
[2]:	https://cocoapods.org/pods/SwiftySignals "CocoaPods"

[image-1]:	https://travis-ci.org/psturm-swift/SwiftySignals.svg?branch=master
[image-2]:	https://img.shields.io/cocoapods/v/SwiftySignals.svg "Version CocoaPods"