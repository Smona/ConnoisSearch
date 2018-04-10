//
//  LoginViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
    }

    //dismisses keyboard when Returned pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
        ) -> Bool {
        
        if emailField.text!.count > 0 && passwordField.text!.count > 0 {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
        
        return true
    }
    
    //dismisses keyboard when outside of keyboard/field pressed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginButtonClicked(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
            if let error = error as NSError? {
                let alertController = UIAlertController (
                    title: "Login Failed",
                    message: "An error occurred",
                    preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default) {
                        (action:UIAlertAction) in
                        print("OK button pressed");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "login", sender: sender)
            }
        }
        
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }

 /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginID" {
            print ("YAY")
        }
    }
 */
}
