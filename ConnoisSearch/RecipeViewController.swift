//
//  RecipeViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
    
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
    
    var recipeDict = [String: Any]()
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = self.uid { // specific recipe
            
        } else {                // random recipe
            self.fetchRecipe("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?limitLicense=false&number=1")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayRecipe() {
        titleLabel.text =  recipeDict["recipe_title"] as? String
        titleLabel.sizeToFit()
        timeLabel.text = String((recipeDict["cook_time"] as? Int)!) + " min"
        timeLabel.sizeToFit()
        servingsLabel.text = String((recipeDict["servings"] as? Int)!) + " serving(s)"
        servingsLabel.sizeToFit()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
                    print(json.description)
                    let header = json["recipes"] as? [[String: Any]]
                    for item in header!{
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
                                ingredientArray.append(amount.description + " " + unit + " " + name)
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
                    }
                    print(self.recipeDict) //DICTIONARY WITH IMPORTANT JSON INFO
                    DispatchQueue.main.async {
                        self.displayRecipe()
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
