//
//  DataLoader.swift
//  Shopify
//
//  Created by Apple on 08/06/2024.
//

import Foundation
import RxSwift

class DataLoader {
    func loadCountries() -> Observable<CountryList> {
        return Observable.create { observer in
            if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let countries = try JSONDecoder().decode(CountryList.self, from: data)
                    observer.onNext(countries)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            } else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found"]))
            }
            return Disposables.create()
        }
    }
}

