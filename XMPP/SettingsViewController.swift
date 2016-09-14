import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet var sessionTimeOut: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let defaults = NSUserDefaults.standardUserDefaults()
        let timeout = defaults.doubleForKey(kSessionTimeString)
        
        if timeout>0
        {
            self.sessionTimeOut.text = String(defaults.doubleForKey(kSessionTimeString))
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textFieldDidEndEditing(textField: UITextField)
    {
        //print("TextField did end editing method called")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(Double(self.sessionTimeOut.text!)!,  forKey: kSessionTimeString);
    }

}
