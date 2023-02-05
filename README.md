# 冷蔵庫くん  
  <img src="https://user-images.githubusercontent.com/84781651/215305572-8003106c-fef5-4a22-b5de-273af037ed92.mov" width="18%"><img src="https://user-images.githubusercontent.com/84781651/215305015-438fca01-6f5c-4296-b33e-bcaef853afb2.png" width="80%">
  
冷蔵庫くんはSwiftとFirebaseにより構築されたiOSアプリです。冷蔵庫内の食品(食材、惣菜、飲料、調味料など)を登録し、クラウド上で数量確認、登録日確認、追加、削除、レシピの検索が行えます。 
アプリとしてリリースしました、以下よりお使いのiPhoneにダウンロードしご試用いただけます。
https://apps.apple.com/jp/app/%E5%86%B7%E8%94%B5%E5%BA%AB%E3%81%8F%E3%82%93/id1668522525
## 導入
1. 下記のコマンドを任意のディレクトリから実行してださい。  
```  
$ git clone https://github.com/KenKato-Dev/Ref1-2  
  
$ cd Refmanager1-2  
```  
2. 移動したディレクトリにあるRefmanager1-2.xcodeprojを開いてください。
3. Xcodeからアプリを実行してください。
4. セキュリティの観点からGoogleService-Info.plist及びEnvironment.Swiftはプロジェクト内に含まれておりません。  
   ご連絡に応じてこれら2ファイルを共有します、Enviromnet.Swiftをご自身で導入される際は以下ご参照ください。  
    - 楽天レシピAPIの楽天レシピカテゴリ一覧APIからリクエストURLを生成してください。  
    - 下記コマンドにてディレクトリ下に.envファイルを作成してください。  
    ```
       $ cd Refmanager1-2  
       $ vi .env  
    ```
    -  .envファイルに下記を挿入してください。
    ```
    rakutenAPIKey=生成した楽天レシピカテゴリ一覧APIのURL
    adUnitIDForList=ca-app-pub-3940256099942544/6300978111
    adUnitIDForSignIn=ca-app-pub-3940256099942544/6300978111
    ```
    -  APIキーをディクショナリにて追加するとビルド時にEnvironment.Swiftというファイルがディレクトリに自動生成されますのでプロジェクトに導入してください。 

5. 画面下部の「アカウントをお持ちでない方はコチラ」をタップし、メールアドレス、ユーザー名、パスワードを入力し登録をしてください。  
   もしくは「お試しで使ってみる」から登録なしでご利用いただけます。
6. 入力が完了すると登録された食材が表示されるtableViewを持つメイン画面に遷移されます、食材の追加、選択表示、修正、削除、レシピ検索、ユーザー登録情報の確認とログアウト等お試しください。  

## 構成/Composition  

- MVP  
- Firesbase  
    - Auth  
    - FireStore  
        - scheme  
- API
    - Rakuten Recipe API  

MVP:  
設計パターンはMVPを採用しています。構成としては各画面にViewControllerとPresenter、複数画面向けにModelを用意し、それぞれ以下の役割としています。  
- ViewContoller：ユーザーの操作等イベントをPresenterに渡し処理しPresenterから返ってきた内容を元にUIを描写  
- Presenter：ModelとViewControllerの仲介役としてViewから受け取ったイベントや必要に応じてModelへ処理を委譲し返ってきた内容を元に処理を実行、処理結果をViewへ変換  
- Model：Presenterからの異常など必要に応じてAPIへのリクエストやfetch、postを実行、UIや画面表示に依存せずロジックを一元管理  
  
MVPパターンの採用は、役割の明確化による保守のしやすさとテスト実装のしやすさ向上を期待して実装しています。  
  
Firebase:  
バックエンドの実装にはFirebaseを利用しており、具体的にはFirebaseはAuthとFirestoreを利用しています。  
実行に必要となるGoogleService-Info.plistはプロジェクトに同梱しておりません。

Auth:  
ユーザの認証に使用しています。ユーザは登録情報の保護や複数アカウントで管理したいニーズへの対応に加え将来的に実装したいグループ間での登録情報の共有に必要なため使用しています。  

Firestore:  
FirestoreはアプリのDB構成に使用しています。下記のようなSchemeで登録された食品情報Foodと利用者情報Userを登録しています。  


Users(コレクション)  
    — UserID(ドキュメント:ユーザーID)  
    — User(フィールド: 利用者情報)  
    — Foods(サブコレクション) — FoodID(ドキュメント) — Food(フィールド: 食品情報)  

- User(フィールド: 利用者情報)      
    - userName: String  
    - email:String  
    - createdAt:Timestamp  

- Food(フィールド: 食品情報)    
    - location: Location(Enum)  
    - kind: FoodKind(Enum)  
    - name: String  
    - quantity: String  
    - unit: UnitSelectButton.UnitMenu(Enum)  
    - IDkey: String  
    - date: Date  
  
FoodsはUsersのサブコレクションとしており、ユーザー情報Userと登録された食材情報Foodを紐づけています。

  
API:  
楽天レシピに登録されている料理のレシピ取得に楽天APIのRakuten Recipe APIを利用しています。リクエストしてレシピ集をData型にて受け取ります。  
APIのリクエストに必要なキーはEnvironment.Swiftファイルにて管理しておりプロジェクトに同梱していません。  
またGoogle AdMobを導入し試験的に広告を表示しております。こちらもリクエストに必要なキーはEnviroment.Swiftファイルにて管理しておりますのでプロジェクトに同梱しておりません。
  
## 概要
以下5つの機能で食材を管理できます。  
- 食品を冷蔵/冷凍の2種の保管場所、肉や海鮮、調味料など計9種の種類分け、5種の数量単位にて保管可能  
- どこに何があるかを保管場所と種類のボタンそれぞれもしくは両方組み合わせて表示  
- 食品の名称や量、保管場所を簡易に更新  
- 選択した食材のおすすめレシピ集(楽天レシピ)を表示、タップしブラウザ上でレシピ集を閲覧可能  
- 複数の食品をまとめて削除可能   
  
## 工夫した点
フィルタリング制御と情報のリアルタイム表示：
保管場所(冷蔵/冷凍/の3つ)と複数選択可能な食品の種類(計9つ)が組み合わったフィルターとなります。
UI操作に合わせてこのフィルター制御を行い知りたい情報を食品の種類と登録日時に並べ替えた状態でFirestoreへリクエストしてTableViewに配列を表示します。
情報の探しやすさや見やすさ向上に加え、将来的にグループシェア機能をつけた際にグループ間での表示情報の誤差を最小限にすることに繋がると考えております。

```swift
if filterRef || filterFreezer, !kinds.isEmpty {
            query = db.collection("Users").document(uid).collection("foods")
                .whereField(fieldElementLocation, isEqualTo: location)
                .whereField(fieldElementKind, in: kindArray)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else if filterRef || filterFreezer, kinds.isEmpty {
            query = db.collection("Users").document(uid).collection("foods")
                .whereField(fieldElementLocation, isEqualTo: location)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else if !filterRef, !filterFreezer, !kinds.isEmpty {

            query = db.collection("Users").document(uid).collection("foods")
                .whereField(fieldElementKind, in: kindArray)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else {
            query = Firestore.firestore().collection("Users").document(uid).collection("foods")
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        }

```
ページネーション機能：
元々はアプリ起動時にFirestoreから情報を全て取り出していましたが登録情報を増やすにつれて少しずつ画面が表示される時間が長くなりました。
このページネーションを実装したことでアプリ起動時や画面遷移時の待機時間減少を期待して期待しております。

```swift
    func paginate() {
        guard let nextDocument = queryDocumentSnaphots.last else { return }
        query = query.start(afterDocument: nextDocument).limit(to: 10)
    }
```

FoodListCell内のcheckBoxButtonの記述改善：
FoodListCellはFoodListTableViewに表示するCellを担当し、Cellは普段は隠蔽され情報削除時に現れタップされると見た目が変わるCheckBoxButtonを持っています。
元々はCellの状態をViewControllerで判断しそれを元にFuncを呼び出して処理しCheckBoxButtonの見た目を変えていました。
しかしViewController全体と当該関係箇所が見にくく、期待する表示通りの制御ができない場合が発生していました。
これらを下記Enum Stateにより一元化することによりViewControllerの見やすさ改善と期待通りの制御が行えるようになりました。
DeleteButtonをタップし、どれを削除するか選択するためのFoodListCell内のcheckBoxButtonの状態を下記Enumにて状態を管理しています。

```swift
enum State {
        case normal //CheckBoxButton隠蔽状態
        case shownCheckBox(isChecked: Bool) //CheckBoxButton出現、Bool値により外観が変化
    }
```

  
## 今後の方針  
- グループ間での共有機能
- 複数の食材を一度に保存
- 任意のキーワードで食材を検索
- 消費期限の通知やアラート表示
