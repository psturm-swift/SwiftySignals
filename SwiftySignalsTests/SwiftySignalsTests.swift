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

import XCTest
@testable import SwiftySignals


class Helper {
    var reference: SwiftySignals
    
    init(reference: SwiftySignals) {
        self.reference = reference
    }
    
    func updateValue(newValue: Int) {
        reference.value2 = newValue
    }
}

class SwiftySignals: XCTestCase {
    var timerCounter = 0
    
    var property = Property(value: 42)
    var value1 = 0
    var value2 = 0
    var value3 = 0
    
    override func setUp() {
        super.setUp()
        property = Property(value: 42)
        value1 = 0
        value2 = 0
        value3 = 0
        timerCounter = 0
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func updateValue1(newValue: Int) {
        value1 = newValue
    }
    
    func updateValue2(newValue: Int) {
        value2 = newValue
    }
    
    func testIfAllObserversAreCalledIfTheyAreConnectedTheFirstTime() {
        property.didSet.then(on: self, call: SwiftySignals.updateValue1)
        property.didSet.then(on: self, call: SwiftySignals.updateValue2)
        
        XCTAssertEqual(42, value1)
        XCTAssertEqual(42, value2)
        XCTAssertEqual(2, property.didSet.subscriberCount)
    }

    func testIfAllObserversAreCalledIfTheValueChanges() {
        property.didSet.then(on: self, call: SwiftySignals.updateValue1)
        property.didSet.then(on: self, call: SwiftySignals.updateValue2)

        property.value = 84

        XCTAssertEqual(84, value1)
        XCTAssertEqual(84, value2)
        XCTAssertEqual(2, property.didSet.subscriberCount)
    }
    
    func testIfReleasedSlotsAreIgnored() {
        property.didSet.then(on: self, call: SwiftySignals.updateValue1)

        var helper: Helper? = Helper(reference: self)
        if let helper = helper {
            property.didSet.then(on: helper, call: Helper.updateValue)
        }
        helper = nil
        
        property.value = 21
        XCTAssertEqual(21, value1)
        XCTAssertEqual(42, value2)
        XCTAssertEqual(1, property.didSet.subscriberCount)
    }
    
    func testIfMainQueueInvocationPolicyDefersTheInvocation() {
        let expectation = self.expectationWithDescription("I expect that value3 is equal to 84")

        property.didSet.then(on: self, call: SwiftySignals.updateValue1)
        property.didSet.then(on: self, call: SwiftySignals.updateValue2)
        property.didSet.then(invoke: .OnMainQueue, with: self, call: { (owner, newValue) in
            owner.value3 = newValue
            if newValue == 84 {
                expectation.fulfill()
            }
        })
        
        property.value = 84
        XCTAssertEqual(84, value1)
        XCTAssertEqual(84, value2)
        XCTAssertEqual(0, value3)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
        XCTAssertEqual(3, property.didSet.subscriberCount)
    }
    
    func testIfTimerFiresOnlyOnce() {
        let expectation = self.expectationWithDescription("I expect that the timer has fired only once within 4 seconds")

        let timerExpectation = Timer()
        timerExpectation.fired.then(with: self) { (_, _) in
            expectation.fulfill()
        }
        timerExpectation.fireAfter(seconds: 4.0)
        
        let timer = Timer()

        timer.fired.then(with: self) { owner in
            owner.timerCounter += 1
        }
        timer.fireAfter(seconds: 1.0)

        waitForExpectationsWithTimeout(10.0, handler: nil)
        
        XCTAssertEqual(1, timerCounter)
    }
    
    func testIfPeriodicTimerFiresMoreThanOnce() {
        let expectation = self.expectationWithDescription("I expect that the timer has fired only once within 4 seconds")
        
        let timerExpectation = Timer()
        timerExpectation.fired.then(with: self) { (_, _) in
            expectation.fulfill()
        }
        timerExpectation.fireAfter(seconds: 4.0)
        
        let timer = PeriodicTimer()
        timer.fired.then(with: self) { owner in
            owner.timerCounter += 1
        }
        timer.interval = 1.0
        timer.activate()
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
        
        XCTAssertLessThan(1, timerCounter)
    }
    
    func testIfOnlyFunctionsAreCalledThatPassTheFilter() {
        property.didSet.filter({$0 > 0}).then(on: self, call: SwiftySignals.updateValue1)
        property.didSet.filter({$0 > 100}).then(on: self, call: SwiftySignals.updateValue2)
        
        XCTAssertEqual(42, value1)
        XCTAssertEqual(0, value2)
        XCTAssertEqual(2, property.didSet.subscriberCount)
    }
}
