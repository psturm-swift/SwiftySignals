// Copyright (c) 2016 Patrick Sturm <psturm.mail@googlemail.com>
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

public final class Slot<Message> {
    fileprivate let function: (Message)->Void
    fileprivate let context: InvocationContext
    fileprivate weak var receiver: AnyObject?
    fileprivate weak var event: Event<Message>?
    
    init(context: InvocationContext, receiver: AnyObject, event: Event<Message>, function: @escaping (Message)->Void) {
        self.function = function
        self.context = context
        self.receiver = receiver
        self.event = event
    }
    
    func invoke(with argument: Message) {
        if isValid {
            context.invoke {
                self.function(argument)
            }
        }
    }

    var isValid: Bool {
        return receiver != nil
    }

    public func unsubscribe() {
        if let event = self.event {
            event.remove(slot: self)
        }
    }
}
