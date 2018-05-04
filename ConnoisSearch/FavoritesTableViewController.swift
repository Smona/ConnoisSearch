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
        cell?.prepTime.text = String(describing: item.prepTime ?? 0) + "m"
        item.imageURL = urlString + item.imageURL!
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
            print(data)
            guard let id = data["id"] as? Int else {
                print("Error: Missing id in Recipe response")
                return
            }
            guard let imgUrl = data["image_url"] as? String else {
                print("Error: Missing recipe image url")
                return
            }
            guard let title = data["recipe_title"] as? String else {
                print("Error: Missing recipe title")
                return
            }
            guard let time = data["cook_time"] as? Int else {
                print("Error: Mising recipe prep time")
                return
            }
            
            self.favorites.append(RecipeItem(recipeID: id, imageURL: imgUrl, recipeTitle: title, prepTime: time))
            let indexPath = IndexPath(row: self.favorites.count - 1, section: 0)
            self.favoritesTableView.beginUpdates()
            self.favoritesTableView.insertRows(at: [indexPath], with: .automatic)
            self.favoritesTableView.endUpdates()
        }
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
