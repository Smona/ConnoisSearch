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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
