//
//  RecepieCategory.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/09/30.
//

import Foundation
struct MediumAndSmall: Codable {
    let categoryName: String
    let parentCategoryId: String
    let categoryId: Int
    var categoryUrl: String
}
class RecepieModel {
    func fetchCategory(keyword: String, _ completion:@escaping(Result<[MediumAndSmall], Error>) -> Void) {
        // smallだけを返すURLを楽天で生成
        guard let url = URL(string:
                            "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId=1050766026714426702"

        ) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("URL取得に失敗:\(error)")
                    completion(.failure(error))
                }
                let decoder = JSONDecoder()
                do {
//                    var mediumArray:[MediumAndSmall]=[]
                    var array: [MediumAndSmall]=[]
                    // 全体をDictionaryに変換
                    let recepieData = try JSONSerialization.jsonObject(with: data!)as? [String: Any]
                    // 全体からKeyで内部をDictionaryにて取り出し
                    let result = recepieData?["result"] as? [String: Any]
                    // dataからmediumに変換
                    let medium = result?["medium"] as? [[String: Any]]
                    let mediumData = try JSONSerialization.data(withJSONObject: medium!, options: .prettyPrinted)
                    let decodedmedium = try decoder.decode([MediumAndSmall].self, from: mediumData)
                    array.append(contentsOf: decodedmedium)
                    // dataからsmallに変換
                    let small = result?["small"] as? [[String: Any]]
                    let smallData = try JSONSerialization.data(withJSONObject: small!, options: .prettyPrinted)
                    let decodedSmall = try decoder.decode([MediumAndSmall].self, from: smallData)
                    array.append(contentsOf: decodedSmall)
                    // 食材名を含むものを配列から取り出す、今回は鶏肉
                    var filteredSmall = array.filter { $0.categoryName.contains(keyword)}
                    completion(.success(filteredSmall))
                } catch {
                    print("デコードに失敗:\(error)")
                }
            }
            task.resume()
    }
    }
}
