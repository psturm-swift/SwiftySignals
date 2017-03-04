// Copyright (c) 2017 Patrick Sturm <psturm.mail@googlemail.com>
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
public final class DebounceModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private let _timeout: TimeInterval
    private var _timer: Timer? = nil
    
    fileprivate init(timeout: Measurement<UnitDuration>) {
        _timeout = timeout.converted(to: .seconds).value
    }
    
    private func invalidateTimer() {
        if let timer = self._timer {
            DispatchQueue.main.async { timer.invalidate() }
        }
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        invalidateTimer()
        
        let timer = Timer(timeInterval: self._timeout, repeats: false) {
            _ in notify(message)
        }
        timer.tolerance = 0

        DispatchQueue.main.async {
            RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        }

        self._timer = timer
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public typealias DebounceObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut>

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public typealias DebounceEndPoint<O: ObservableType> = EndPoint<DebounceObservable<O>>

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
extension EndPoint {
    public func debounce(timeout: Measurement<UnitDuration>) -> DebounceEndPoint<SourceObservable> {
        let debounceObservable = DebounceObservable(
            source: self.observable,
            modifier: DebounceModifier<SourceObservable.MessageOut>(timeout: timeout))
        
        return DebounceEndPoint<SourceObservable>(
            observable: debounceObservable,
            dispatchQueue: self.dispatchQueue)
    }
}
