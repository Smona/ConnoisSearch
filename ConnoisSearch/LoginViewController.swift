//
//  LoginViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set("bharuchahet", forKey: "Email")
        UserDefaults.standard.set("cricket7", forKey: "Password")
        UserDefaults.standard.synchronize()
        
        if let email = UserDefaults.standard.string(forKey: "Email") {
            print(email)
        }
        if let password = UserDefaults.standard.string(forKey: "Password") {
            print(password)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginID" {
            if emailField.text != UserDefaults.standard.string(forKey: "Email") || passwordField.text != UserDefaults.standard.string(forKey: "Password") {
                let alertController = UIAlertController (
                    title: "Login Failed",
                    message: "The username and password you have entered is incorrect.",
                    preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default) {
                        (action:UIAlertAction) in
                        print("OK button pressed");
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true, completion: nil)
                print("false")
                return false
            }
        }
        print("true")
        return true
    }

 /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginID" {
            print ("YAY")
        }
    }
 */
}
