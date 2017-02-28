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

public final class FilterModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private let _predicate: (MessageIn)->Bool
    
    fileprivate init(predicate: @escaping (MessageIn)->Bool) {
        self._predicate = predicate
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        if self._predicate(message) {
            notify(message)
        }
    }
}

public typealias FilterObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut>
public typealias FilterTail<O: ObservableType> = Tail<FilterObservable<O>>

extension Tail {
    public func filter(predicate: @escaping (SourceObservable.MessageOut)->Bool) -> FilterTail<SourceObservable> {
        let filterObservable = FilterObservable(
            source: self.observable,
            modifier: FilterModifier<SourceObservable.MessageOut>(predicate: predicate),
            dispatchQueue: self.dispatchQueue)
        
        return FilterTail<SourceObservable>(
            observable: filterObservable,
            dispatchQueue: self.dispatchQueue)
    }
}
