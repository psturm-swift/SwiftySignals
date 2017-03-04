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
class TimerSignalTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testIfTimerTriggersAtLeastTwice() {
        let observables = ObservableCollection()
        let expectations = [
            self.expectation(description: "Timer has been triggered once"),
            self.expectation(description: "Timer has been triggered twice")
        ]
        
        let timer = TimerSignal(interval: Measurement(value: 1.0, unit: UnitDuration.seconds), repeats: true)
        
        var currentExpectation = 0
        timer
            .fired
            .then {
                guard currentExpectation < expectations.count else { return }
                expectations[currentExpectation].fulfill()
                currentExpectation += 1
            }
            .append(to: observables)
        
        timer.enable()
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(2, currentExpectation)
    }
    
    func testIfTimerTriggersAfterADefinedTimeInterval() {
        let observables = ObservableCollection()
        let expectation = self.expectation(description: "Timer has been triggered")
        let timer = TimerSignal(interval: Measurement(value: 2, unit: UnitDuration.seconds), repeats: false)
        
        timer
            .fired
            .then { expectation.fulfill() }
            .append(to: observables)
        
        timer.enable()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    static var allTests : [(String, (TimerSignalTests) -> () throws -> Void)] {
        let unitTests : [(String, (TimerSignalTests) -> () throws -> Void)] = [
            ("testIfTimerTriggersAtLeastTwice", testIfTimerTriggersAtLeastTwice),
            ("testIfTimerTriggersAfterADefinedTimeInterval", testIfTimerTriggersAfterADefinedTimeInterval)
        ]
        return unitTests
    }
    
}
