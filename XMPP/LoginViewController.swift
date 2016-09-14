import UIKit
import XMPPFramework
import xmpp_messenger_ios

class LoginViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameIsInvalid: UILabel!
    @IBOutlet var passwordIsInvalid: UILabel!
    @IBOutlet var validateButton: UIButton!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        self.navigationItem.setHidesBackButton(true, animated:true);

    }
    
    // Mark: Private Methods
    
    func DismissKeyboard() {
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark:Action methods

    @IBAction func login(sender: AnyObject)
    {
        
        if OneChat.sharedInstance.isConnected()
        {
            OneChat.sharedInstance.disconnect()
            usernameTextField.hidden = false
            passwordTextField.hidden = false
            validateButton.setTitle(kLoginBtnTitle, forState: UIControlState.Normal)
        }
        else
        {
            if self.usernameTextField.text!.isEmpty {
                self.usernameIsInvalid.text = kNoString
                self.usernameIsInvalid.hidden = false
                return
            }else{
                self.usernameIsInvalid.hidden = true
            }
            
            if !isValidEmail(self.usernameTextField.text!){
                self.usernameIsInvalid.text = kEmailIsInvalid
                self.usernameIsInvalid.hidden = false
                return
            }else{
                self.usernameIsInvalid.hidden = true
            }
            
            if self.passwordTextField.text!.characters.count < 7{
                self.passwordIsInvalid.text = kPasswordLengthError
                self.passwordIsInvalid.hidden = false
                return
            }else{
                self.passwordIsInvalid.hidden = true
            }
            
            if !isValidPassword(self.passwordTextField.text!) {
                self.passwordIsInvalid.text = kPasswordError
                self.passwordIsInvalid.hidden = false
                return
            }else{
                self.passwordIsInvalid.hidden = true
            }
            
            self.activityIndicatorView.startAnimating()
            OneChat.sharedInstance.connect(username: self.usernameTextField.text!, password: self.passwordTextField.text!)
            { (stream, error) -> Void in
                self.activityIndicatorView.stopAnimating()

                if let _ = error {
                    let alertController = UIAlertController(title: kSorryString, message: kErrorString + " \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: kOKString, style: UIAlertActionStyle.Default, handler:
                        { (UIAlertAction) -> Void in
                        //do something
                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                } else
                {
                    self.activityIndicatorView.stopAnimating()

                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.isUserLoggedIn = true
                    self.passwordTextField.resignFirstResponder()
                    
                    self.performSegueWithIdentifier(kOpenChatSegue, sender: nil)
                }
            }
        }
    }
    
    
    // Mark: UITextField Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if passwordTextField.isFirstResponder()
        {
            textField.resignFirstResponder()
            login(self)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //Validate Email
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    //Validate Password
    func isValidPassword(testStr:String) -> Bool {
        let passRegEx = "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{7,20})"
        
        let passTest = NSPredicate(format: "SELF MATCHES %@", passRegEx)
        return passTest.evaluateWithObject(testStr)
    }

}

