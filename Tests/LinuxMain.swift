import XCTest
@testable import SwiftySignalsTests

XCTMain([
     testCase(PropertyTests.allTests),
     testCase(TimerSignalTests.allTests),
     testCase(DispatchTests.allTests),
     testCase(DistincTests.allTests),
     testCase(DebounceTests.allTests)
])
