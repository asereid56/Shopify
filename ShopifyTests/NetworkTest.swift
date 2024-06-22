//
//  ShopifyTests.swift
//  ShopifyTests
//
//  Created by Aser Eid on 02/06/2024.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Shopify

final class NetworkTest: XCTestCase {
    
    var network : NetworkServiceProtocol?
    var disposeBag : DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        network = NetworkService.shared
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        super.tearDown()
        
        network = nil
        disposeBag = nil
    }
    
    func testGet() {
        
        let expectation = expectation(description: "Wait for brands")
        network?.get(url: NetworkConstants.baseURL, endpoint: APIEndpoint.brands.rawValue, parameters: nil, headers: nil).subscribe(onNext: { (data : BrandsResponse) in
            
            XCTAssertEqual(data.smartCollections.count, 12)
            expectation.fulfill()
            
        },onError: { error in
            
            XCTFail("Error occured: \(error.localizedDescription)")
            expectation.fulfill()
            
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10)
    }
    
    

    
    func testPut() {
        let expectation = expectation(description: "wait to update adddress")
        
        let address = Address(address1: "5758 B, Street")
        let addressRequest = AddressRequestRoot(address: address)
        let endPoint = APIEndpoint.editOrDeleteAddress.rawValue.replacingOccurrences(of: "{customer_id}", with:  "7484133802137").replacingOccurrences(of: "{address_id}", with: "8878822686873")
        
        network?.put(url: NetworkConstants.baseURL, endpoint: endPoint, body: addressRequest, headers: nil, responseType: AddressResponseRoot.self)
            .subscribe(onNext: { success , msg , response in
                
                XCTAssertTrue(success)
                XCTAssertEqual(response?.customer_address.address1, "5758 B, Street")
                expectation.fulfill()
                
            },onError: { error in
                
                XCTFail("Error occurred: \(error.localizedDescription)")
                expectation.fulfill()
                
            }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10)
    }
    
    
    func testDelete() {
        let expectation = expectation(description: "wait to delete draft order")
        
        let linItems = LineItem(title: "DummyProduct", price: "0.0", quantity: 1)
        let draftOrder = DraftOrder(lineItems: [linItems])
        let draftOrderWrapper = DraftOrderWrapper(draftOrder: draftOrder)
        let endPoint = APIEndpoint.createDraftOrder.rawValue
        
        network?.post(url: NetworkConstants.baseURL, endpoint: endPoint, body: draftOrderWrapper, headers: nil, responseType: DraftOrderWrapper.self)
            .subscribe(onNext: { success , msg , response in
                deleteDraftOrder(draftOrderID : String((response?.draftOrder?.id)!))
            }).disposed(by: disposeBag)
        
        func deleteDraftOrder(draftOrderID : String) {
            let deleteDraftOrderEndpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderID)
            network?.delete(url: NetworkConstants.baseURL, endpoint: deleteDraftOrderEndpoint, parameters: nil, headers: nil)
                .subscribe(onNext: { statusCode in
                    XCTAssertEqual(statusCode, 200)
                    expectation.fulfill()
                },onError: { error in
                    XCTFail("Error occurred: \(error.localizedDescription)")
                    expectation.fulfill()
                    
                }).disposed(by: disposeBag)
        }
        
        waitForExpectations(timeout: 10)
    }
    
    
    
    
}
