//
//  RecepieCategory.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/09/30.
//

import Foundation
import SwiftUI
// 楽天APIからレシピ集を取り出す際使用する構造体
struct Small: Codable {
    let categoryName: String
    let parentCategoryId: String
    let categoryId: Int
    var categoryUrl: String
}
// RecepieCategoryのModel、楽天APIへのリクエスト処理
class RecepieModel {
    // 楽天APIへのリクエスト処理
    func fetch(_ keyword: String, _ completion: @escaping (Result<[Small], Error>) -> Void) {
        guard let url = URL(string:
            "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId=1050766026714426702"
        ) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    print("URL取得に失敗:\(error)")
                }
                let decoder = JSONDecoder()
                do {
                    var array: [Small] = []
                    // 全体をDictionaryに変換
                    // オフラインの際ここでエラー発生、エラーハンドリング
                    guard let data = data else {
                        return
                    }
                    let recepieData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    // 全体からKeyで内部をDictionaryにて取り出し
                    let result = recepieData?["result"] as? [String: Any]
                    // dataからsmallに変換
                    let small = result?["small"] as? [[String: Any]]
                    guard let small = small else {return}
                    let smallData = try JSONSerialization.data(withJSONObject: small, options: .prettyPrinted)
                    let decodedSmall = try decoder.decode([Small].self, from: smallData)
                    array.append(contentsOf: decodedSmall)
                    // 食材名を含むものを配列から取り出す、今回は鶏肉
                    let filteredSmall = array.filter { $0.categoryName.contains(keyword) }
                    DispatchQueue.main.async {
                        completion(.success(filteredSmall))
                    }
                } catch {
                    print("デコードに失敗:\(error)")
                }
            }
            task.resume()
        }
    }
}
