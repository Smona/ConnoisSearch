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
    
    var favoritesDict = [String]()
    var recipeDict = [String: Any]()
    var favoritesResults:Array<RecipeItem> = []
    var urlString = "https://spoonacular.com/recipeImages/"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
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
        
        let handle3 = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/favorites").observe(.value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
                for i in userDict{
                    self.favoritesDict.append(i.key)
                }
            }
        })
    }
    
    func fetchRecipe(_ query: String) {
        if let url = NSURL(string: query) {
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
                    var item: [String: Any];
                    if let header = json["recipes"] as? [[String: Any]] { // response with a list of recipes
                        item = header[0]; // just display the first one
                    } else { // single recipe
                        item = json;
                    }
                    
                    if let id = item["id"] as? Int {
                        self.recipeDict["id"] = id
                    }
                    if let title = item["title"] as? String{
                        self.recipeDict["recipe_title"] = title
                    }
                    if let image = item["image"] as? String{
                        self.recipeDict["image_url"] = image
                    }
                    if let glutenFree = item["glutenFree"] as? Int{
                        self.recipeDict["gluten_free"] = glutenFree
                    }
                    if let dairyFree = item["dairyFree"] as? Int{
                        self.recipeDict["dairy_free"] = dairyFree
                    }
                    if let vegan = item["vegan"] as? Int{
                        self.recipeDict["vegan"] = vegan
                    }
                    if let vegetarian = item["vegetarian"] as? Int{
                        self.recipeDict["vegetarian"] = vegetarian
                    }
                    if let cookTime = item["readyInMinutes"] as? Int{
                        self.recipeDict["cook_time"] = cookTime
                    }
                    if let instructions = item["instructions"] as? String{
                        self.recipeDict["instructions"] = instructions
                    }
                    if let ingredients = item["extendedIngredients"] as? [[String: Any]]{
                        var ingredientArray = [String]()
                        for i in ingredients{
                            let amount = i["amount"] as! NSNumber
                            let unit = i["unit"] as! String
                            let name = i["name"] as! String
                            ingredientArray.append(String(describing: amount) + " " + unit + " " + name)
                        }
                        self.recipeDict["ingredients"] = ingredientArray
                    }
                    //TO CHECK AND SEE IF INFORMATION GRABBED CORRECTLY:
                    if let recipeURL = item["spoonacularSourceUrl"] as? String{
                        self.recipeDict["source url"] = recipeURL
                    }
                    
                    if let servings = item["servings"] as? Int{
                        self.recipeDict["servings"] = servings
                    }
                    print(self.recipeDict)
                    let recipeItem = RecipeItem.create(_recipeID: self.recipeDict["id"] as! Int, _imageURL: self.recipeDict["image_url"] as! String, _recipeTitle: self.recipeDict["recipe_title"] as! String, _prepTime: self.recipeDict["cook_time"] as! Int)
                    
                    self.favoritesResults.append(recipeItem)
                    DispatchQueue.main.async {
                        self.favoriteButton.setTitle("Favorites", for: UIControlState.normal)
                        self.performSegue(withIdentifier: "favoriteSegue", sender: self)
                    }
                } catch {
                    print("error trying to convert data to JSON")
                    return
                }
            }
            task.resume()
        }
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
        searchButton.setTitle("Loading...", for: UIControlState.normal)
    }
    @IBAction func favoritesClicked(_ sender: Any) {
        for item in favoritesDict {
            fetchRecipe("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/" + item + "/information?includeNutrition=false")
        }
        favoriteButton.setTitle("Loading", for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchID" {
            if let destinationVC = segue.destination as? ResultsTableTableViewController {
                destinationVC.searchResults = self.results
            }
        }
        if segue.identifier == "favoriteSegue" {
            if let destinationVC = segue.destination as? FavoritesTableViewController {
                destinationVC.favoritesResults = self.results
            }
        }
    }
    
    func searchAPI() {
        if let url = NSURL(string:"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?\(self.diet)instructionsRequired=true&\(self.allergies)limitLicense=false&number=5&offset=0&query=" + searchTextField.text!) {
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
                    print(json.description)
                    let header = json["results"] as? [[String: Any]]
                    for item in header! {
                        let recipeItem = RecipeItem.create(_recipeID: item["id"] as! Int, _imageURL: item["image"] as! String, _recipeTitle: item["title"] as! String, _prepTime: item["readyInMinutes"] as! Int)
                        self.results.append(recipeItem)
                    }
                    print(self.results)
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

