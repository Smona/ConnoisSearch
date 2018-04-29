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
    
    var recipeInfo = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text =  recipeInfo["recipe_title"] as? String
        print(titleLabel.text)
        titleLabel.sizeToFit()
        timeLabel.text = String((recipeInfo["cook_time"] as? Int)!) + " min"
        timeLabel.sizeToFit()
        servingsLabel.text = String((recipeInfo["servings"] as? Int)!) + " serving(s)"
        servingsLabel.sizeToFit()
        instructionsLabel.text = (recipeInfo["instructions"] as? String)!
        instructionsLabel.sizeToFit()
        
        let ingredients = recipeInfo["ingredients"] as! [String]
        ingredientsLabel.text = ingredients.joined(separator: "\n")
        ingredientsLabel.sizeToFit()
        
        let url = URL(string: (recipeInfo["image_url"] as? String)!)
        let data = try? Data(contentsOf: url!)
        image.image = UIImage(data: data!)

        recipeContainer.sizeToFit()
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
