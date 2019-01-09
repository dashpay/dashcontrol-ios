//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

class DashControlSnapshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        app.launchEnvironment = [ "UITesting": "1" ]
        setupSnapshot(app)
        app.launch()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMakeSnapshot() {
        snapshot("0News")
        
        // ----------------------------
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Proposals"].tap()
        
        snapshot("1Proposals")
        
        // ----------------------------
        
//        tabBarsQuery.buttons["Price"].tap()
//        app.staticTexts["1W"].tap()
//        app.staticTexts["4H"].tap()
//
//        snapshot("2Price")
        
        // ----------------------------
        
        tabBarsQuery.buttons["Portfolio"].tap()

        snapshot("3Portfolio")
    }
    
}
