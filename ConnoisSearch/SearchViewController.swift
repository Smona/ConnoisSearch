//
//  SearchViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITextFieldDelegate {
    var results:Array<RecipeItem> = []
    var diet:String = ""
    var allergies:String = ""
    
    var favoritesResults:Array<RecipeItem> = []
    var urlString = "https://spoonacular.com/recipeImages/"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        
        let userHandle = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)")
        userHandle.child("/dietary preference").observe(.value, with: { (snapshot) in
            if let dietBool = snapshot.value as? String {
                if dietBool == "none"{
                    self.diet = ""
                }
                if dietBool == "vegetarian"{
                    self.diet = "diet=vegetarian&"
                }
                if dietBool == "vegan"{
                    self.diet = "diet=vegan&"
                }
            }
        })
        
        userHandle.child("allergies").observe(.value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
                let dairyBool = userDict["dairy"] as! Bool
                if dairyBool == true{
                    self.allergies = "intolerances=dairy&"
                }
                
                let glutenBool = userDict["gluten"] as! Bool
                if glutenBool == true{
                    self.allergies = "intolerances=gluten&"
                }
                
                let peanutBool = userDict["peanut"] as! Bool
                if peanutBool == true{
                    self.allergies = "intolerances=peanut&"
                }
                if dairyBool == true && glutenBool == true{
                    self.allergies = "intolerances=dairy%2C+gluten&"
                }
                if dairyBool == true && peanutBool == true{
                    self.allergies = "intolerances=dairy%2C+peanut&"
                }
                if glutenBool == true && peanutBool == true{
                    self.allergies = "intolerances=gluten%2C+peanut&"
                }
                if glutenBool == true && peanutBool == true && dairyBool == true{
                    self.allergies = "intolerances=gluten%2C+peanut%2C+dairy&"
                }
            }
        })
        
        
    }
    
    //dismisses keyboard when Returned pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
    
    @IBAction func searchClicked(_ sender: Any) {
        searchAPI()
        searchButton.setTitle("Finding Recipes...", for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchID" {
            if let destinationVC = segue.destination as? ResultsTableTableViewController {
                destinationVC.searchResults = self.results
                self.results = []
            }
        }
    }
    
    func searchAPI() {
        if let url = NSURL(string:"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?\(self.diet)instructionsRequired=true&\(self.allergies)limitLicense=false&number=10&offset=0&query=" + searchTextField.text!) {
            let request = NSMutableURLRequest(url:url as URL)
            request.httpMethod = "GET"
            request.addValue("P94NjqGeAkmshBXL0yGbztKyClfLp1JXYgUjsnvPETR0q1LSkb", forHTTPHeaderField: "X-Mashape-Key")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("data is empty")
                    return
                }
                do {
                    guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any/*Object*/] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    
                    let header = json["results"] as? [[String: Any]]
                    for item in header! {
                        let recipeItem = RecipeItem.create(_recipeID: item["id"] as! Int, _imageURL: item["image"] as! String, _recipeTitle: item["title"] as! String, _prepTime: item["readyInMinutes"] as! Int)
                        self.results.append(recipeItem)
                    }
                    
                    DispatchQueue.main.async {
                        self.searchButton.setTitle("Search", for: UIControlState.normal)
                        self.performSegue(withIdentifier: "searchID", sender: self)
                    }
                }
                catch {
                    print("error trying to convert data to JSON")
                    return
                }
            }
            task.resume()
        }
    }
}

