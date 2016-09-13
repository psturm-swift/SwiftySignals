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


public protocol Invalidatable: class {
    func invalidate()
}

public final class InvalidationContainer: Invalidatable {
    private var objects: [Invalidatable] = []
    
    public init() {
    }

    internal func add(object: Invalidatable) {
        objects.append(object)
    }
    
    public func invalidate() {
        for object in objects {
            object.invalidate()
        }
        objects = []
    }
    
    deinit {
        invalidate()
    }
}

final class InternalSlot<Message> {
    private let function: (Message)->Void
    private let context: InvocationContext
    private weak var receiver: AnyObject?
    
    init(context: InvocationContext, receiver: AnyObject, function: @escaping (Message)->Void) {
        self.function = function
        self.context = context
        self.receiver = receiver
    }
    
    func invoke(with argument: Message) {
        if isValid {
            context.invoke {
                self.function(argument)
            }
        }
    }

    var isValid: Bool {
        return receiver != nil
    }

    func invalidate() {
        receiver = nil
    }
}

public final class Slot<Message>: Invalidatable {
    private weak var internalSlot: InternalSlot<Message>? = nil
    
    init(internalSlot: InternalSlot<Message>) {
        self.internalSlot = internalSlot
    }
    
    public var isValid: Bool {
        return internalSlot?.isValid ?? false
    }
    
    public func invalidate() {
        internalSlot?.invalidate()
    }
    
    public func invalidate(with container: InvalidationContainer) {
        container.add(object: self)
    }
}