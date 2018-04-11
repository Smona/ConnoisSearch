//
//  SignupViewController.swift
//  ConnoisSearch
//
//  Created by Mason Bourgeois on 4/9/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    
    @IBAction func signupBtnClick(_ sender: Any) {
      Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!)
      { (user, error) in
        if let error = error as NSError? {
          // Handle error
          let alertController = UIAlertController (
              title: "Signup Failed",
              message: "Make sure you entered a valid email",
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
          self.performSegue(withIdentifier: "signedUpSuccess", sender: sender)
        }
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
        ) -> Bool {
        
        if emailField.text!.count > 0 && passwordField.text!.count > 0 {
            signupBtn.isEnabled = true
        } else {
            signupBtn.isEnabled = false
        }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
