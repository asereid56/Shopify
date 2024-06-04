//
//  NetworkService.swift
//  Shopify
//
//  Created by Apple on 03/06/2024.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

struct NetworkConstants {
    static let apiKey = "ff8515d9c1ce9b93b6be04426b3572d6"
    static let shopifyBaseURL = "https://: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@mad44-sv-iost2.myshopify.com/admin/api/2024-04"
}

enum APIEndpoint: String {
    case getCollections = "/custom_collections.json"
    case customerAddress = "/customers/{customer_id}/addresses.json"
}


protocol NetworkServiceProtocol {
    func request<T: Decodable>(url : String ,endpoint: String, method: HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<T>
    func post<T: Codable>(url : String ,endpoint: String, body: T, headers: HTTPHeaders?) -> Observable<Int>
}

class NetworkService: NetworkServiceProtocol {
    private let disposeBag = DisposeBag()

    private func createRequestDetails(url : String , endpoint: String, headers: HTTPHeaders?) -> (String, HTTPHeaders) {
        let url = "\(url)\(endpoint)"
        var combinedHeaders = headers ?? ["Content-Type": "application/json"]
        combinedHeaders.add(name: "Authorization", value: NetworkConstants.apiKey)
        return (url, combinedHeaders)
    }

    // Generic function to make network requests
    func request<T: Decodable>(url : String ,endpoint: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> Observable<T> {
       let (url, combinedHeaders) = createRequestDetails(url : url ,endpoint: endpoint, headers: headers)
        return RxAlamofire
            .requestData(method, url, parameters: parameters, encoding: URLEncoding.default, headers: combinedHeaders)
            .flatMap { response, data -> Observable<T> in
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    return Observable.just(decodedObject)
                } catch {
                    return Observable.error(error)
                }
            }
    }

    func post<T: Codable>(url: String, endpoint: String, body: T, headers: HTTPHeaders? = nil) -> Observable<Int> {
           let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)
           
           do {
               let jsonData = try JSONEncoder().encode(body)
               return Observable.create { observer in
                   var request = URLRequest(url: URL(string: completeURL)!)
                   request.httpMethod = HTTPMethod.post.rawValue
                   request.headers = combinedHeaders
                   request.httpBody = jsonData
                   
                   let disposable = RxAlamofire.request(request)
                       .responseData()
                       .subscribe(onNext: { (response, _) in
                           print("Enter0")
                           observer.onNext(response.statusCode)
                           observer.onCompleted()
                       }, onError: { error in
                           observer.onError(error)
                       })
                   
                   return Disposables.create {
                       disposable.dispose()
                   }
               }
           } catch {
               return Observable.error(error)
           }
       }
}


