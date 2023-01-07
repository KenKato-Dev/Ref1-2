# 冷蔵庫くん 
 <img src="https://user-images.githubusercontent.com/84781651/210377761-d29f1662-e458-4f77-bc17-411c88b78933.png" width="100%">  
   
冷蔵庫くんは冷蔵庫内の食材や総菜、飲料、スイーツなどの食品を登録、追加や削除等修正、食品のレシピ検索が行えるiOSアプリです。SwiftとFirebaseにより構築されております。  
  
## 導入
1. 下記のコマンドを任意のディレクトリから実行してださい。  
```  
$ git clone https://github.com/KenKato-Dev/Ref1-2  

$ cd Refmanager1-2  
```  
2. 移動したディレクトリにあるRefManager1-2.xcodeprojを開いてください。
3. Xcodeからアプリを実行してください。(※GoogleService-Info.plist及びEnvironment.Swiftはプロジェクト内に含まれておりません。送付しますのでGit又はメール等でご連絡ください)
4. 画面下部の「アカウントをお持ちでない方はコチラ」をタップし、メールアドレス、ユーザー名、パスワードを入力し登録をしてください。(メールアドレスは＠と.comが入っていたら認識しますので動かすだけならテキトーで構いません)
5. 入力が完了すると登録された食材が表示されるtableViewを持つメイン画面に遷移されます、食材の追加、選択表示、修正、削除、レシピ検索、ユーザー登録情報の確認とログアウト等お試しください。
 

## 構成  

- MVP  
- Firesbase  
    - Auth  
    - FireStore  
        — scheme  
- API
    - Rakuten Recipe API  

MVP:  
設計パターンはMVPを採用しています．構成としては各画面にViewControllerとPresenter、複数画面向けにModelを用意し，それぞれ以下の役割としています。  
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
FirestoreはアプリのDB構成に使用しています。DBには下記のようなSchemeで登録された食品情報Foodと利用者情報Userを登録しています。
Users(コレクション)  
    — UserID(ドキュメント)  
    — User(フィールド)  
    — Foods(サブコレクション) — FoodID(ドキュメント) — Food各プロパティ(フィールド)  

Userは下記のようなSchemeです。    
userName: String  
email:String  
createdAt:Timestamp  

Foodは以下のようなSchemeです。  
location: Location(Enum)  
kind: FoodKind(Enum)  
name: String  
quantity: String  
unit: UnitSelectButton.UnitMenu(Enum)  
IDkey: String  
date: Date  
  
FoodsはUsersのサブコレクションとしており、ユーザー情報Userと登録された食材情報Foodを紐づけています。  
  
API:  
楽天レシピに登録されている料理のレシピ取得に楽天APIのRakuten Recipe APIを利用しています。リクエストしてレシピ集をData型にて受け取ります。  
APIのリクエストに必要なキーはEnvironment。swiftファイルにて管理しておりプロジェクトに同梱していません。  
  
## 概要  
以下5つの機能で食材を管理できます。  
- 食品を冷蔵/冷凍の2種の保管場所、肉や海鮮、調味料など計9種の種類分け、5種の数量単位にて保管可能  
- どこに何があるか保管場所と種類のボタンそれぞれもしくは両方組み合わせ把握可能  
- 食品の名称や量、保管場所を簡易に更新  
- 選択した食材のおすすめレシピ集(楽天レシピ)を表示、タップしブラウザ上でレシピ集を閲覧可能  
- 複数の食品をまとめて削除可能  
  
## 特徴  
- 買い物中や帰宅途中など知りたい場面でも片手で操作しやすくボタンを下部に集中配置  
- 何がいつからどれくらいあるのかを一目で把握できるセル内容  
- 多量に登録されている状態でもページネーションにより迅速に表示  
## 作成の中で工夫した点　　
Refmanager工夫した点　　
Firestoreからの配列の取り出しとソート、ページネーション　　
チェックボックスとデリートボタンの関連付け、enum State での管理　　
.env APIキーの隠匿管理　　
Firestoreのスキーマ構築　　

## 今後の方針  
- グループ間での共有機能
- 複数の食材を一度に保存
- 任意のキーワードで食材を検索
- 消費期限の通知やアラート表示
- AppStoreでのリリース
