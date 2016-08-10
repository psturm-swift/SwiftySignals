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

public final class Slot<Message> {
    private let function: Message->Void
    private let context: InvocationContext
    private weak var receiver: AnyObject?
    private weak var signal: Signal<Message>?
    
    init(context: InvocationContext, receiver: AnyObject, signal: Signal<Message>, function: Message->Void) {
        self.function = function
        self.context = context
        self.receiver = receiver
        self.signal = signal
    }
    
    public func invoke(with argument: Message) {
        if isValid {
            context.invoke {
                self.function(argument)
            }
        }
    }

    public func unsubscribe() {
        if let signal = self.signal {
            signal.remove(slot: self)
        }
    }
    
    public var isValid: Bool {
        return receiver != nil
    }
}

public final class RestrictedSlotTrait<T> {
    private let slot: Slot<T>?
    
    private init(slot: Slot<T>) {
        self.slot = slot
    }
    
    public func unsubscribe() {
        slot?.unsubscribe()
    }
}

public protocol IsSlotTraitGenerator {
    associatedtype MessageType
    associatedtype SlotTrait: AnyObject
    
    func slotTrait(for slot: Slot<MessageType>) -> SlotTrait
}

public struct RestrictedSlotTraitGenerator<T>: IsSlotTraitGenerator {
    public typealias MessageType = T
    public typealias SlotTrait = RestrictedSlotTrait<T>
    
    init() {
    }
    
    public func slotTrait(for slot: Slot<T>) -> RestrictedSlotTrait<T> {
        return RestrictedSlotTrait<T>(slot: slot)
    }
}
