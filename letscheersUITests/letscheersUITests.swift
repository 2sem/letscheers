//
//  letscheersUITests.swift
//  letscheersUITests
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import XCTest

class letscheersUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
    }
    
    func testToSelectToasts(){
        let app = XCUIApplication()
        
        for i in 1...10{
            for mainrow in app.tables.cells.allElementsBoundByIndex{
                mainrow.tap();
                for row in app.tables.cells.allElementsBoundByIndex{
                    print("tap toast cell - \(mainrow.staticTexts.allElementsBoundByIndex.first) \(row.staticTexts.allElementsBoundByIndex.first)");
                    row.tap();
                    app.alerts.element(boundBy: 0).buttons["확인"].tap()
                    
                }
                
                XCUIApplication().navigationBars.element(boundBy: 0).buttons["건배사"].tap()
            }
            
            print("complete one = \(i)");
        }
        //app.tables.containing(.searchField, identifier:"검색어").element.tap()
    }
}
