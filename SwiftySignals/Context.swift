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

