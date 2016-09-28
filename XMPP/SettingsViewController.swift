import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet var sessionTimeOut: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let timeout = defaults.double(forKey: kSessionTimeString)
        
        if timeout>0
        {
            self.sessionTimeOut.text = String(defaults.double(forKey: kSessionTimeString))
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
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        //print("TextField did end editing method called")
        
        let defaults = UserDefaults.standard
        defaults.set(Double(self.sessionTimeOut.text!)!,  forKey: kSessionTimeString);
    }

}
