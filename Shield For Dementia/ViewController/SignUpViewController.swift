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
            passwordHintLabel.text = "6-24 characters, contains uppercase, lowercase and digit"
        }
        else{
            passwordHintLabel.isHidden = true
        }
        
        print("password validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func confirmEditChanged(_ sender: Any) {
        let psw = pswTF.text
        if psw == ""{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "Input password first"
        }
        else if confirmTF.text != psw{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "confirm password doesn't match"
        }
        else{
            confirmPswHintLabel.isHidden = true
        }
    }
    
    @IBAction func usernameEditChanged(_ sender: Any) {
        let inputUsername = usernameTF.text!
        let validated:Bool = ValidationUtils.validateUsername(username: inputUsername)
        if  validated == false{
            usernameHintLabel.isHidden = false
            usernameHintLabel.text = "username must be 7-20 characters, no symbols"
        }
        else{
            usernameHintLabel.isHidden = true
        }
        print("username validated, the result is: " + String(describing: validated))
    }

    @IBAction func fnameEditChanged(_ sender: Any) {
        let fnInput = firstNameTF.text
        let validated:Bool = ValidationUtils.nameValidate(name: fnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Enter a validated name"
        }
        else{
            nameHintLabel.isHidden = true
        }
        print("name validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func lnameEditChanged(_ sender: Any) {
        let lnInput = lastNameTF.text
        let validated:Bool = ValidationUtils.nameValidate(name: lnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Enter a validated name"
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
        }
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
