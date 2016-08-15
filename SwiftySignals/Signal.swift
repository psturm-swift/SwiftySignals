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

public final class Signal<Message>: IsMessageSource {
    public typealias MessageType = Message
    public typealias SlotType = Slot<Message>
    
    private var connectedSlots = [Slot<Message>]()
    private(set) public var lastMessage: Message? = nil
    
    public init() {
    }

    public func trigger(with message: Message) {
        lastMessage = message
        removeInvalidSlots()
        
        let connectedSlots = self.connectedSlots
        for slot in connectedSlots {
            slot.invoke(with: message)
        }
    }
    
    public func trigger(message: Message) {
        trigger(with: message)
    }
    
    public func filter(predicate: Message->Bool) -> MessagePublisherFilter<Message> {
        return MessagePublisherFilter(signal: self, predicate: predicate)
    }
    
    public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        let slot = Slot<Message>(context: context, receiver: receiver, signal: self, function: { [weak receiver] message in
            if let receiver = receiver {
                function(receiver, message)
            }
        })
        connectedSlots.append(slot)
        if let lastMessage = self.lastMessage {
            slot.invoke(with: lastMessage)
        }
        
        return slot
    }
    
    public var subscriberCount: Int {
        return connectedSlots.count
    }

    func remove(slot slot: Slot<Message>) {
        connectedSlots = connectedSlots.filter { $0 !== slot }
    }
    
    func removeInvalidSlots() {
        connectedSlots = connectedSlots.filter { slot in slot.isValid }
    }
}

public final class MessagePublisher<Message>: IsMessageSource {
    public typealias MessageType = Message
    public typealias SlotType = Slot<Message>
    
    let signal: Signal<Message>
    
    init(signal: Signal<Message>) {
        self.signal = signal
    }
    
    public func filter(predicate: Message->Bool) -> MessagePublisherFilter<Message> {
        return signal.filter(predicate)
    }
    
    public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        return signal.then(with: context, and: receiver, call: function)
    }
    
    public var subscriberCount: Int {
        return signal.subscriberCount
    }
}

public final class MessagePublisherFilter<Message>: IsMessageSource {
    public typealias MessageType = Message
    public typealias SlotType = Slot<Message>

    let predicate: Message->Bool
    let signal: Signal<Message>
    
    init(signal: Signal<Message>, predicate: Message->Bool) {
        self.signal = signal
        self.predicate = predicate
    }
    
    public func filter(predicate: Message->Bool) -> MessagePublisherFilter<Message> {
        let currentPredictate = self.predicate
        return MessagePublisherFilter(signal: self.signal, predicate: {
            message in
            return currentPredictate(message) && predicate(message)
        })
    }
    
    public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        return signal.then(with: context, and: receiver) { [predicate] (receiver, message) in
            if (predicate(message)) {
                function(receiver, message)
            }
        }
    }
    
    public var subscriberCount: Int {
        return signal.subscriberCount
    }
}
