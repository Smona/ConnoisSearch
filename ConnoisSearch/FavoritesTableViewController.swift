//
//  FavoritesTableViewController.swift
//  ConnoisSearch
//
//  Created by Bharucha, Het S on 4/30/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit
import Firebase

class FavoritesTableViewController: UITableViewController {
    
    @IBOutlet var favoritesTableView: UITableView!
    var favorites:Array<RecipeItem> = []
    var urlString = "https://spoonacular.com/recipeImages/"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add new cells for each favorite
        let favoritesRef = Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/favorites")
        favoritesRef.observe(.childAdded) { snapshot in
            self.addFavorite(snapshot.key)
        }
        favoritesRef.observe(.childRemoved) { snapshot in
            for var i in 0..<self.favorites.count {
                print(i)
                print(self.favorites[i])
                let recipe = self.favorites[i]
                if String(describing: recipe.recipeID) == snapshot.key {
                    self.favorites.remove(at: i)
                    let indexPath = IndexPath(row: i, section: 0)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.endUpdates()
                    return
                }
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        favoritesTableView.tableFooterView = UIView(frame: CGRect.zero) // hide extra table cells
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
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = favorites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as? recipeItemTableViewCell
        cell?.recipeTitle.text = item.recipeTitle
        
        if let prepTime = item.prepTime {
            cell?.prepTime.text = String(describing: prepTime) + "m"
        } else {
            cell?.prepTime.text = ""
        }
        
        let url = URL(string: item.imageURL!)
        let data = try? Data(contentsOf: url!)
        cell?.recipeImage.image = UIImage(data: data!)
        cell?.uid = item.recipeID
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight(for: indexPath)
    }
    
    private func rowHeight(for indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func addFavorite(_ uid: String) {
        RecipeViewController.fetchRecipe(uid + "/information?includeNutrition=false") { data in
            guard let id = data["id"] as? Int else {
                print("Error: Missing id in Recipe response")
                return
            }
            guard let title = data["recipe_title"] as? String else {
                print("Error: Missing recipe title")
                return
            }
            
            let newItem = RecipeItem(recipeID: id, recipeTitle: title, imageURL: data["image_url"] as? String, prepTime: data["cook_time"] as? Int)
            self.favorites.append(newItem)
            let indexPath = IndexPath(row: self.favorites.count - 1, section: 0)
            self.favoritesTableView.beginUpdates()
            self.favoritesTableView.insertRows(at: [indexPath], with: .automatic)
            self.favoritesTableView.endUpdates()
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let id = self.favorites[indexPath.row].recipeID
            Database.database().reference().child("/users/\(Auth.auth().currentUser!.uid)/favorites/\(id)").removeValue()
            self.favorites.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
        
        if segue.identifier == "showFavorite" {
            guard let cell = sender as? recipeItemTableViewCell else {
                print(sender!)
                return
            }
            let recipeView = segue.destination as! RecipeViewController
            recipeView.uid = cell.uid
        }
    }

}
