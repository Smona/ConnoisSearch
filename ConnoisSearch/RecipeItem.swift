//
//  RecipeItem.swift
//  ConnoisSearch
//
//  Created by Bharucha, Het S on 4/28/18.
//  Copyright © 2018 group13. All rights reserved.
//

import Foundation

class RecipeItem {
    
    let recipeID:Int?
    var imageURL:String?
    let recipeTitle:String?
    let prepTime:Int?
    
    init(recipeID:Int, imageURL:String, recipeTitle:String, prepTime:Int) {
        self.recipeID = recipeID
        self.imageURL = imageURL
        self.recipeTitle = recipeTitle
        self.prepTime = prepTime
    }
    
    class func create(_recipeID:Int, _imageURL:String, _recipeTitle:String, _prepTime:Int) -> RecipeItem {
        return RecipeItem(recipeID:_recipeID, imageURL:_imageURL, recipeTitle:_recipeTitle, prepTime:_prepTime)
    }
}
