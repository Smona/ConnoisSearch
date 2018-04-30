//
//  SearchViewController.swift
//  ConnoisSearch
//
//  Created by Het Bharucha on 3/24/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    var results:Array<RecipeItem> = []
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
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
    
    @IBAction func searchClicked(_ sender: Any) {
        searchAPI()
        searchButton.setTitle("Loading...", for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchID" {
            if let destinationVC = segue.destination as? ResultsTableTableViewController {
                destinationVC.searchResults = self.results
            }
        }
    }
    
    func searchAPI() {
        if let url = NSURL(string:"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?instructionsRequired=true&limitLicense=false&number=10&offset=0&query=" + searchTextField.text! + "&type=main+course") {
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

