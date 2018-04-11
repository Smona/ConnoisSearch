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
    
    var recipeInfo = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeInfo = SearchViewController().randomDict //copies dictionary from SearchVC
        print(recipeInfo)

        titleLabel.text = "meme" //TEMP; REPLACE WITH DICTIONARY'S "recipe title"
        timeLabel.text = String(5) + " min." //TEMP; REPLACE WITH DICTIONARY'S "cook time"
        servingsLabel.text = String(2) + " serving(s)" //TEMP; REPLACE WITH DICTIONARY'S "servings"
        instructionsLabel.text = "say cheese" //TEMP; REPLACE WITH DICTIONARY'S "instructions"
        
        let url = URL(string: "https://spoonacular.com/recipeImages/598880-556x370.jpg") //TEMP; REPLACE WITH DICTIONARY'S "image url"
        let data = try? Data(contentsOf: url!)
        image.image = UIImage(data: data!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
