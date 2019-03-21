//
//  AppStoreItemController.swift
//  AppleSearch25
//
//  Created by Hannah Hoff on 3/21/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation

class AppStoreItemController {
    
    static let baseUrl = URL(string: "https://itunes.apple.com")
    
    static func fetchItemsOf(type: AppStoreItem.ItemType, searchTerm: String, completion: @escaping ([AppStoreItem]?) -> Void) {
        // 1. Construct the URL/URLRequest
        guard let baseUrl = baseUrl?.appendingPathComponent("search"),
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else { completion(nil); return}
        let querySearchTermItem = URLQueryItem(name: "term", value: searchTerm)
        let queryItemType = URLQueryItem(name: "entity", value: type.rawValue)
        components.queryItems = [querySearchTermItem, queryItemType]
        
        guard let finalUrl = components.url else { completion(nil); return }
        
        // 2. Call our dataTask (.resume())
        URLSession.shared.dataTask(with: finalUrl) { (data, _, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(nil)
                return
            }
            guard let data = data else { completion(nil); return}
            do {
               guard let outermostDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                let resultsArray = outermostDictionary["results"] as? [[String: Any]] else { completion(nil); return }
                
//                var appStoreItems: [AppStoreItem] = []
//                for dictionary in resultsArray {
//                    if let appStoreItem = AppStoreItem(itemType: type, dictionary: dictionary) {
//                        appStoreItems.append(appStoreItem)
//                    }
//                }
                // does the same as commented above ^
                let appStoreItems = resultsArray.compactMap{ AppStoreItem(itemType: type, dictionary: $0)}
                completion(appStoreItems)
            } catch {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(nil)
                return
            }
        }
    }
}
