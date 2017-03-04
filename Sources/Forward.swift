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

final class Forward<T>: ObserverType {
    typealias MessageIn = T
    private let _processMessage: InstanceFunction<T>
    private let _unsubscribed: InstanceFunction<Void>

    init<Target: AnyObject>(target: Target, processMessage: @escaping (Target)->((T)->Void), unsubscribed: @escaping (Target)->(()->Void)) {
        self._processMessage = InstanceFunction(target: target, function: processMessage)
        self._unsubscribed = InstanceFunction(target: target, function: unsubscribed)
    }
    
    func process(message: MessageIn) {
        _processMessage.call(with: message)
    }
    
    func unsubscribed() {
        _unsubscribed.call()
    }
}
