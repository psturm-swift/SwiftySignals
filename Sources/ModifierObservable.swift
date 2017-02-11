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

public final class ModifierObservable<O: ObservableType, T, M: ModifierType>: ObservableType where M.MessageIn == O.MessageOut, M.MessageOut == T {
    public typealias MessageIn = O.MessageOut
    public typealias MessageOut = T

    private let _observable = Observable<T>()
    private let _syncQueue: DispatchQueue
    private let _dispatchQueue: DispatchQueue
    private let _modifier: M
    private var _source: O? = nil
    private var _forwarder: Forward<ModifierObservable, MessageIn>! = nil
    
    public init(source: O, modifier: M, dispatchQueue: DispatchQueue)
    {
        self._syncQueue = DispatchQueue(label: "SwiftySignals.ModifierObservable")
        self._dispatchQueue = dispatchQueue
        self._source = source
        self._modifier = modifier
        self._forwarder = Forward(
            target: self,
            processMessage: ModifierObservable.process,
            unsubscribed: ModifierObservable.unsubscribed
        )
        source.subscribe(observer: self._forwarder)
    }
    
    deinit {
        if let source = self._source {
            source.unsubscribe(observer: self._forwarder)
        }
    }
    
    public func subscribe<Observer: ObserverType>(observer: Observer) where Observer.MessageIn == MessageOut {
        _syncQueue.async(flags: .barrier) {
            self._observable.subscribe(observer: observer)
        }
    }
    
    public func unsubscribe<Observer: ObserverType>(observer: Observer) where Observer.MessageIn == MessageOut {
        _syncQueue.async(flags: .barrier) {
            self._observable.unsubscribe(observer: observer)
        }
    }

    private func process(_ message: MessageIn) {
        _dispatchQueue.async {
            self._modifier.process(message: message, notify: {
                [weak self] newMessage in
                if let observable = self?._observable {
                    observable.send(message: newMessage)
                }
            })
        }
    }
    
    private func unsubscribed() {
        self._syncQueue.async {
            self._source = nil
            self._observable.unsubscribeAll()
        }
    }
}
