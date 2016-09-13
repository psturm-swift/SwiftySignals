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
    func invoke(_ function: @escaping (Void)->Void)
}

public struct DefaultInvocationContext: InvocationContext {
    public func invoke(_ function: @escaping (Void) -> Void) {
        if Thread.isMainThread {
            function()
        }
        else {
            DispatchQueue.main.async {
                function()
            }
        }
    }
}

public struct ImmediateInvocationContext: InvocationContext {
    public func invoke(_ function: @escaping (Void) -> Void) {
        function()
    }
}

public struct DispatchQueueInvocationContext: InvocationContext {
    let dispatchQueue: DispatchQueue
    
    public init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    public func invoke(_ function: @escaping (Void) -> Void) {
        dispatchQueue.async {
            function()
        }
    }
}

public enum InvocationPolicy {
    case immediately
    case onMainThreadASAP
    case onMainQueue
    case withLowPriority
    case withNormalPriority
    case withHighPriority
    case onQueue(DispatchQueue)
    
    var context: InvocationContext {
        switch self {
        case .immediately:
            return ImmediateInvocationContext()
        case .onMainThreadASAP:
            return DefaultInvocationContext()
        case .onMainQueue:
            return DispatchQueueInvocationContext(dispatchQueue: DispatchQueue.main)
        case .withLowPriority:
            return DispatchQueueInvocationContext(dispatchQueue: DispatchQueue.global(qos: .utility))
        case .withNormalPriority:
            return DispatchQueueInvocationContext(dispatchQueue: DispatchQueue.global(qos: .default))
        case .withHighPriority:
            return DispatchQueueInvocationContext(dispatchQueue: DispatchQueue.global(qos: .userInitiated))
        case .onQueue(let customQueue):
            return DispatchQueueInvocationContext(dispatchQueue: customQueue)
        }
    }
}
