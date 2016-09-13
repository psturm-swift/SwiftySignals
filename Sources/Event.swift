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

public final class Event<Message>: EventType, FilteredEventType {
    public typealias FilterResult = FilteredEvent<Message>

    private var connectedSlots = [InternalSlot<Message>]()
    public private(set) var lastMessage: Message? = nil
    
    public init() {
    }
    
    public func filter(_ predicate: @escaping (Message)->Bool) -> FilteredEvent<Message> {
        return FilteredEvent(event: self, predicate: predicate)
    }

    private func add(_ slot: InternalSlot<Message>) {
        connectedSlots.append(slot)
        if let lastMessage = self.lastMessage {
            slot.invoke(with: lastMessage)
        }
    }

    public func then(
        with context: InvocationContext,
        call function: @escaping (Message)->Void) -> Slot<Message>
    {
        let slot = InternalSlot<Message>(context: context, receiver: self, function: function)
        add(slot)
        return Slot(internalSlot: slot)
    }
    
    @discardableResult public func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: @escaping (Receiver, Message) -> Void) -> Slot<Message>
    {
        let slot = InternalSlot<Message>(context: context, receiver: receiver, function: { 
            [weak receiver] message in
            if let receiver = receiver {
                function(receiver, message)
            }
        })
        add(slot)
        return Slot(internalSlot: slot)
    }
    
    public var subscriberCount: Int {
        return connectedSlots.count
    }
    
    internal func fire(with message: Message) {
        let validSlots = self.connectedSlots.filter { slot in slot.isValid }
        lastMessage = message
        for slot in validSlots {
            slot.invoke(with: message)
        }
        self.connectedSlots = validSlots
    }
    
    internal func fire(_ message: Message) {
        fire(with: message)
    }
}

public final class FilteredEvent<Message>: EventType, FilteredEventType {
    internal let predicate: (Message)->Bool
    internal let event: Event<Message>
    
    internal init(event: Event<Message>, predicate: @escaping (Message)->Bool) {
        self.event = event
        self.predicate = predicate
    }
    
    public func filter(_ predicate: @escaping (Message)->Bool) -> FilteredEvent<Message> {
        let currentPredictate = self.predicate
        return FilteredEvent(event: self.event, predicate: {
            message in
            return currentPredictate(message) && predicate(message)
        })
    }
    
    public func then(
        with context: InvocationContext,
        call function: @escaping (Message)->Void) -> Slot<Message>
    {
        return event.then(with: context, call: function)
    }
    
    @discardableResult public func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: @escaping (Receiver, Message) -> Void) -> Slot<Message>
    {
        return event.then(with: context, and: receiver) { [predicate] (receiver, message) in
            if (predicate(message)) {
                function(receiver, message)
            }
        }
    }
}
