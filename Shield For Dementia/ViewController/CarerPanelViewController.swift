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

        setWelcomeLabel()

        // Do any additional setup after loading the view.
    }
    
    override func  viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        disableButtonsBecauseNoPatient()
        checkPairedPatient()
    }
    
    //handle log out button behaviour
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
    
    //set welcome label
    func setWelcomeLabel(){
        var lastName = ""
        if UserDefaults.standard.value(forKey: "firstName") != nil{
            lastName = UserDefaults.standard.value(forKey: "firstName") as! String
        }
        greetingLabel.text = "Good " + getTimeOfTheDay() + ", " + lastName
    }
    
    //retrieve first name from api
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
                                let ids = carer1["ids"] as? Int
                                UserDefaults.standard.set(ids, forKey: "ids")
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
    
    //check paired patient using API
    func checkPairedPatient(){
        let username = UserDefaults.standard.object(forKey: "username") as! String
        var hasPatient:Bool = false
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
                                for item in json!{
                                    if let pair = item as? [String: Any]{
                                        if pair["status"] as! Int == 1{
                                            let patientId = pair["user_id"] as! String
                                            let requestId = pair["request_id"] as! Int
                                            self.enableButtonBecauseHasPatient()
                                            UserDefaults.standard.set(patientId, forKey: "patientId")
                                            UserDefaults.standard.set(requestId, forKey: "requestId")
                                            self.pairedPatientLabel.text = "You have been paired with: " + patientId
                                            hasPatient = true
                                        }
                                    }
                                }
                                if !hasPatient{
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
    
    //fake method used for now to pair patient and carer
    func fakeCheckPairedPatient(){
        let username = UserDefaults.standard.object(forKey: "username") as! String
        let ids = ((UserDefaults.standard.value(forKey: "carerIDS") as? Int)!)
        var hasPatient:Bool = false
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/fake/searchpatientbycarerids?carerIDS=" + String(ids)
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
                                let user = json![0] as! [String: Any]
                                let patientId = user["user_id"] as! String
                                UserDefaults.standard.set(patientId, forKey: "patientId")
                                self.pairedPatientLabel.text = "You have been paired with: " + patientId
                                hasPatient = true
                                self.enableButtonBecauseHasPatient()
                            }
                            catch{
                                print(error)
                            }
                        }
                        if !hasPatient{
                            UserDefaults.standard.removeObject(forKey: "patientId")
                            self.disableButtonsBecauseNoPatient()
                            self.pairedPatientLabel.text = "You have no paired patient. Please pair with a patient to use functions."
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
    
    //disable the buttons to avoid crash
    func disableButtonsBecauseNoPatient(){
        remindButton.isEnabled = false
        memoryButton.isEnabled = false
    }
    
    func enableButtonBecauseHasPatient(){
        remindButton.isEnabled = true
        memoryButton.isEnabled = true
    }
    
    @IBAction func pairingButtonPressed(_ sender: Any) {
        CBToast.showToastAction()
        let username = UserDefaults.standard.object(forKey: "username") as? String
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkwhethercarerhaspatient?carerId=" + username!
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
                                for item in json!{
                                    if let pair = item as? [String: Any]{
                                        if pair["status"] is NSNull{
                                            var status:[String] = [String]()
                                            status.append(pair["user_id"] as! String)
                                            status.append("0")
                                            CBToast.hiddenToastAction()
                                            self.performSegue(withIdentifier: "pairedSegue", sender: status)
                                        }
                                        else if pair["status"] as! Int != 0{
                                            var status:[String] = [String]()
                                            status.append(pair["user_id"] as! String)
                                            status.append(String(pair["status"] as! Int))
                                            CBToast.hiddenToastAction()
                                            self.performSegue(withIdentifier: "pairedSegue", sender: status)
                                        }
                                    }
                                }
                            }
                        
                            catch{
                                print(error)
                            }
                        }
                        else {
                            CBToast.hiddenToastAction()
                            self.performSegue(withIdentifier: "pairingSegue", sender: self)
                        }
                    }
                }
            }
            task.resume()
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pairedSegue"{
            if let vc = segue.destination as? PairedViewController, let status = sender as? [String] {
                vc.status = status
            }
        }
    }
    
    @IBAction func unwindToCarePanel(segue:UIStoryboardSegue) { }
    
    
}
