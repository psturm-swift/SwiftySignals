// Copyright (c) 2016 Patrick Sturm <psturm.mail@googlemail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public final class PropertySlot<T> {
    private let slot: Slot<T>?
    private weak var property: Property<T>?
    
    private init(property: Property<T>, slot: Slot<T>) {
        self.property = property
        self.slot = slot
    }

    public func invoke() {
        if let slot = slot, let property = property {
            slot.invoke(with: property.value)
        }
    }
    
    public func unsubscribe() {
        if let slot = self.slot {
            slot.unsubscribe()
        }
    }
}

public class Property<T> {
    private let signalOnValueChange = Signal<T>()

    public var value: T {
        didSet {
            signalOnValueChange.trigger(with: value)
        }
    }
    
    public init(value: T) {
        self.value = value
    }

    public func didSet<Receiver:AnyObject>(invoke policy: InvocationPolicy = .OnMainThreadASAP,
                       with receiver: Receiver,
                            call function: (Receiver, T) -> Void) -> PropertySlot<T>
    {
        return didSet(with: policy.context, and: receiver, call: function)
    }
    
    public func didSet<Receiver:AnyObject>(invoke policy: InvocationPolicy = .OnMainThreadASAP,
                       on receiver: Receiver,
                            call function: Receiver->(T->Void)) -> PropertySlot<T>
    {
        return didSet(with: policy.context, on: receiver, call: function)
    }
    
    public func didSet<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: (Receiver, T) -> Void) -> PropertySlot<T>
    {
        let slot = signalOnValueChange.then(with: context, and: receiver, call: function)
        return PropertySlot<T>(property: self, slot: slot)
    }
    
    public func didSet<Receiver:AnyObject>(with context: InvocationContext,
                     on receiver: Receiver,
                        call function: Receiver->(T->Void)) -> PropertySlot<T>
    {
        let slot = signalOnValueChange.then(with: context, on: receiver, call: function)
        return PropertySlot<T>(property: self, slot: slot)
    }
    
    public func removeAllListeners() {
        signalOnValueChange.removeAllListeners()
    }
    
    public var listenerCount: Int {
        return signalOnValueChange.listenerCount
    }
}
