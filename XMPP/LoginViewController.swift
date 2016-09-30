import UIKit
import XMPPFramework
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
        if usernameTextField.isFirstResponder {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark:Action methods

    @IBAction func login(_ sender: AnyObject)
    {
        
        if ChatConnector.sharedInstance.isConnected()
        {
            ChatConnector.sharedInstance.disconnect()
            usernameTextField.isHidden = false
            passwordTextField.isHidden = false
            validateButton.setTitle(kLoginBtnTitle, for: UIControlState())
        }
        else
        {
            if self.usernameTextField.text!.isEmpty {
                self.usernameIsInvalid.text = kNoString
                self.usernameIsInvalid.isHidden = false
                return
            }else{
                self.usernameIsInvalid.isHidden = true
            }
            
            if !isValidEmail(self.usernameTextField.text!){
                self.usernameIsInvalid.text = kEmailIsInvalid
                self.usernameIsInvalid.isHidden = false
                return
            }else{
                self.usernameIsInvalid.isHidden = true
            }
            
            if self.passwordTextField.text!.characters.count < 7{
                self.passwordIsInvalid.text = kPasswordLengthError
                self.passwordIsInvalid.isHidden = false
                return
            }else{
                self.passwordIsInvalid.isHidden = true
            }
            
            if !isValidPassword(self.passwordTextField.text!) {
                self.passwordIsInvalid.text = kPasswordError
                self.passwordIsInvalid.isHidden = false
                return
            }else{
                self.passwordIsInvalid.isHidden = true
            }
            
            self.activityIndicatorView.startAnimating()
            ChatConnector.sharedInstance.connect(username: self.usernameTextField.text!, password: self.passwordTextField.text!)
            { (stream, error) -> Void in
                self.activityIndicatorView.stopAnimating()

                if let _ = error {
                    let alertController = UIAlertController(title: kSorryString, message: kErrorString + " \(error)", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: kOKString, style: UIAlertActionStyle.default, handler:
                        { (UIAlertAction) -> Void in
                        //do something
                    }))

                    self.present(alertController, animated: true, completion: nil)
                } else
                {
                    self.activityIndicatorView.stopAnimating()

                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.isUserLoggedIn = true
                    self.passwordTextField.resignFirstResponder()
                    
                    self.performSegue(withIdentifier: kOpenChatSegue, sender: nil)
                }
            }
        }
    }
    
    
    // Mark: UITextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if passwordTextField.isFirstResponder
        {
            textField.resignFirstResponder()
            login(self)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //Validate Email
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //Validate Password
    func isValidPassword(_ testStr:String) -> Bool {
        let passRegEx = "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{7,20})"
        
        let passTest = NSPredicate(format: "SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: testStr)
    }

}

