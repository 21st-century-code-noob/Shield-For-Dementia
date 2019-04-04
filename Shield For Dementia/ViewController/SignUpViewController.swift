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
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTF.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    


    @IBAction func usernameEditChanged(_ sender: Any) {
        let inputUsername = usernameTF.text! + ""
        let validated:Bool = ValidationUtils.validateUsername(username: inputUsername)
        if  validated == false{
            usernameHintLabel.isHidden = false
            usernameHintLabel.text = "7-20 characters, no symbols"
        }
        print("username validated, the result is: " + String(describing: validated))
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
