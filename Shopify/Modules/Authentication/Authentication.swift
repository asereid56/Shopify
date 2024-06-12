//
//  Authentication.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import UIKit
import RxSwift
import RxAlamofire
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore
import FirebaseFirestoreSwift

class AuthenticationManager {
    static func signIn(email: String, password: String, vc: UIViewController , mainCoordinator : MainCoordinator) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .userDisabled:
                    print("user disabled")
                case .invalidEmail:
                    showAlert(vc: vc, title: "Invalid Email Format", message: "Enter a valid email")
                case .accountExistsWithDifferentCredential:
                    showAlert(vc: vc, title: "Wrong Password", message: "Check your password and try again")
                case .invalidCredential:
                    showAlert(vc: vc, title: "Invalid Credentials", message: "Check your email and password and try again")
                case .wrongPassword:
                    showAlert(vc: vc, title: "Empty Fields", message: "Please fill in email and password fields")
                default:
                    print("Error: \(error)")
                }
            } else {
                fetchUserDocumentFromFirebase(firebaseId: authResult!.user.uid){ customerId in
                    getCustomerDraftOrdersIds(customerId: customerId) { ids in
                        let idsArray = ids.components(separatedBy: ", ")
                        print("from sign in after fetching draft orders ids \(idsArray)")
                        getCustomerFirstAndLastName(customerId: customerId) { firstName, lastName in
                            saveUserInfoToUserDefaults(customerId: customerId, ordersId: idsArray[0],
                                                       wishListId: idsArray[1], firstName: firstName, lastName: lastName)
                        }
                    }
                }
                mainCoordinator.gotoTab()
                showWelcomeAlert(vc: vc)
                
            }
        }
    }
    static func signUp(firstname: String, lastName: String, email: String, password: String, vc: UIViewController) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .userDisabled:
                    print("user disabled")
                case .weakPassword:
                    showAlert(vc: vc, title: "Weak Password", message: "Your password must be at least 6 characters")
                case .invalidEmail:
                    showAlert(vc: vc, title: "Invalid Email Format", message: "Enter a valid email")
                case .emailAlreadyInUse:
                    showAlert(vc: vc, title: "Registered Email", message: "The email address is already in use by another account.")
                case .missingEmail:
                    showAlert(vc: vc, title: "Empty Email Field", message: "An email address must be provided")
                    
                default:
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signs up successfully")
                setupCustomer(firstName: firstname, lastName: lastName, email: email)
                
                
                
            }
        }
    }
    
    static func signInWithGoogle(vc: UIViewController, completion: @escaping (Bool) -> Void){
        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
            let user = signInResult?.user
            guard let idToken = user?.idToken else {
                print("AUTHENTICATION ERROR")
                return
            }
            let accessToken = user?.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken!.tokenString)
            Auth.auth().signIn(with: credential){ _, error in
                print("firstName: \(user!.profile!.givenName!), lastName: \(user!.profile!.familyName!), email: \(user!.profile!.email)")
                setupCustomer(firstName: user!.profile!.givenName!, lastName: user!.profile!.familyName!, email: user!.profile!.email)
                completion(true)
            }
        }
    }
    
    static func showWelcomeAlert(vc: UIViewController){
        print("show welcome alert")
        if let currentUser = Auth.auth().currentUser {
            print("user here")
            let alert = UIAlertController(title: nil, message: "Welcome back \(currentUser.email ?? "")", preferredStyle: .actionSheet)
            vc.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true)
            }
        }
        else {
            print("no user")
            let alert = UIAlertController(title: nil, message: "Please log in to make use of all features", preferredStyle: .actionSheet)
            vc.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true)
            }
        }
    }
    static func showAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        vc.present(alert, animated: true)
        
    }
    static func isUserLoggedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}



func setupCustomer(firstName: String, lastName: String, email: String) {
    
    let network = NetworkService.shared
    let customer = Customer(firstName: firstName, lastName: lastName, email: email)
    let customerResponse = CustomerResponse(customer: customer)
    let endpoint = APIEndpoint.createCustomer.rawValue
    _ = network.post(endpoint: endpoint, body: customerResponse, responseType: CustomerResponse.self)
        .subscribe(onNext: { success, message, response in
            if success {
                print("Request succeeded: \(message ?? "")")
                
                if let response = response {
                    let customer_id = String(response.customer!.id!)
                    print("Response: \(response.customer?.id ?? 0000)")
                    createUserDocumentOverFirebase(firebaseId: Auth.auth().currentUser!.uid, APIId: customer_id, email: email) {
                        createTwoDraftOrders(email: email) { ids in
                            attachIdsToCustomer(ids, customer_id, network)
                            saveUserInfoToUserDefaults(customerId: customer_id, ordersId: String(ids[0]), wishListId: String(ids[1]), firstName: firstName, lastName: lastName)
                        }
                    }
                }
            } else {
                print("Request failed: \(message ?? "")")
            }
        }, onError: { error in
            print("Request error: (error)")
        })
}


func createUserDocumentOverFirebase(firebaseId: String, APIId: String, email: String, completion: @escaping () -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(firebaseId)
    
    let userData: [String: Any] = [
        "firebaseId": firebaseId,
        "APIId": APIId,
        "email": email
    ]
    
    userRef.setData(userData) { error in
        if let error = error {
            print("Error adding document: \(error)")
        } else {
            print("Document added with ID: \(firebaseId)")
            completion()
        }
    }
}
func fetchUserDocumentFromFirebase(firebaseId: String, completion: @escaping (String) -> ()) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(firebaseId)
    
    userRef.getDocument { document, error in
        if let document = document, document.exists {
            guard let data = document.data() else { return }
            guard let customerId = data["APIId"] else { return }
            print("User API Id fetched from Firestore: \(customerId)")
            completion(customerId as! String)
        } else {
            print("Document does not exist")
        }
    }
}
func createTwoDraftOrders(email: String, completion: @escaping ([Int]) -> Void) {
    var draftOrdersIds = [Int]()
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    createDraftOrder(name: "orders", email: email) { id in
        draftOrdersIds.append(id)
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    createDraftOrder(name: "wishlist", email: email) { id in
        draftOrdersIds.append(id)
        dispatchGroup.leave()
    }
    
    dispatchGroup.notify(queue: .main) {
        completion(draftOrdersIds)
    }
}

func createDraftOrder(name: String, email: String, completion: @escaping (Int) -> Void) {
    let network = NetworkService.shared
    let endpoint = APIEndpoint.createDraftOrder.rawValue
    let lineItem = LineItem(title: "dummy", price: "12", quantity: 1)
    let draftOrderWrapper = DraftOrderWrapper(draftOrder: DraftOrder(name: name, lineItems: [lineItem], email: email))
    _ = network.post(endpoint: endpoint, body: draftOrderWrapper, responseType: DraftOrderWrapper.self)
        .subscribe(onNext: { success, message, response in
            if success {
                print("Request succeeded: \(message ?? "")")
                if let response = response {
                    print("Response: \(response)")
                    let idArray = response.draftOrder?.adminGraphqlApiId?.components(separatedBy: "DraftOrder/")
                    let draftOrderId = idArray?.last ?? "non"
                    print("draft order id: \(draftOrderId)")
                    completion(Int(draftOrderId)!)
                }
            } else {
                print("Request failed: \(message ?? "")")
            }
        }, onError: { error in
            print("Request error: \(error)")
        })
}

func attachIdsToCustomer(_ ids: [Int], _ customer_id: String, _ network: NetworkService) {
    let customer = Customer(tags: ids.map{String($0)}.joined(separator: ","))
    _ = network.put(endpoint: "/customers/\(customer_id).json", body: CustomerResponse(customer: customer), responseType: CustomerResponse.self).subscribe(onNext: {_,_,_ in}, onError: { error in
        print("Error: \(error)")
    })
}

func saveUserInfoToUserDefaults(customerId: String, ordersId: String, wishListId: String, firstName: String, lastName: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(customerId, forKey: "customerId")
    userDefaults.set(ordersId, forKey: "ordersId")
    userDefaults.set(wishListId, forKey: "wishListId")
    userDefaults.set(firstName, forKey: "firstName")
    userDefaults.set(lastName, forKey: "lastName")
    
}

func getCustomerIdFromUserDefaults() -> String? {
    UserDefaults.standard.string(forKey: "customerId")
}
func getOrdersIdFromUserDefaults() -> String? {
    UserDefaults.standard.string(forKey: "ordersId")
}
func getWishListIdFromUserDefaults() -> String? {
    UserDefaults.standard.string(forKey: "wishListId")
}
func getFirstNameFromUserDefaults() -> String? {
    UserDefaults.standard.string(forKey: "firstName")
}
func getLastNameFromUserDefaults() -> String? {
    UserDefaults.standard.string(forKey: "lastName")
}

func getCustomerDraftOrdersIds(customerId: String, completion: @escaping (String) -> Void) {
    let network = NetworkService.shared
    _ = network.get(endpoint: "/customers/\(customerId).json")
        .subscribe{ (customerResponse: CustomerResponse) in
            print(customerResponse.customer?.tags! as Any)
            completion(customerResponse.customer!.tags!)
        } onError: { error in
            print("error getting customer draft orders ids: \(error)")
        }
}
func getCustomerFirstAndLastName(customerId: String, completion: @escaping (String, String) -> Void) {
    let network = NetworkService.shared
    _ = network.get(endpoint: "/customers/\(customerId).json")
        .subscribe{ (customerResponse: CustomerResponse) in
            completion(customerResponse.customer!.firstName!, customerResponse.customer!.lastName!)
        } onError: { error in
            print("error getting customer draft orders ids: \(error)")
        }
}
