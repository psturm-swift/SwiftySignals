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

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public final class OnceOnlyTimer {
    private weak var timer: Timer? = nil
    private let tolerance: TimeInterval
    public let fired = Event<Void>()
    
    public init(tolerance: TimeInterval = 0) {
        self.tolerance = tolerance
    }
    
    public func invalidate() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    public func fireAfter(seconds: TimeInterval) {
        invalidate()
        let timer = Timer(timeInterval: seconds, repeats: false) { _ in self.fired.fire() }
        timer.tolerance = tolerance
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        self.timer = timer
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public final class PeriodicTimer {
    private weak var timer: Foundation.Timer? = nil
    private let tolerance: TimeInterval
    public let fired = Event<Void>()
    
    public init(tolerance: TimeInterval = 0) {
        self.tolerance = tolerance
    }
    
    public var interval: TimeInterval = 0.0 {
        didSet {
            if let _ = timer {
                activate()
            }
        }
    }
    
    public func invalidate() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    public func activate() {
        invalidate()
        let timer = Timer(timeInterval: interval, repeats: true) { _ in self.fired.fire() }
        timer.tolerance = tolerance
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        self.timer = timer
    }
}
