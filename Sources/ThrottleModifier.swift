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

public final class ThrottleModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private let _timeDiff: TimeInterval
    private var _last: TimeInterval = 0
    
    fileprivate init(maxRate: Measurement<UnitFrequency>) {
        _timeDiff = 1.0 / maxRate.converted(to: UnitFrequency.hertz).value
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        let now = Date().timeIntervalSince1970

        if now - _last >= _timeDiff {
            _last = now
            notify(message)
        }
    }
}

public typealias ThrottleObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut>
public typealias ThrottleTail<O: ObservableType> = Tail<ThrottleObservable<O>>

extension Tail {
    public func throttle(maxRate: Measurement<UnitFrequency>) -> ThrottleTail<SourceObservable> {
        let throttleObservable = ThrottleObservable(
            source: self.observable,
            modifier: ThrottleModifier<SourceObservable.MessageOut>(maxRate: maxRate))
        
        return ThrottleTail<SourceObservable>(
            observable: throttleObservable,
            dispatchQueue: self.dispatchQueue)
    }
}
