import XCTest
import Foundation
import UIKit
@testable import Smack


class LoginTests: XCTestCase {
    
    var vc : LoginViewController!
    
    override func setUp(){
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        vc = navigationController.topViewController as! LoginViewController
        vc.viewDidLoad()
    }
    
    func testValidation(){
        let validEmail = vc.isValidEmail("test@test.com")
        XCTAssert(validEmail == true)
        
        let notValidEmail = vc.isValidEmail("test")
        XCTAssert(notValidEmail == false)

        let noEmail = vc.isValidEmail("")
        XCTAssert(noEmail == false)

        
        let validPass = vc.isValidPassword("College@13")
        XCTAssert(validPass == true)
        
        let tooShortPass = vc.isValidPassword("pass")
        XCTAssert(tooShortPass == false)
        
        let weakPass = vc.isValidPassword("dog12345")
        XCTAssert(weakPass == false)
    }
    
    func testLogin(){
        
        var b : UIButton
        b = vc.validateButton
        
        vc.usernameTextField.text = ""
        vc.passwordTextField.text = ""
        vc.login(b)
        
        XCTAssert(vc.usernameIsInvalid.hidden == false)
        XCTAssert(vc.usernameIsInvalid.text == kNoString)
        XCTAssert(vc.passwordIsInvalid.hidden == true)
        
        vc.usernameTextField.text = "test"
        vc.login(b)
        XCTAssert(vc.usernameIsInvalid.hidden == false)
        XCTAssert(vc.usernameIsInvalid.text == kEmailIsInvalid)
        XCTAssert(vc.passwordIsInvalid.hidden == true)
        
        vc.usernameTextField.text = "daithi@jwchat.org"
        vc.login(b)
        XCTAssert(vc.usernameIsInvalid.hidden == true)
        XCTAssert(vc.passwordIsInvalid.text == kPasswordLengthError)
        XCTAssert(vc.passwordIsInvalid.hidden == false)
        
        vc.passwordTextField.text = "dog12345"
        vc.login(b)
        XCTAssert(vc.usernameIsInvalid.hidden == true)
        XCTAssert(vc.passwordIsInvalid.text == kPasswordError)
        XCTAssert(vc.passwordIsInvalid.hidden == false)
        
        vc.passwordTextField.text = "College@13"
        vc.login(b)
        XCTAssert(vc.usernameIsInvalid.hidden == true)
        XCTAssert(vc.passwordIsInvalid.hidden == true)
    }
    
    override func tearDown(){
        super.tearDown()
    }
}