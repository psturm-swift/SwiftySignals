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

import XCTest
@testable import SwiftySignals

class DistinctTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testIfOnlyDistinctMessagesArePassed() {
        let expectation = self.expectation(description: "Last message should be 10")
        let signal = Signal<Int>()
        let observables = ObservableCollection()
        var result = 0
        var count = 0
        
        signal
            .fired
            .distinct()
            .then {
                result += $0
                count += 1
                if $0 == 10 {
                    expectation.fulfill()
                }
            }
            .append(to: observables)
        
        signal.fire(with: 2)
        signal.fire(with: 2)
        signal.fire(with: 2)
        signal.fire(with: 3)
        signal.fire(with: 3)
        signal.fire(with: 10)
        
        self.waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(3, count)
        XCTAssertEqual(15, result)
        
    }

    static var allTests : [(String, (DistinctTests) -> () throws -> Void)] {
        let unitTests : [(String, (DistinctTests) -> () throws -> Void)] = [
            ("testIfOnlyDistinctMessagesArePassed", testIfOnlyDistinctMessagesArePassed)
        ]
        return unitTests
    }
    
}
