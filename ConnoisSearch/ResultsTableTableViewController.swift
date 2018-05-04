//
//  ResultsTableTableViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class ResultsTableTableViewController: UITableViewController {

    @IBOutlet weak var noneFoundLabel: UILabel!
    @IBOutlet var resultsTableView: UITableView!
    var searchResults:Array<RecipeItem> = []
    var urlString = "https://spoonacular.com/recipeImages/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Results"
        resultsTableView.tableFooterView = UIView(frame: CGRect.zero) // hide extra table cells
        if searchResults.count > 0 {
            noneFoundLabel.frame.size.height = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? recipeItemTableViewCell
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
                print("recipe cell segue")
                if let item = sender as? recipeItemTableViewCell {
                    destinationVC.uid = item.uid
                }
            }
        }
    }
}
