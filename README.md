# 冷蔵庫くん/RefManager  
 <img src="https://user-images.githubusercontent.com/84781651/206842125-53fdc0ab-dbff-4bb1-8601-d78b61dc3181.png" width="25%">
  
冷蔵庫くんは冷蔵庫内の食材や総菜、飲料、スイーツなどの食品をクラウド上で管理するiOSアプリです。SwiftとFirebaseにより構築されております。  
  
REFManager is an iOS application for managing food like ingredients, beverages, dishes, sweets, etc. in refrigerator on cloud(firestore), which is configured by Swift, Firebase and Rakuten recepie API.
## 概要/About RefManager  
以下5つの機能で食材を管理できます。  
・食品を冷蔵/冷凍の2種の保管場所、肉や海鮮、調味料など計9種の種類分け、5種の数量単位にて保管可能  
・どこに何があるか保管場所と種類のボタンそれぞれもしくは両方組み合わせ把握可能  
・食品の名称や量、保管場所を簡易に更新  
・選択した食材のおすすめレシピ集(楽天レシピ)を表示、タップしブラウザ上でレシピ集を閲覧可能  
・複数の食品をまとめて削除可能  
  
You can manage food stylishly with following 5 features.  
・Can preserve food classified by 2 types of preserve location(Refrigerator/freezer),9 food types in total such as meat, seafood, seasoning and so forth, and selectable 5 kinds of quantity units.  
・Can find where everything was by tapping location button and food type buttons.  
・Easily can update name, quantity and location.  
・Can check recommended recipes on web site using food you chose.  
・Can delete several foods at once.
## 特徴/Character  
・買い物中や帰宅途中など知りたい場面でも片手で操作しやすくボタンを下部に集中配置  
・何がいつからどれくらいあるのかを一目で把握できるセル内容  
・多量に登録されている状態でもページネーションにより迅速に表示  
  
・Can control display contents by buttons placed on bottom of screen with one hand easily when you’re shopping or on your way home.  
・easily understandable cell provides how many is in which location from when.  
・display contents smoothly by pagination even if lots of item has been preserved on cloud.
## 構成/Composition  
本アプリはMVPアーキテクチャを採用しております。構造体Food型をFirebaseのCloud firestoreにて管理しており、Food型は下記の構成となります。  
  
Architecture of the App. is MVP. It is managed with custom strcut “Food” and Cloud firestore. Composition of Food is as follows.  

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
        
        var kindNumber: String {
            switch self {
            case .meat:
                return "1"
            case .fish:
                return "2"
            case .vegetableAndFruit:
                return "3"
            case .milkAndEgg:
                return "4"
            case .dish:
                return "5"
            case .drink:
                return "6"
            case .seasoning:
                return "7"
            case .sweet:
                return "8"
            case .other:
                return "9"
            }
        }
    }
}
```
8つのプロパティで構成されており、保管場所を管理するlocationと種類を管理するkind、数量の単位を管理するunitはEnumとなっています。　　
Firestoreの構成は下記の通りです。  
  
It is composed by 8 properties, and "location" managing preserved location, "kind" managing food kinds and "unit" managing quantity unit of food are enum.   
Tree composition of Firestore is as follows.
<img width="1200" alt="スクリーンショット 2022-12-12 13 21 39" src="https://user-images.githubusercontent.com/84781651/206960175-2393d5a3-a101-41e1-b6bb-30b3f8b20ce0.png">
一層目コレクション"foods"を基に、Food構造体を二層目ドキュメントにUUIDにて保管し、名称や量などの具体的な情報は三層目の各fieldに保管されています。  
Based on an initial layer "collection" named "foods", Food struct items are stored in second layer "document" with UUID. concrete information like name or quantity is stored in each field of third layer.  
  
## 導入/Installation
googleservice-info.plistが必要となりますのFirebaseから本ファイルをダウンロードし本アプリのプロジェクトファイルに追加してください。  
googleservice-info.plist is neccesary for using this app. Please get it from Firebase account and add it to the app. project file.  
  
## 今後の方針/To do next  
・アカウントとグループ間での共有機能
・複数の食材を一度に保存
・任意のキーワードで食材を検索
・消費期限の通知やアラート表示
・AppStoreでのリリース  

・Account and share function.  
・Preservation of several foods at once.  
・Keyword search.  
・notification/alert of expiry date.  
・release on appstore.  

