
import Foundation

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
        // Given
       let array = [1, 2, 3, 4, 5]
        
       // When
       let value = array[safe: 2]
        
       // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
        }
        
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        // Given
            let array = [1, 1, 2, 3, 5]
            
            // When
            let value = array[safe: 20]
            
            // Then
            XCTAssertNil(value)
    }
}
