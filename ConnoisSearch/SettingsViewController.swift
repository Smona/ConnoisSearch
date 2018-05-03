//
//  SettingsViewController.swift
//  ConnoisSearch
//
//  Created by Mason Bourgeois on 4/29/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    @IBOutlet weak var dairySwitch: UISwitch! //fb: dairy
    @IBOutlet weak var glutenSwitch: UISwitch! //fb: gluten
    @IBOutlet weak var peanutSwitch: UISwitch!  //fb: peanut
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let handle = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/dietary preference").observe(.value, with: { (snapshot) in
            let dietBool = snapshot.value as! String
            if dietBool == "none"{
                self.segmentedControl.selectedSegmentIndex = 0
            }
            if dietBool == "vegetarian"{
                self.segmentedControl.selectedSegmentIndex = 1
            }
            if dietBool == "vegan"{
                self.segmentedControl.selectedSegmentIndex = 2
            }
            
        })
        
        let handle2 = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/allergies").observe(.value, with: { (snapshot) in
            let userDict = snapshot.value as! [String: Any]

            let dairyBool = userDict["dairy"] as! Bool
            if dairyBool == true{
                self.dairySwitch.setOn(true, animated: true)
            }
            
            let glutenBool = userDict["gluten"] as! Bool
            if glutenBool == true{
                self.glutenSwitch.setOn(true, animated: true)
            }
            
            let peanutBool = userDict["peanut"] as! Bool
            if peanutBool == true{
                self.peanutSwitch.setOn(true, animated: true)
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func dietaryChange(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            //NONE
            Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/dietary preference").setValue("none")
        case 1:
            //VEG
            Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/dietary preference").setValue("vegetarian")
        case 2:
            //VEGAN
            Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/dietary preference").setValue("vegan")
        default: break;
        }
    }
    
    @IBAction func dairyToggle(_ sender: Any) {
        let ref = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/allergies/dairy")
        if dairySwitch.isOn == true{
            ref.setValue(true)
        }
        if dairySwitch.isOn == false{
            ref.setValue(false)
        }
    }
    @IBAction func glutenToggle(_ sender: Any) {
        let ref = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/allergies/gluten")
        if glutenSwitch.isOn == true{
            ref.setValue(true)
        }
        if glutenSwitch.isOn == false{
            ref.setValue(false)
        }
    }
    
    @IBAction func peanutToggle(_ sender: Any) {
        let ref = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/allergies/peanut")
        if peanutSwitch.isOn == true{
            ref.setValue(true)
        }
        if peanutSwitch.isOn == false{
            ref.setValue(false)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "logout" {
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error)
            }
        }
    }
}
