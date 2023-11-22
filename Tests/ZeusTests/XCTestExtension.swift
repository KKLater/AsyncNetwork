//
//  XCTestCase.swift
//
//
//  Created by 罗树新 on 2023/7/3.
//

import XCTest

extension XCTestCase {
    
    func expectation(timeout: TimeInterval,
                     description: String? = nil,
                     action: (_ expectation: XCTestExpectation) -> Void) {
        let expectation = XCTestExpectation(description: description ?? UUID().uuidString)
        action(expectation)
        wait(for: [expectation], timeout: 60)
    }
    
}
