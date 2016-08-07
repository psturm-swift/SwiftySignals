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

public protocol InvocationContext {
    func invoke(function: Void->Void)
}

public struct DefaultInvocationContext: InvocationContext {
    public func invoke(function: Void -> Void) {
        if NSThread.isMainThread() {
            function()
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                function()
            }
        }
    }
}

public struct ImmediateInvocationContext: InvocationContext {
    public func invoke(function: Void -> Void) {
        function()
    }
}

public struct DispatchQueueInvocationContext: InvocationContext {
    let dispatchQueue: dispatch_queue_t
    
    public init(dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
    }
    
    public func invoke(function: Void -> Void) {
        dispatch_async(dispatchQueue) {
            function()
        }
    }
}

public final class InternalSlot<Message> {
    private let function: Message->Void
    private let context: InvocationContext
    private weak var receiver: AnyObject?
    
    init(context: InvocationContext, receiver: AnyObject, function: Message->Void) {
        self.function = function
        self.context = context
        self.receiver = receiver
    }
    
    public func invoke(with argument: Message) {
        if isValid {
            context.invoke {
                self.function(argument)
            }
        }
    }
    
    var isValid: Bool {
        return receiver != nil
    }
}