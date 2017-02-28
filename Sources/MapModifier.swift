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

public final class MapModifier<S, T>: ModifierType {
    public typealias MessageIn = S
    public typealias MessageOut = T

    private let _transform: (MessageIn)->MessageOut

    fileprivate init(transform: @escaping (MessageIn)->MessageOut) {
        self._transform = transform
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        notify(self._transform(message))
    }
}

public typealias MapObservable<O: ObservableType, T> = ModifierObservable<O, T>
public typealias MapTail<O: ObservableType, T> = Tail<MapObservable<O, T>>

extension Tail {
    public func map<T>(transform: @escaping (SourceObservable.MessageOut)->T) -> MapTail<SourceObservable, T> {
        let mapObservable = MapObservable(
            source: self.observable,
            modifier: MapModifier<SourceObservable.MessageOut, T>(transform: transform),
            dispatchQueue: self.dispatchQueue)
        
        return MapTail<SourceObservable, T>(
            observable: mapObservable,
            dispatchQueue: self.dispatchQueue)
    }
}
