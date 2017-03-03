import XCTest
@testable import SwiftySignalsTests

XCTMain([
     testCase(PropertyTests.allTests),
     testCase(OnceOnlyTimerTests.allTests),
     testCase(PeriodicTimerTests.allTests),
     testCase(DispatchTests.allTests)
])
