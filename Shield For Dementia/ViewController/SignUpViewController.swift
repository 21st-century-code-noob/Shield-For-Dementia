//
//  SignInViewController.swift
//  Shield For Dementia
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var pswTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var usernameHintLabel: UILabel!
    @IBOutlet weak var passwordHintLabel: UILabel!
    @IBOutlet weak var confirmPswHintLabel: UILabel!
    @IBOutlet weak var nameHintLabel: UILabel!
    @IBOutlet weak var signupLoadingIndicator: UIActivityIndicatorView!
    
    var availabilityChecked: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTF.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    

    @IBAction func pswEditChanged(_ sender: Any) {
        let inputPsw = pswTF.text! + ""
        let validated:Bool = ValidationUtils.validatePsw(psw: inputPsw)
        if  validated == false{
            passwordHintLabel.isHidden = false
            passwordHintLabel.text = "Password must be 8-24 characters, with at least one uppercase, lowercase and number, no symbol"
        }
        else{
            passwordHintLabel.isHidden = true
        }
        
        print("password validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func confirmEditChanged(_ sender: Any) {
        let psw = pswTF.text
        if !passwordHintLabel.isHidden{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "Enter validated password first"
        }
        else if confirmTF.text != psw{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "Must be the same as the password you entered above"
        }
        else{
            confirmPswHintLabel.isHidden = true
        }
    }
    
    @IBAction func usernameEditChanged(_ sender: Any) {
        self.availabilityChecked = false
        let inputUsername = usernameTF.text!
        let validated:Bool = ValidationUtils.validateUsername(username: inputUsername)
        if  validated == false{
            usernameHintLabel.isHidden = false
            usernameHintLabel.text = "Username must be 6-20 characters, with no symbol."
        }
        else{
            usernameHintLabel.isHidden = true
        }
        print("username validated, the result is: " + String(describing: validated))
    }

    @IBAction func fnameEditChanged(_ sender: Any) {
        let fnInput = firstNameTF.text
        let lnInput = lastNameTF.text
        
        let validated:Bool = ValidationUtils.nameValidate(name: fnInput!) && ValidationUtils.nameValidate(name: lnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Your name must be in validated format."
        }
        else{
            nameHintLabel.isHidden = true
        }
        print("name validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func lnameEditChanged(_ sender: Any) {
        let lnInput = lastNameTF.text
        let fnInput = firstNameTF.text
        
        let validated:Bool = ValidationUtils.nameValidate(name: fnInput!) && ValidationUtils.nameValidate(name: lnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Your name must be in validated format."
        }
        else{
            nameHintLabel.isHidden = true
        }
        print("name validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func SignUpButtonPressed(_ sender: Any) {
        if usernameHintLabel.isHidden && passwordHintLabel.isHidden && confirmPswHintLabel.isHidden &&
            nameHintLabel.isHidden{
            signUpButton.setTitle("", for: .normal)
            signupLoadingIndicator.startAnimating()
            signUpButton.isEnabled = false
            if availabilityChecked == false{

            }
            else{
                
            }
        }
    }
    
    @IBAction func checkAvailablityButtonPressed(_ sender: Any) {
        if usernameHintLabel.isHidden {
            checkUsernameAvailability(username: usernameTF.text)
        }
        else{
            let alert = UIAlertController(title: "Username Not Validated", message: "Please enter a validated username before checking.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    func checkUsernameAvailability(username: String!){
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkcarerid?carerId=" + username
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    let alert = UIAlertController(title: "Error", message: "There is an error when registering for you. Please try later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
                DispatchQueue.main.sync{
                    if "true" == responseString{
                        let alert = UIAlertController(title: "Username Already Exists", message: "Please use another username", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else{
                        self.availabilityChecked = true
                        let alert = UIAlertController(title: "Congrats", message: "This username is available, please continue signing up. ", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        task.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
