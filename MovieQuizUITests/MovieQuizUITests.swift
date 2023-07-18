//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ivan Ch on 18.07.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false

    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }

    
    
    func testScreenCast() throws {
        let app = XCUIApplication()
        let button = app.buttons["Нет"]
        button.tap()
        
        let button2 = app.buttons["Да"]
        button2.tap()
        button.tap()
        button.tap()
        button2.tap()
        button2.tap()
        button.tap()
        button2.tap()
        button.tap()
        button.tap()
        
    }
    
}
