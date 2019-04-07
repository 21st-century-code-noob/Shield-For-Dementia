//
//  CarerPanelViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class CarerPanelViewController: UIViewController {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var pairedPatientLabel: UILabel!
    @IBOutlet weak var remindButton: UIButton!
    @IBOutlet weak var memoryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
        if UserDefaults.standard.object(forKey: "firstName") == nil{
            retriveFname()
        }
        setWelcomeLabel()
        checkPairedPatient()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Log Out", style: .default, handler: { (action) -> Void in
            // Present dialog message to user
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "patientId")
            UserDefaults.standard.removeObject(forKey: "firstName")
            self.performSegue(withIdentifier: "logoutUnwindSegue", sender: self)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setWelcomeLabel(){
        var lastName = ""
        if UserDefaults.standard.value(forKey: "firstName") != nil{
            lastName = UserDefaults.standard.value(forKey: "firstName") as! String
        }
        greetingLabel.text = "Good " + getTimeOfTheDay() + ", " + lastName
    }
    
    func retriveFname(){
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkcarerid?carerId=" + username
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    
                }
            }
            else{
                var firstName: String = ""
                let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
                DispatchQueue.main.sync{
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            if let carer1 = json![0] as? [String: Any]{
                                firstName = (carer1["first_name"] as? String)!
                                UserDefaults.standard.set(firstName, forKey: "firstName")
                                self.greetingLabel.text = "Good " + self.getTimeOfTheDay() + ", " + firstName
                            }
                        }
                        catch {
                            print(error)
                        }
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkPairedPatient(){
        let username = UserDefaults.standard.object(forKey: "username") as! String
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkwhethercarerhaspatient?carerId=" + username
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                }
                else{
                    let dataString = String(data: data!, encoding: String.Encoding.utf8)
                    DispatchQueue.main.sync{
                        if dataString != "[]"{
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                                var hasPatient:Bool = false
                                for item in json!{
                                    if let pair = item as? [String: Any]{
                                        if pair["status"] as! Int == 1{
                                            let patientId = pair["user_id"] as! String
                                            self.enableButtonBecauseHasPatient()
                                            UserDefaults.standard.set(patientId, forKey: "patientId")
                                            self.pairedPatientLabel.text = "You have been paired with: " + patientId
                                            hasPatient = true
                                        }
                                    }
                                }
                                if hasPatient == false{
                                    UserDefaults.standard.removeObject(forKey: "patientId")
                                    self.disableButtonsBecauseNoPatient()
                                    self.pairedPatientLabel.text = "You have no paired patient. Please pair with a patient to use functions."
                                }
                            }
                            catch{
                                print(error)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        
    }

    func getTimeOfTheDay() -> String{
        let dateComponents = Calendar.current.dateComponents([.hour], from: Date())
        var timeOfDay: String = ""
        if let hour = dateComponents.hour {
            switch hour {
            case 0..<12:
                timeOfDay = "Morning"
            case 12..<17:
                timeOfDay = "Afternoon"
            default:
                timeOfDay = "Night"
            }
        }
        return timeOfDay
    }
    
    func disableButtonsBecauseNoPatient(){
        remindButton.isEnabled = false
        memoryButton.isEnabled = false
    }
    
    func enableButtonBecauseHasPatient(){
        remindButton.isEnabled = true
        memoryButton.isEnabled = true
    }
    

    
    
}
