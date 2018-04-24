//
//  SearchViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    var randomDict = [String: Any]()
    //PROBLEM: when called in RecipeVC, an empty randomDict is passed, without the info appended from apiConnection()
    //SOLUTION: pass from apiConnection()? Code order problem? randomDict being deleted for some reason when RecipeVC calls it?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var randomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
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

    @IBAction func randomClicked(_ sender: Any) {
        apiConnection()
        randomButton.setTitle("Loading...", for: UIControlState.normal)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchID" {
            print("YAY1")
        }
        else if segue.identifier == "showRandom" {
            if let destinationVC = segue.destination as? RecipeViewController {
                destinationVC.recipeInfo = self.randomDict
            }
        }
    }
    
    func apiConnection() {
        if let url = NSURL(string:"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?limitLicense=false&number=1") {
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
                    //print(json.description)
                    let header = json["recipes"] as? [[String: Any]]
                    for item in header!{
                        if let title = item["title"] as? String{
                            self.randomDict["recipe_title"] = title
                        }
                        if let image = item["image"] as? String{
                            self.randomDict["image_url"] = image
                        }
                        if let glutenFree = item["glutenFree"] as? Int{
                            self.randomDict["gluten_free"] = glutenFree
                        }
                        if let dairyFree = item["dairyFree"] as? Int{
                            self.randomDict["dairy_free"] = dairyFree
                        }
                        if let vegan = item["vegan"] as? Int{
                            self.randomDict["vegan"] = vegan
                        }
                        if let vegetarian = item["vegetarian"] as? Int{
                            self.randomDict["vegetarian"] = vegetarian
                        }
                        if let cookTime = item["readyInMinutes"] as? Int{
                            self.randomDict["cook_time"] = cookTime
                        }
                        if let instructions = item["instructions"] as? String{
                            self.randomDict["instructions"] = instructions
                        }
                        if let ingredients = item["extendedIngredients"] as? [[String: Any]]{
                            var ingredientArray = [String]()
                            for i in ingredients{
                                ingredientArray.append(i["originalString"] as! String)
                            }
                            self.randomDict["ingredients"] = ingredientArray
                        }
                        //TO CHECK AND SEE IF INFORMATION GRABBED CORRECTLY:
                        if let recipeURL = item["spoonacularSourceUrl"] as? String{
                            self.randomDict["source url"] = recipeURL
                        }
                        
                        if let servings = item["servings"] as? Int{
                            self.randomDict["servings"] = servings
                        }
                    }
                    print(self.randomDict) //DICTIONARY WITH IMPORTANT JSON INFO
                    DispatchQueue.main.async {
                        self.randomButton.setTitle("Random Recipe", for: UIControlState.normal)
                        self.performSegue(withIdentifier: "showRandom", sender: self)
                    }
                } catch {
                    print("error trying to convert data to JSON")
                    return
                }
                }
            task.resume()
        }

    }
}

