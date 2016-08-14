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

public final class Timer {
    private weak var timer: NSTimer? = nil
    private let tolerance: NSTimeInterval
    private let signalFired = Signal<Void>()
    public var fired: MessagePublisher<Void> {
        return MessagePublisher<Void>(signal: signalFired)
    }
    
    public init(tolerance: NSTimeInterval = 0) {
        self.tolerance = tolerance
    }
    
    public func invalidate() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    public func fireAfter(seconds seconds: NSTimeInterval) {
        invalidate()
        let timer = NSTimer(timeInterval: seconds, target: self, selector: #selector(Timer.fireSignal), userInfo: nil, repeats: false)
        timer.tolerance = tolerance
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        self.timer = timer
    }
    
    @objc private func fireSignal() {
        signalFired.trigger()
    }
}

public final class PeriodicTimer {
    private weak var timer: NSTimer? = nil
    private let tolerance: NSTimeInterval
    private let signalFired = Signal<Void>()
    public var fired: MessagePublisher<Void> {
        return MessagePublisher<Void>(signal: signalFired)
    }
    
    public init(tolerance: NSTimeInterval = 0) {
        self.tolerance = tolerance
    }
    
    public var interval: NSTimeInterval = 0.0 {
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
        let timer = NSTimer(timeInterval: interval, target: self, selector: #selector(Timer.fireSignal), userInfo: nil, repeats: true)
        timer.tolerance = tolerance
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        self.timer = timer
    }
    
    @objc private func fireSignal() {
        signalFired.trigger()
    }
}
