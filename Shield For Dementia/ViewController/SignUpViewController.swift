//
//  SignInViewController.swift
//  Shield For Dementia
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    
    
    /*@IBAction func SignUpButtonPressed(_ sender: Any) {
        CBToast.showToastAction()
        if !availabilityChecked{
            CBToast.hiddenToastAction()
            displayAlert(title: "Username Availability Not Checked", message: "Please check username availability before signing up.")
        }
        else if usernameHintLabel.isHidden && passwordHintLabel.isHidden && confirmPswHintLabel.isHidden &&
            nameHintLabel.isHidden{
            signUpButton.setTitle("", for: .normal)
            signupLoadingIndicator.startAnimating()
            signUpButton.isEnabled = false
            
            let username = usernameTF.text!
            let passwordHash = SHA1.hexString(from: pswTF.text!)
            let firstName = firstNameTF.text!
            let lastName = lastNameTF.text!
            
            var requestURL3 = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/addaewcarer?carerId="
            requestURL3 = requestURL3 + username
            requestURL3 = requestURL3 + "&password="
            requestURL3 = requestURL3 + passwordHash! + "&firstName=" + firstName + "&lastName=" + lastName
            
            let url = URL(string: requestURL3)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                let dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.displayAlert(title: "Error", message: "An error occured, please try later.")
                    }
                }
                else if "\"success!\"" != dataString{
                    DispatchQueue.main.sync{
                        print(dataString)
                        CBToast.hiddenToastAction()
                        self.displayAlert(title: "Sign Up Failed", message: "Please check your input")
                    }
                }
                else{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        CBToast.showToast(message: "Account successfully created.", aLocationStr: "center", aShowTime: 5.0)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            task.resume()
        }
        else{
            CBToast.hiddenToastAction()
            displayAlert(title: "Information Not Correct", message: "Please provide all information in correct format to sign up.")
        }
        
        
    }


    //button action handling
    @IBAction func checkAvailablityButtonPressed(_ sender: Any) {
        if usernameHintLabel.isHidden {
            checkUsernameAvailability(username: usernameTF.text)
        }
        else{
            self.displayAlert(title: "Username Not Valid", message: "Please enter a valid username before checking.")
        }
    }
    
    //using API checking username availability
    func checkUsernameAvailability(username: String!){
        checkAvailabilityButton.isHidden = true
        checkAvailabilityIndicator.startAnimating()
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkcarerid?carerId=" + username
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    self.checkAvailabilityButton.isHidden = false
                    self.checkAvailabilityIndicator.stopAnimating()
                    CBToast.showToast(message: "An error has occured", aLocationStr: "top", aShowTime: 2.0)
                }
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
                DispatchQueue.main.sync{
                    if "[]" != responseString{
                        CBToast.showToast(message: "The username already exists", aLocationStr: "top", aShowTime: 2.0)
                    }
                    else{
                        self.availabilityChecked = true
                        CBToast.showToast(message: "This username is available", aLocationStr: "top", aShowTime: 2.0)
                    }
                    self.checkAvailabilityButton.isHidden = false
                    self.checkAvailabilityIndicator.stopAnimating()
                }
            }
        }
        task.resume()
    }
    */
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
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

