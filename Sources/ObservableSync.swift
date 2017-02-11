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

public final class ObservableSync<T>: ObservableType {
    public typealias MessageOut = T
    private let _observable = Observable<T>()
    private let _syncQueue: DispatchQueue
    
    public init() {
        self._syncQueue = DispatchQueue(label: "ObservableSync")
    }
    
    public func subscribe<O : ObserverType>(observer: O) where O.MessageIn == MessageOut {
        self._syncQueue.async(flags: .barrier) {
            self._observable.subscribe(observer: observer)
        }
    }
    
    public func unsubscribe<O : ObserverType>(observer: O) where O.MessageIn == MessageOut {
        self._syncQueue.async(flags: .barrier) {
            self._observable.unsubscribe(observer: observer)
        }
    }
    
    internal func send(_ message: MessageOut) {
        self._syncQueue.async(flags: .barrier) {
            self._observable.send(message)
        }
    }
    
    internal func send(message: MessageOut) {
        self._syncQueue.async(flags: .barrier) {
            self._observable.send(message: message)
        }
    }
    
    public func unsubscribeAll() {
        self._syncQueue.async(flags: .barrier) {
            self._observable.unsubscribeAll()
        }
    }
}
