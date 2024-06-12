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
    case getDraftOrder = "/draft_orders/{darft_order_id}.json"
    case productVariant = "/variants/{variant_id}.json"
}

// Define a protocol for NetworkService
protocol NetworkServiceProtocol {
    func get<T: Decodable>(url : String , endpoint: String,  parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<T>
    func post<T: Encodable, U: Decodable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?, responseType: U.Type) -> Observable<(Bool, String?, U?)>
    func delete(url: String, endpoint: String, parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<Int>
//    func put<T: Codable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?) -> Observable<(HTTPURLResponse, Data)>
    func put<T: Encodable, U: Decodable>(url: String, endpoint: String, body: T, headers: HTTPHeaders?, responseType: U.Type) -> Observable<(Bool, String?, U?)>
}

enum NetworkError: Error {
    case invalidStatusCode(message: String)
}

class NetworkService: NetworkServiceProtocol {
    private let disposeBag = DisposeBag()

    // Helper function to create full URL and default headers
    private func createRequestDetails(url : String ,endpoint: String, headers: HTTPHeaders?) -> (String, HTTPHeaders) {
        let url = "\(NetworkConstants.baseURL)\(endpoint)"
        var combinedHeaders = headers ?? HTTPHeaders()
       // combinedHeaders.add(name: "Authorization", value: NetworkConstants.apiKey)
        combinedHeaders.add(name: "X-Shopify-Access-Token", value: Constant.adminApiAccessToken)
        combinedHeaders.add(name: "Content", value: "application/json")
        return (url, combinedHeaders)
    }

    // Generic function to get data
    func get<T: Decodable>(url : String = NetworkConstants.baseURL ,endpoint: String, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> Observable<T> {
        let (url, combinedHeaders) = createRequestDetails(url : url ,endpoint: endpoint, headers: headers)

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
    //Generic function to put data
//    func put<T: Codable>(url: String = NetworkConstants.baseURL, endpoint: String, body: T, headers: HTTPHeaders? = nil) -> Observable<(HTTPURLResponse, Data)> {
//        let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)
//        print(completeURL)
//        do {
//            let jsonData = try JSONEncoder().encode(body)
//            return Observable.create { observer in
//                var request = URLRequest(url: URL(string: completeURL)!)
//                request.httpMethod = HTTPMethod.put.rawValue
//                request.headers = combinedHeaders
//                request.httpBody = jsonData
//
//                let disposable = RxAlamofire.request(request)
//                    .responseData()
//                    .subscribe(onNext: { (response, data) in
//                        observer.onNext((response , data))
//                        observer.onCompleted()
//                    }, onError: { error in
//                        observer.onError(error)
//                    })
//
//                return Disposables.create {
//                    disposable.dispose()
//                }
//            }
//        } catch {
//            return Observable.error(error)
//        }
//    }
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


