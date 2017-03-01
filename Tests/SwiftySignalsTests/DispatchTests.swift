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

class DispatchTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testIfBlocksAreExecutedOnMainQueueOnSubscription() {
        let observables = ObservableCollection()
        let propertyProcessed = self.expectation(description: "Property processed")
        let property = Property<Bool>(value: true)
        
        property
            .didSet
            .then { _ in XCTAssertTrue(Thread.isMainThread) }
            .map {
                value -> Bool in
                XCTAssertTrue(Thread.isMainThread)
                return !value
            }
            .then { _ in propertyProcessed.fulfill() }
            .append(to: observables)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testIfBlocksAreExecutedOnMainQueueIfPropertyDidSet() {
        let observables = ObservableCollection()
        let propertyProcessed = self.expectation(description: "Property processed")
        let property = Property<Bool>(value: true)
        
        property
            .didSet
            .discard(first: 1)
            .then { _ in XCTAssertTrue(Thread.isMainThread) }
            .map {
                value -> Bool in
                XCTAssertTrue(Thread.isMainThread)
                return !value
            }
            .then { _ in propertyProcessed.fulfill() }
            .append(to: observables)
        
        property.value = !property.value
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testIfBlocksAreExecutedNotOnMainThreadIfDispatchIsTurnedOff() {
        let observables = ObservableCollection()
        let propertyProcessed = self.expectation(description: "Property processed")
        let property = Property<Bool>(value: true)
        
        property
            .didSet
            .noDispatch()
            .discard(first: 1)
            .then { _ in XCTAssertTrue(!Thread.isMainThread) }
            .map {
                value -> Bool in
                XCTAssertTrue(!Thread.isMainThread)
                return !value
            }
            .then { _ in propertyProcessed.fulfill() }
            .append(to: observables)
        
        property.value = !property.value
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    static var allTests : [(String, (DispatchTests) -> () throws -> Void)] {
        let unitTests : [(String, (DispatchTests) -> () throws -> Void)] = [
            ("testIfBlocksAreExecutedOnMainQueueOnSubscription", testIfBlocksAreExecutedOnMainQueueOnSubscription),
            ("testIfBlocksAreExecutedOnMainQueueIfPropertyDidSet", testIfBlocksAreExecutedOnMainQueueIfPropertyDidSet),
            ("testIfBlocksAreExecutedNotOnMainThreadIfDispatchIsTurnedOff", testIfBlocksAreExecutedNotOnMainThreadIfDispatchIsTurnedOff)
        ]
        return unitTests
    }
    
}
