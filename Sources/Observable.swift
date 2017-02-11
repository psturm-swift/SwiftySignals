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

public final class Observable<T>: ObservableType {
    public typealias MessageOut = T

    private var _observers: [AnyObserver<MessageOut>] = []
    private var _lastMessage: T? = nil
    
    public func subscribe<O : ObserverType>(observer: O) where O.MessageIn == MessageOut {
        if !self._observers.contains(where: { $0._base === observer }) {
            self._observers.append(AnyObserver<O.MessageIn>(base: observer))
            if let lastMessage = self._lastMessage {
                observer.process(message: lastMessage)
            }
        }
    }

    public func unsubscribe<O : ObserverType>(observer: O) where O.MessageIn == MessageOut {
        self._observers = self._observers.filter { $0._base !== observer }
        observer.unsubscribed()
    }

    internal func send(_ message: MessageOut) {
        self._lastMessage = message
        for observer in self._observers {
            observer.process(message: message)
        }
    }
        
    internal func send(message: MessageOut) {
        send(message)
    }
    
    public func unsubscribeAll() {
        for observer in self._observers {
            observer.unsubscribed()
        }
        self._observers = []
    }
}
