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

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
class DebounceTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testIfOnlyTheLastMessageOfASeriesIsPassed() {
        let observables = ObservableCollection()
        let signal = Signal<Int>()
        let expectation = self.expectation(description: "Last message arrives")
        
        signal
            .fired
            .debounce(timeout: Measurement(value: 2, unit: UnitDuration.seconds))
            .then {
                XCTAssertEqual(10, $0)
                if $0 == 10 {
                    expectation.fulfill()
                }
            }
            .giveOwnership(to: observables)

        for msg in 0...10 {
            signal.fire(with: msg)
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    static var allTests : [(String, (DebounceTests) -> () throws -> Void)] {
        let unitTests : [(String, (DebounceTests) -> () throws -> Void)] = [
            ("testIfOnlyTheLastMessageOfASeriesIsPassed", testIfOnlyTheLastMessageOfASeriesIsPassed)
        ]
        return unitTests
    }
    
}
