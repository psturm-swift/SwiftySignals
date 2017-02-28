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
    private let _observable: ObservableSync<Void>
    private let _syncQueue: DispatchQueue
    private weak var _timer: Timer? = nil
    private let _tolerance: TimeInterval

    public var fired: Tail<ObservableSync<Void>> {
        get {
            return Tail<ObservableSync<Void>>(observable: _observable, dispatchQueue: DispatchQueue.main)
        }
    }
    
    public init(tolerance: TimeInterval = 0) {
        let syncQueue = DispatchQueue.main
        self._observable = ObservableSync<Void>()
        self._syncQueue = syncQueue
        self._tolerance = tolerance
    }
    
    private func _invalidate() {
        if let timer = self._timer {
            timer.invalidate()
            self._timer = nil
        }
    }
    
    public func invalidate() {
        self._syncQueue.async {
            self._invalidate()
        }
    }
    
    public func fireAfter(seconds: TimeInterval) {
        self._syncQueue.async {
            self._invalidate()
            let timer = Timer(timeInterval: seconds, repeats: false) {
                _ in self._observable.send()
            }
            timer.tolerance = self._tolerance
            RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
            self._timer = timer
        }
    }
    
    deinit {
        _observable.unsubscribeAll()
    }    
}