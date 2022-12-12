 # RefManager （tentative）
REFManager is an iOS application for managing food like ingredients, beverages, dishes, sweets, etc. in refrigerator, which is configured by Swift and Firebase and Rakuten recepie API.
## About RefManager
You can manage food stylishly with following 5 feature.  
・Can preserve food classified by 2type of preserve location(Refrigerator/freezer),9 food type in total such as meat, seafood, seasoning and so forth, and selectable 5 kinds of quantity units.  
・Can understand where everything was by location button and food type buttons.  
・Easily can update name, quantity and location.  
・Can check recommended recipes on web site using food you chose.  
・Can delete several foods at once.
## Character
・Can control display contents by buttons placed on bottom of screen with one hand easily when you’re shopping or on your way home.  
・easily understandable cell provides how many is in which location from when.  
・display contents quickly by pagination even if lots of item has been preserved on cloud.
## Composition  
The App is managed with custom strcut “Food” and Cloud firestore. Composition of Food is as follows.  
```swift
struct Food: Equatable, Codable {
    var location: Location
    var kind: FoodKind
    var name: String
    var quantity: String
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date
    enum Location: String, CaseIterable, Codable {
        case refrigerator
        case freezer
    }
    enum FoodKind: String, CaseIterable, Codable {
        case meat
        case fish
        case vegetableAndFruit
        case milkAndEgg
        case dish
        case drink
        case seasoning
        case sweet
        case other
    }
}
```
It is composed by 8 properties, and location managing preserved location, kind managing food kinds and unit managing quantity unit of food are enum. It confirms Codable but not CodingKey.
Tree composition of Firestore is as follows.
<img width="500" alt="スクリーンショット 2022-12-12 13 21 39" src="https://user-images.githubusercontent.com/84781651/206960175-2393d5a3-a101-41e1-b6bb-30b3f8b20ce0.png">


## Installation

## Usage
<img src="https://user-images.githubusercontent.com/84781651/206842125-53fdc0ab-dbff-4bb1-8601-d78b61dc3181.png" width="25%">

## Todo
・Account and share function.  
・Preservation of several foods at once.  
・Keyword search.  
・notification/alert of expiry date.  
・release on appstore.  

