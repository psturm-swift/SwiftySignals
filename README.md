# SwiftySignals

[![Build Status](https://travis-ci.org/psturm-swift/SwiftySignals.svg?branch=master)](https://travis-ci.org/psturm-swift/SwiftySignals)

## Author
Patrick Sturm, psturm.mail@googlemail.com

## License
SwiftySignals is available under the MIT license. See the LICENSE file for more info.

## Introduction
SwiftySignals provides a simple API to send and react to application messages.
There are three concept involved:
- *Signal:* Signals are senders of messages.
- *Message*: Messages are instances of an arbitrary type.
- *Slot:*: Slots receive messages in the first place and hand them over to a connected user defined function.
The concept can be considered as a specific implementation of the observer pattern.

## Tutorial
Let’s image a class representing a temperature sensor. The class has a instance function `updateTemperature()` which reads out the current temperature and sends it via a signal to all its connected receivers. A receivers could be anything like a view controller which displays the temperature in a view or a controller that triggers an alert if the temperature is too low or too high.

The class `TemperatureSensor` could be implemented like this:

	class TemperatureSensor {
	    static shared = TemperatureSensor()
	    let signalTemperature = Signal<Temperature>()
	
	    func updateTemperature() {
	        let currentTemperature = readTemperature()
	        signalTemperature.trigger(with: currentTemperature)
	    }
	}

### Defining a signal
In SwiftySignals a signal is an instance of

	class Signal<Message>

Along with the definition of a signal, you need to define the type of the message the signal will send out. There is no restriction on the message type. Also `Void` is a valid message type.

In our example we define the signal as:

	let signalTemperature = Signal<Temperature>()

The update function will send the current temperature by calling the function `Signal<Message>.trigger(with:)`

	signalTemperature.trigger(with: currentTemperature)

### Connecting a instance function to a signal
To react on a message we need to connect at least one receiver to the signal. In our example we will define a view controller as receiver which will display the current temperature.
The best place to connect the view controller as receiver is `viewDidLoad()`.  Now we need to call `Signal.then(on:call:)`. Parameter `on:` defines the receiver object and `call:` the instance function that should be invoked on the receiver. Such a function needs to have one parameter for the message.

	class TemperatureVC: NSViewController {
	    override func viewDidLoad() {
	        TemperatureSensor.shared
	                .signalTemperature
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

### Manual disconnect the receiver from the signal
The `then(on:call:)` function returns a so called slot. The slot allows you to disconnect the receiver from the signal manually.

	let slot = TemperatureSensor.shared
	                .signalTemperature
	                .then(
	                    on: self, 
	                    call: TemperatureVC.newTemperatureArrived
	                )
	
	slot.unsubscribe() // Disconnect the receiver

### Connecting closures to a signal
Alternatively you could connect a closure instead of an instance method to the signal. However, also in this case you need a receiver object. This receiver object is given along with the message to your closure:

	class TemperatureVC: NSViewController {
	    override func viewDidLoad() {
	        TemperatureSensor.shared
	            .signalTemperature
	            .then(with: self) { (receiver, temperature) in
	                /* receiver === self */
	                receiver.newTemperatureArrived(temperature)
	            }
	    }
	}

*Warning:* You should never use a strong reference to self within these closures to avoid strong-reference-cycles. This is the reason for having the receiver object as first closure argument.

### SwiftySignals and Grand Central Dispatch
If you trigger a signal on the main thread, then the connected function are called immediately by default. If you trigger a signal on another thread than the main thread, then your receiver function will be process on the main dispatch queue.

This behavior can be modified per connection. For this purpose you can call `then` with the additional parameter `invoke` that defines the `InvocationPolicy`.

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
- `Immediately`: The connected function will be executed in the same thread as the signal was triggered.
- `OnMainQueue`: The connected function is delegated to the main queue.
- `OnMainThreadASAP`: If the signal is triggered on the main thread, then the connected function is called immediately. If the signal is triggered on another thread than the main thread, then the connected function is delegated to the main queue.
- `WithLowPriority`: The connected function will be executed on a global concurrent queue with low priority.
- `WithMediumPriority`: The connected function will be executed on a global concurrent queue with medium priority.
- `WithHighPriority`: The connected function will be executed on a global concurrent queue with high priority.
- `OnQueue(dispatch_queue_t)`: The connected function will be executed on the given queue.

### Thread Safety
In the current version instances of `Signal<MessageType>` are not thread-safe. Thus only one thread, preferable the main thread, is allowed to access the signal. This restriction might become obsolete in the future.

### Properties
A property is of type `Property<T>`. It stores a value `Property<T>.value` of type `T` and has an embedded signal. If you set a new value to `Property<T>.value` then the embedded signal is triggered automatically.
You cannot connection your functions directly to the signal. Instead you need to use the `didSet` functions of `Property<T>`. This functions works similar to the `then` functions for signals.

	class Model {
	    static let shared = Model()
	    let temperature = Property<Temperature>(value: 56°C)
	}
	
	class TemperatureVC: NSViewController {
	    var temperatureValue: Temperature? = nil
	
	    override func init() {
	        Model.shared
	            .temperature
	            .didSet(
	                on: self, 
	                call: TemperatureVC.setNewTemperature
	            )
	        setNewTemperature(Model.shared.temperature.value)
	    }
	
	    func setNewTemperature(value: Temperature) {
	        temperatureValue = value
	    }
	}

After we connect the `setNewTemperature` instance function to the property, we call it once with the current value of the property:

	setNewTemperature(Model.shared.temperature.value)

Instead of initializing the local temperature variable manually we could do this alternatively by calling the `invoke` function on the returned slot of `didSet`:

	 Model.shared
		.temperature
		.didSet(
			on: self, 
			call: TemperatureVC.setNewTemperature
		)
		.invoke()

The additional `invoke` command will trigger `setNewTemperature` with the property’s value.
