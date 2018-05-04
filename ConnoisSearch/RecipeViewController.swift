//
//  RecipeViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class RecipeViewController: UIViewController {
    static let emptyFaveBtn = UIImage(named: "favorite_button@3x.png")
    static let filledFaveBtn = UIImage(named: "favorite_button_fill@3x.png")
    
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var recipeScroll: UIScrollView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var recipeContainer: UIView!
    @IBOutlet weak var loadingView: UILabel!
    @IBOutlet weak var recipeView: UIScrollView!
    
    var isFavorite = false;
    var recipeDict = [String: Any]()
    var uid: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var query: String
        if let uid = self.uid { // specific recipe
            query = uid.description + "/information?includeNutrition=false"
        } else {                // random recipe
            query = "random?limitLicense=false&number=1"
            let userHandle = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)")
            userHandle.child("/dietary preference").observe(.value, with: { (snapshot) in
                if let dietBool = snapshot.value as? String {
                    if dietBool == "none"{
                        query = "random?limitLicense=false&number=1"
                    }
                    if dietBool == "vegetarian"{
                        query = "random?limitLicense=false&number=1&tags=vegetarian"
                    }
                    if dietBool == "vegan"{
                        query = "random?limitLicense=false&number=1&tags=vegan"
                    }
                }
                print(query)
            })
        }

        RecipeViewController.fetchRecipe(query) { data in
            self.recipeDict = data
            if let uid = data["id"] as? Int {
                self.uid = uid
            }
            // Check if a favorite
            let favesRef = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/favorites")
            favesRef.observe(.childAdded) { snapshot in
                print(snapshot.key)
                print(String(describing: self.uid!))
                if snapshot.key == String(describing: self.uid!) {
                    self.isFavorite = true
                    self.setFavoriteBtnImg(self.isFavorite)
                }
            }
            favesRef.observe(.childRemoved) { snapshot in
                if snapshot.key == String(describing: self.uid!) {
                    self.isFavorite = false
                    self.setFavoriteBtnImg(self.isFavorite)
                }
            }
            
            self.displayRecipe()
            return
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayRecipe() {
        titleLabel.text =  recipeDict["recipe_title"] as? String
        if let cookTime = recipeDict["cook_time"] as? Int {
            timeLabel.text = String(cookTime) + " min"
        } else {
            timeLabel.text = " "
        }
        if let servings = recipeDict["servings"] as? Int {
            servingsLabel.text = String(servings) + (servings == 1 ? " serving" : " servings")
        } else {
            servingsLabel.text = " "
        }
        instructionsLabel.text = (recipeDict["instructions"] as? String)!
        instructionsLabel.sizeToFit()
        
        let ingredients = recipeDict["ingredients"] as! [String]
        ingredientsLabel.text = ingredients.joined(separator: "\n")
        ingredientsLabel.sizeToFit()
        
        let url = URL(string: (recipeDict["image_url"] as? String)!)
        let data = try? Data(contentsOf: url!)
        image.image = UIImage(data: data!)
        
        recipeContainer.sizeToFit()
        loadingView.isHidden = true
        recipeView.isHidden = false
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        let ref = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/favorites/\(uid!)")
        if isFavorite {
            ref.removeValue()
        } else {
            ref.setValue(true)
        }


    }
    
    func setFavoriteBtnImg(_ active: Bool) {
        let image = (active ? RecipeViewController.filledFaveBtn : RecipeViewController.emptyFaveBtn)
        favoriteBtn.setImage(image, for: .normal)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    static func fetchRecipe(_ query: String, callback: @escaping (_ data: [String: Any]) -> Void)  {
        var recipeDict: [String: Any] = [:]
        
        if let url = NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/" + query) {
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
                        recipeDict["id"] = id
                    }
                    if let title = item["title"] as? String{
                        recipeDict["recipe_title"] = title
                    }
                    if let image = item["image"] as? String{
                        recipeDict["image_url"] = image
                    }
                    if let glutenFree = item["glutenFree"] as? Int{
                        recipeDict["gluten_free"] = glutenFree
                    }
                    if let dairyFree = item["dairyFree"] as? Int{
                        recipeDict["dairy_free"] = dairyFree
                    }
                    if let vegan = item["vegan"] as? Int{
                        recipeDict["vegan"] = vegan
                    }
                    if let vegetarian = item["vegetarian"] as? Int{
                        recipeDict["vegetarian"] = vegetarian
                    }
                    if let cookTime = item["preparationMinutes"] as? Int{
                        recipeDict["cook_time"] = cookTime
                    }
                    if let instructions = item["instructions"] as? String{
                        recipeDict["instructions"] = instructions
                    }
                    if let ingredients = item["extendedIngredients"] as? [[String: Any]]{
                        var ingredientArray = [String]()
                        for i in ingredients{
                            let amount = i["amount"] as! NSNumber
                            let unit = i["unit"] as! String
                            let name = i["name"] as! String
                            ingredientArray.append("• " + String(describing: amount) + " " + unit + " " + name)
                        }
                        recipeDict["ingredients"] = ingredientArray
                    }
                    //TO CHECK AND SEE IF INFORMATION GRABBED CORRECTLY:
                    if let recipeURL = item["spoonacularSourceUrl"] as? String{
                        recipeDict["source url"] = recipeURL
                    }
                    
                    if let servings = item["servings"] as? Int{
                        recipeDict["servings"] = servings
                    }
                    
                    DispatchQueue.main.async {
                        callback(recipeDict)
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
