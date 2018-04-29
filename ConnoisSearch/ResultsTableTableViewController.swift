//
//  ResultsTableTableViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class ResultsTableTableViewController: UITableViewController {

    var searchResults:Array<RecipeItem> = []
    var urlString = "https://spoonacular.com/recipeImages/"
    var cellDict = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Results"
        print("Now in TableView")
        print(searchResults)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? recipeItemTableViewCell
        cell?.recipeTitle.text = item.recipeTitle
        cell?.prepTime.text = "Ready in " + String(describing: item.prepTime ?? 0) + " minutes!"
        item.imageURL = urlString + item.imageURL!
        let url = URL(string: item.imageURL!)
        let data = try? Data(contentsOf: url!)
        cell?.recipeImage.image = UIImage(data: data!)
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight(for: indexPath)
    }
    
    private func rowHeight(for indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func getAPI(id:Int?) {
        if let url = NSURL(string:"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/" + String(describing: id ?? 0 ) + "/information?includeNutrition=false") {
            print(url)
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
                    if let title = json["title"] as? String{
                        self.cellDict["recipe_title"] = title
                    }
                    if let image = json["image"] as? String{
                        self.cellDict["image_url"] = image
                    }
                    if let glutenFree = json["glutenFree"] as? Int{
                        self.cellDict["gluten_free"] = glutenFree
                    }
                    if let dairyFree = json["dairyFree"] as? Int{
                        self.cellDict["dairy_free"] = dairyFree
                    }
                    if let vegan = json["vegan"] as? Int{
                        self.cellDict["vegan"] = vegan
                    }
                    if let vegetarian = json["vegetarian"] as? Int{
                        self.cellDict["vegetarian"] = vegetarian
                    }
                    if let cookTime = json["readyInMinutes"] as? Int{
                        self.cellDict["cook_time"] = cookTime
                    }
                    if let instructions = json["instructions"] as? String{
                        self.cellDict["instructions"] = instructions
                    }
                    if let ingredients = json["extendedIngredients"] as? [[String: Any]]{
                        var ingredientArray = [String]()
                        for i in ingredients{
                            ingredientArray.append(i["originalString"] as! String)
                        }
                        self.cellDict["ingredients"] = ingredientArray
                    }
                        //TO CHECK AND SEE IF INFORMATION GRABBED CORRECTLY:
                    if let recipeURL = json["spoonacularSourceUrl"] as? String{
                        self.cellDict["source url"] = recipeURL
                    }
                        
                    if let servings = json["servings"] as? Int{
                        self.cellDict["servings"] = servings
                    }
                    print(self.cellDict) //DICTIONARY WITH IMPORTANT JSON INFO
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "cellSegue", sender: self)
                    }
                } catch {
                    print("error trying to convert data to JSON")
                    return
                }
            }
            task.resume()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getAPI(id: searchResults[indexPath.row].recipeID)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            if let destinationVC = segue.destination as? RecipeViewController {
                destinationVC.recipeInfo = self.cellDict
            }
        }
    }


}
