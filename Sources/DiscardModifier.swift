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

public final class DiscardModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private var _count: Int
    
    fileprivate init(count: Int) {
        self._count = count
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        if _count > 0 {
            _count -= 1
        }
        else {
            notify(message)
        }
    }
}

public typealias DiscardObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut, DiscardModifier<O.MessageOut>>
public typealias DiscardTail<O: ObservableType> = Tail<DiscardObservable<O>>

extension Tail {
    public func discard(first n: Int) -> DiscardTail<SourceObservable> {
        let discardObservable = DiscardObservable(
            source: self.observable,
            modifier: DiscardModifier<SourceObservable.MessageOut>(count: n),
            dispatchQueue: self.dispatchQueue)
        
        return DiscardTail<SourceObservable>(
            observable: discardObservable,
            dispatchQueue: self.dispatchQueue)
    }
}
