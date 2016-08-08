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

public enum InvocationPolicy {
    case Immediately
    case OnMainThreadASAP
    case OnMainQueue
    case WithLowPriority
    case WithNormalPriority
    case WithHighPriority
    case OnQueue(dispatch_queue_t)
    
    var context: InvocationContext {
        switch self {
        case .Immediately:
            return ImmediateInvocationContext()
        case .OnMainThreadASAP:
            return DefaultInvocationContext()
        case .OnMainQueue:
            return DispatchQueueInvocationContext(dispatchQueue: dispatch_get_main_queue())
        case .WithLowPriority:
            return DispatchQueueInvocationContext(dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
        case .WithNormalPriority:
            return DispatchQueueInvocationContext(dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        case .WithHighPriority:
            return DispatchQueueInvocationContext(dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
        case .OnQueue(let customQueue):
            return DispatchQueueInvocationContext(dispatchQueue: customQueue)
        }
    }
}

public final class Signal<Message> {
    private var connectedSlots = [InternalSlot<Message>]()
    
    public init() {
    }
    
    public func trigger(with argument: Message) {
        trigger(argument)
    }

    public func trigger(argument: Message) {
        removeInvalidSlots()

        let connectedSlots = self.connectedSlots
        for slot in connectedSlots {
            slot.invoke(with: argument)
        }
    }

    public func then<Receiver:AnyObject>(with context: InvocationContext,
                     and receiver: Receiver,
                         call function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        return appendNewSlot(withContext: context, withReceiver: receiver, withFunction: function)
    }

    public func then<Receiver:AnyObject>(with context: InvocationContext,
                     on receiver: Receiver,
                        call function: Receiver->(Message->Void)) -> Slot<Message>
    {
        return appendNewSlot(withContext: context, withReceiver: receiver, withFunction: { (_receiver, _value) in
            function(_receiver)(_value)
        })
    }
    
    public func then<Receiver:AnyObject>(invoke policy: InvocationPolicy = .OnMainThreadASAP,
                     with receiver: Receiver,
                          call function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        return appendNewSlot(withContext: policy.context, withReceiver: receiver, withFunction: function)
    }
    
    public func then<Receiver:AnyObject>(invoke policy: InvocationPolicy = .OnMainThreadASAP,
                     on receiver: Receiver,
                          call function: Receiver->(Message->Void)) -> Slot<Message>
    {
        return appendNewSlot(withContext: policy.context, withReceiver: receiver, withFunction: { (_owner, _value) in
            function(_owner)(_value)
        })
    }
    
    func remove(slot slot: InternalSlot<Message>) {
        connectedSlots = connectedSlots.filter { $0 !== slot }
    }
    
    public func removeAllListeners() {
        connectedSlots = []
    }
    
    public var listenerCount: Int {
        return connectedSlots.count
    }
    
    private func appendNewSlot<Receiver:AnyObject>(withContext context: InvocationContext,
                       withReceiver receiver: Receiver,
                                 withFunction function: (Receiver, Message) -> Void) -> Slot<Message>
    {
        let internalSlot = InternalSlot<Message>(context: context, receiver: receiver, function: { [weak receiver] value in
            if let receiver = receiver {
                function(receiver, value)
            }
        })
        
        connectedSlots.append(internalSlot)
        
        return Slot(internalSlot: internalSlot, signal: self)
    }
    
    private func removeInvalidSlots() {
        connectedSlots = connectedSlots.filter { slot in slot.isValid }
    }
}
