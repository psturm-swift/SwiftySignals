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
// THE SOFTWARE

import Foundation

public final class Property<T> {
    private let _observable: ObservableSync<T>
    private let _syncQueue: DispatchQueue
    private var _value: T
    
    public var value: T {
        set {
            self._syncQueue.async(flags: .barrier) {
                self._value = newValue
                self._observable.send(message: newValue)
            }
        }
        get {
            var syncedValue: T!
            self._syncQueue.sync {
                syncedValue = self._value
            }
            return syncedValue
        }
    }
    
    public var didSet: EndPoint<ObservableSync<T>> {
        return EndPoint<ObservableSync<T>>(
            observable: _observable,
            dispatchQueue: DispatchQueue.main)
    }
    
    public init(value: T) {
        let syncQueue = DispatchQueue(label: "SwiftySignals.Property", attributes: .concurrent)
        self._observable = ObservableSync<T>()
        self._syncQueue = syncQueue
        self._value = value
        self._observable.send(message: value)
    }
    
    deinit {
        _observable.unsubscribeAll()
    }
}
