//
//  NetworkService.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//
import Foundation
import RxSwift
import RxAlamofire
import Alamofire

enum APIEndpoint: String {
    case createCustomer  = "/customers.json"
    case address = "/customers/{customer_id}/addresses.json"
    case editOrDeleteAddress = "/customers/{customer_id}/addresses/{address_id}.json"
    case brands = "/smart_collections.json"
    case products = "/products.json?collection_id={brand_id}"
    case CategoryAll = "/products.json"
    case CategoryMen = "/products.json?collection_id=330332438681"
    case CategoryWomen = "/products.json?collection_id=330332471449"
    case CategoryKids = "/products.json?collection_id=330332504217"
    case CategorySale = "/products.json?collection_id=330332536985"
    case getDraftOrder = "/draft_orders/{darft_order_id}.json"
    case createDraftOrder = "/draft_orders.json"
    case productVariant = "/variants/{variant_id}.json"
    case ordersByCustomer = "/orders.json?customer_id={customer_id}"
    case currencyRate = "?apikey={apikey}&currencies={currencies}&base_currency={base_currency}"
    case createOrder = "/orders.json"
    case validateDiscount = "/discount_codes/lookup.json?code={discount_code}"
    case priceRule = "/price_rules/{price_rule_id}.json"
    case allPriceRules = "/price_rules.json"
}

enum NetworkError: Error {
    case invalidStatusCode(message: String)
}

// Define a protocol for NetworkService
protocol NetworkServiceProtocol {
    func get<T: Decodable>(url : String? , endpoint: String,  parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<T>
    func post<T: Encodable, U: Decodable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?, responseType: U.Type) -> Observable<(Bool, String?, U?)>
    func delete(url: String, endpoint: String, parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<Int>
//    func put<T: Codable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?) -> Observable<(HTTPURLResponse, Data)>
    func put<T: Encodable, U: Decodable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?, responseType: U.Type) -> Observable<(Bool, String?, U?)>
    
}

class NetworkService: NetworkServiceProtocol {
 
    static let shared = NetworkService()
    
    private let disposeBag = DisposeBag()

    private init(){}
    // Helper function to create full URL and default headers
    private func createRequestDetails(url : String ,endpoint: String, headers: HTTPHeaders?) -> (String, HTTPHeaders) {
        let url = "\(url)\(endpoint)"
        print("url-------------: \(url)")
        var combinedHeaders = headers ?? HTTPHeaders()
       // combinedHeaders.add(name: "Authorization", value: NetworkConstants.apiKey)
        if headers == nil{
            combinedHeaders.add(name: "X-Shopify-Access-Token", value: Constant.adminApiAccessToken)
            combinedHeaders.add(name: "Content", value: "application/json")
        }
        return (url, combinedHeaders)
    }

    // Generic function to get data
    func get<T: Decodable>(url : String? = NetworkConstants.baseURL ,endpoint: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> Observable<T> {
        let (url, combinedHeaders) = createRequestDetails(url : url ?? "" ,endpoint: endpoint, headers: headers)
        return RxAlamofire
            .requestData(.get, url, parameters: parameters, encoding: URLEncoding.default, headers: combinedHeaders)
            .flatMap { response, data -> Observable<T> in
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    return Observable.just(decodedObject)
                } catch {
                    return Observable.error(error)
                }
            }
    }

    // Generic function to post data
    func post<T: Encodable, U: Decodable>(url: String = NetworkConstants.baseURL, endpoint: String, body: T, headers: HTTPHeaders? = nil, responseType: U.Type) -> Observable<(Bool, String?, U?)> {
        let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)
        print(completeURL)
        return RxAlamofire
            .requestDecodable(.post, completeURL, parameters: body.dictionary, encoding: JSONEncoding.default, headers: combinedHeaders)
            .flatMap { (response, value) -> Observable<(Bool, String?, U?)> in
                let statusCode = response.statusCode
                if (200...299).contains(statusCode) {
                    return Observable.just((true, "Succeeded with status code: \(statusCode)", value))
                } else {
                    return Observable.just((false, "Request failed with status code: \(statusCode)", nil))
                }
            }
            .catchError { error in
                Observable.just((false, "Request error: \(error.localizedDescription)", nil))
            }
    }


    //Generic function to delete data
    func delete(url: String = NetworkConstants.baseURL, endpoint: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> Observable<Int> {
        let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)

        return Observable.create { observer in
            let disposable = RxAlamofire.requestData(.delete, completeURL, parameters: parameters, encoding: URLEncoding.default, headers: combinedHeaders)
                .subscribe(onNext: { (response, _) in
                    observer.onNext(response.statusCode)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })

            return Disposables.create {
                disposable.dispose()
            }
        }
    }
    func put<T: Encodable, U: Decodable>(url: String = NetworkConstants.baseURL, endpoint: String, body: T, headers: HTTPHeaders? = nil, responseType: U.Type) -> Observable<(Bool, String?, U?)> {
        let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)
        print(completeURL)
        return RxAlamofire
            .requestDecodable(.put, completeURL, parameters: body.dictionary, encoding: JSONEncoding.default, headers: combinedHeaders)
            .flatMap { (response, value) -> Observable<(Bool, String?, U?)> in
                let statusCode = response.statusCode
                if (200...299).contains(statusCode) {
                    return Observable.just((true, "Succeeded with status code: \(statusCode)", value))
                } else {
                    return Observable.just((false, "Request failed with status code: \(statusCode)", nil))
                }
            }
            .catchError { error in
                Observable.just((false, "Request error: \(error.localizedDescription)", nil))
            }
    }

}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}


