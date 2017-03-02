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

Connecting modifiers to signals is quite easy. Let´s say, we want to print the message when  it is fired. For that purpose we could use the modifier `then` to connect to the signal’s endpoint `fired`:

	let signal = Signal<Int>(value: 15)
	let observables = ObservableCollection()
	signal
	    .fired
	    .then { print($0) }
	    .append(to: observables)
	signal.fire(with: 20)

Important to note is, that modifier chain needs to be stored somewhere. If this is not done, then the modifier chain is deleted immediately due to automatic reference counting. However, modifiers can be appended to an observable collection to keep them alive. In this case the modifier chain is destroyed along with the observable collection.

** to be continued **

[1]:	https://travis-ci.org/psturm-swift/SwiftySignals
[2]:	https://cocoapods.org/pods/SwiftySignals "CocoaPods"
[3]:	https://swift.org "Swift"

[image-1]:	https://travis-ci.org/psturm-swift/SwiftySignals.svg?branch=fb_rework_api
[image-2]:	https://img.shields.io/cocoapods/v/SwiftySignals.svg "Version CocoaPods"
[image-3]:	https://img.shields.io/badge/swift-version%203-blue.svg