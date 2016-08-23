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

public protocol EventType {
    associatedtype MessageType
    associatedtype SlotType: AnyObject
    
    @warn_unused_result func then(
        with context: InvocationContext,
        call function: MessageType->Void) -> SlotType

    func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: (Receiver, MessageType) -> Void) -> SlotType
    
    // Begin: Functions with default implementation
    func then<Receiver:AnyObject>(
        with context: InvocationContext,
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType
    
    func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    
    func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        with receiver: Receiver,
        call function: (Receiver, MessageType) -> Void) -> SlotType
    
    func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        with receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    
    func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType
    
    func then<Receiver:AnyObject>(
        with receiver: Receiver,
        call function: (Receiver, MessageType) -> Void) -> SlotType
    
    func then<Receiver:AnyObject>(
        with receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    
    func then<Receiver:AnyObject>(
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType

    @warn_unused_result func then(
        invoke policy: InvocationPolicy,
        call function: MessageType->Void) -> SlotType

    @warn_unused_result func then(call function: MessageType->Void) -> SlotType
    // End: Functions with default implementation
}

public extension EventType {
    public func then<Receiver:AnyObject>(
        with context: InvocationContext,
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType
    {
        return then(with: context, and: receiver) { (receiver, message) in function(receiver)(message) }
    }
    
    public func then<Receiver:AnyObject>(
        with context: InvocationContext,
        and receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    {
        return then(with: context, and: receiver) { (receiver, _) in function(receiver) }
    }
    
    public func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        with receiver: Receiver,
        call function: (Receiver, MessageType) -> Void) -> SlotType
    {
        return then(with: policy.context, and: receiver, call: function)
    }
    
    public func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        with receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    {
        return then(with: policy.context, and: receiver, call: function)
    }
    
    public func then<Receiver:AnyObject>(
        invoke policy: InvocationPolicy,
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType
    {
        return then(invoke: policy, on: receiver, call: function)
    }
    
    public func then<Receiver:AnyObject>(
        with receiver: Receiver,
        call function: (Receiver, MessageType) -> Void) -> SlotType
    {
        return then(with: InvocationPolicy.OnMainThreadASAP.context, and: receiver, call: function)
    }
    
    public func then<Receiver:AnyObject>(
        with receiver: Receiver,
        call function: Receiver -> Void) -> SlotType
    {
        return then(with: InvocationPolicy.OnMainThreadASAP.context, and: receiver, call: function)
    }
    
    public func then<Receiver:AnyObject>(
        on receiver: Receiver,
        call function: Receiver->(MessageType->Void)) -> SlotType
    {
        return then(with: InvocationPolicy.OnMainThreadASAP.context, on: receiver, call: function)
    }
    
    @warn_unused_result public func then(
        invoke policy: InvocationPolicy,
        call function: MessageType->Void) -> SlotType
    {
        return then(with: policy.context, call: function)
    }
 
    @warn_unused_result public func then(call function: MessageType->Void) -> SlotType {
        return then(with: InvocationPolicy.OnMainThreadASAP.context, call: function)
    }
}

public protocol FilteredEventType {
    associatedtype MessageType
    associatedtype FilterResult: EventType
    
    @warn_unused_result func filter(predicate: MessageType->Bool) -> FilterResult
}
