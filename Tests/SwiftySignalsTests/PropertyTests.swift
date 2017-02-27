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

class PropertyTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testThatPropertyValueCanBeReadOut() {
        let property = Property<Int>(value: 54)
        XCTAssertEqual(54, property.value)
    }
    
    func testThatPropertyValueCanBeChanged() {
        let property = Property<Int>(value: 54)
        property.value = 64
        XCTAssertEqual(64, property.value)
    }
    
    func testIfOnlyEvenNumbersCanBeObserved() {
        let observables = ObservableCollection()
        let property = Property<Int>(value: 53)

        let expectEvenNumber = self.expectation(description: "Expect even number")
        
        property
            .didSet
            .filter { $0 % 2 == 0 }
            .then { XCTAssertTrue($0 % 2 == 0) }
            .then { _ in expectEvenNumber.fulfill() }
            .append(to: observables)
        
        property.value = 54
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testIfLastMessageIsPropagatedOnSubscription() {
        let observables = ObservableCollection()
        let property = Property<Int>(value: 13)
        let expectLastMessage = self.expectation(description: "Expect last message")
        
        property
            .didSet
            .map { $0 == 13 }
            .then { XCTAssertTrue($0) }
            .then { _ in expectLastMessage.fulfill() }
            .append(to: observables)
        
        self.waitForExpectations(timeout: 10, handler: nil)
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

    static var allTests : [(String, (PropertyTests) -> () throws -> Void)] {
        let unitTests : [(String, (PropertyTests) -> () throws -> Void)] = [
            ("testThatPropertyValueCanBeReadOut", testThatPropertyValueCanBeReadOut),
            ("testThatPropertyValueCanBeChanged", testThatPropertyValueCanBeChanged),
            ("testIfOnlyEvenNumbersCanBeObserved", testIfOnlyEvenNumbersCanBeObserved),
            ("testIfLastMessageIsPropagatedOnSubscription", testIfLastMessageIsPropagatedOnSubscription),
            ("testIfBlocksAreExecutedOnMainQueueOnSubscription", testIfBlocksAreExecutedOnMainQueueOnSubscription),
            ("testIfBlocksAreExecutedOnMainQueueIfPropertyDidSet", testIfBlocksAreExecutedOnMainQueueIfPropertyDidSet)
        ]
        return unitTests
    }
    
}
