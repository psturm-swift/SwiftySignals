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

public struct EndPoint<O: ObservableType> {
    public typealias SourceObservable = O
    
    public let observable: SourceObservable
    public let dispatchQueue: DispatchQueue?
    public let owner: OwnerType?
    
    internal init(
        observable: SourceObservable,
        dispatchQueue: DispatchQueue? = nil,
        owner: OwnerType? = nil)
    {
        self.observable = observable
        self.dispatchQueue = dispatchQueue
        self.owner = owner
    }
    
    public func endPoint<R: ObservableType>(with observable: R) -> EndPoint<R> {
        return EndPoint<R>(
            observable: observable,
            dispatchQueue: self.dispatchQueue,
            owner: self.owner)
    }
}
