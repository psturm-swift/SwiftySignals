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

public final class ThenFunctionModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private let _instanceFunction: InstanceFunction<MessageIn>

    fileprivate init<Target: AnyObject>(target: Target, function: @escaping (Target)->((MessageOut)->Void)) {
        self._instanceFunction = InstanceFunction(target: target, function: function)
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        self._instanceFunction.call(with: message)
        notify(message)
    }
}

public typealias ThenFunctionObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut>
public typealias ThenFunctionEndPoint<O: ObservableType> = EndPoint<ThenFunctionObservable<O>>

extension EndPoint {
    public func then<Target: AnyObject>(
        call function: @escaping (Target)->((SourceObservable.MessageOut)->Void),
        on target: Target)
        -> ThenFunctionEndPoint<SourceObservable>
    {
        let thenObservable = ThenFunctionObservable(
            source: self.observable,
            modifier: ThenFunctionModifier<SourceObservable.MessageOut>(target: target, function: function),
            dispatchQueue: self.dispatchQueue
        )
        
        return endPoint(with: thenObservable)
    }
}

public final class ThenBlockModifier<T>: ModifierType {
    public typealias MessageIn = T
    public typealias MessageOut = T
    
    private let _block: (MessageIn)->Void

    fileprivate init(block: @escaping (MessageIn)->Void) {
        self._block = block
    }
    
    public func process(message: MessageIn, notify: @escaping (MessageOut) -> Void) {
        self._block(message)
        notify(message)
    }
}

public typealias ThenBlockObservable<O: ObservableType> = ModifierObservable<O, O.MessageOut>
public typealias ThenBlockEndPoint<O: ObservableType> = EndPoint<ThenBlockObservable<O>>

extension EndPoint {
    public func then(do block: @escaping (SourceObservable.MessageOut)->Void) -> ThenBlockEndPoint<SourceObservable> {
        let thenObservable = ThenBlockObservable(
            source: self.observable,
            modifier: ThenBlockModifier<SourceObservable.MessageOut>(block: block),
            dispatchQueue: self.dispatchQueue)

        return endPoint(with: thenObservable)
    }
    
}
