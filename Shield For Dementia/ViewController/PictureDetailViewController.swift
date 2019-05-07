//
//  PictureDetailViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import Firebase

class PictureDetailViewController: UIViewController {
    
    var image: UIImage?
    var imageName: String?
    var imageUrl: String?
    var imageMessage: String?
    
    let username = UserDefaults.standard.object(forKey: "patientId") as! String
    var databaseRef = Database.database().reference().child("users")
    var storageRef = Storage.storage()
    
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func deleteMemory(_ sender: Any) {
        CBToast.showToastAction()
        databaseRef.child(username).child("images").child(imageName!).removeValue()
        databaseRef.child(username).child("imageMessages").child(imageName!).removeValue()
        let storageRef1 = storageRef.reference(forURL: imageUrl!)
        
        //Removes image from storage
        storageRef1.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                CBToast.hiddenToastAction()
                self.displayMessage("Image has been deleted", "Success")
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageDetail.image = image
        if(imageMessage == ""){
            messageLabel.text = "This picture does not have a message."
        }
        else{
            messageLabel.text = "Behind the picture: " + imageMessage!
        }
       
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

