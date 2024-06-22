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
import FirebaseStorage

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .invalidEmail:
                    completion(false, "Invalid Email Format", "Enter a valid email")
                case .accountExistsWithDifferentCredential:
                    completion(false, "Wrong Password", "Check your password and try again")
                case .invalidCredential:
                    completion(false, "Invalid Credentials", "Check your email and password and try again")
                case .wrongPassword:
                    completion(false, "Empty Fields", "Please fill in email and password fields")
                default:
                    print("Error: \(error)")
                }
            } else {
                self?.fetchExistingUserData(id: authResult!.user.uid) { success in
                    if success {
                        completion(true, nil, nil)
                    }
                    else {
                        print("something went wrong fetching existing data")
                        completion(false, nil, nil)
                    }
                }
            }
        }
    }
    func signUp(firstname: String, lastName: String, email: String, password: String, completion: @escaping (Bool, String?, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .userDisabled:
                    print("user disabled")
                case .weakPassword:
                    completion(false, "Weak Password", "Your password must be at least 6 characters")
                case .invalidEmail:
                    completion(false, "Invalid Email Format", "Enter a valid email")
                case .emailAlreadyInUse:
                    completion(false, "Registered Email", "The email address is already in use by another account.")
                case .missingEmail:
                    completion(false, "Empty Email Field", "An email address must be provided")
                    
                default:
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                setupCustomer(firstName: firstname, lastName: lastName, email: email) { success in
                    if success {
                        completion(true, nil, nil)
                        Auth.auth().currentUser?.sendEmailVerification()
                        print("User signs up successfully")
                    }
                    else {
                        completion(false, nil, nil)
                    }
                }
                
                
                
            }
        }
    }
    
    func signInWithGoogle(vc: UIViewController, completion: @escaping (Bool, Bool) -> Void){
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
            Auth.auth().signIn(with: credential){ [weak self] authResult, error in
                if let isNewUser = authResult?.additionalUserInfo?.isNewUser {
                    if isNewUser {
                        print("New Google user: ")
                        print("firstName: \(user!.profile!.givenName!), lastName: \(user!.profile!.familyName!), email: \(user!.profile!.email)")
                        setupCustomer(firstName: user!.profile!.givenName!, lastName: user!.profile!.familyName!, email: user!.profile!.email) { success in
                            completion(true, true)
                        }
                    }
                    else {
                        print("Old Google user: ")
                        self?.fetchExistingUserData(id: authResult!.user.uid) { success in
                            if success {
                                completion(true, false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resendEmailVerificaiton(completion: @escaping () -> Void) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { _ in
            completion()
        })
    }
    
    func showWelcomeAlert(vc: UIViewController){
        if let currentUser = Auth.auth().currentUser {
            print("user here")
            _ = showToast(message: "Welcome back \(currentUser.email ?? "")", vc: vc)
        }
    }
    
    func showAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        vc.present(alert, animated: true)
        
    }
    
    func isUserLoggedIn() -> Bool {
        Auth.auth().currentUser != nil && UserDefaultsManager.shared.getCustomerIdFromUserDefaults() != nil
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaultsManager.shared.clearDefaults()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchExistingUserData(id: String, completion: @escaping (Bool) -> Void) {
        fetchUserDocumentFromFirebase(firebaseId: id){ customerId in
            getCustomerDraftOrdersIds(customerId: customerId) { ids in
                let idsArray = ids.components(separatedBy: ", ")
                print("from sign in after fetching draft orders ids \(idsArray)")
                getCustomerFirstAndLastName(customerId: customerId) { firstName, lastName in
                    UserDefaultsManager.shared.saveUserInfoToUserDefaults(customerId: customerId,
                                                                          ordersId: idsArray[0], wishListId: idsArray[1], firstName: firstName, lastName: lastName)
                    completion(true)
                }
            }
        }
    }
    func resetPassword(with email: String, completion: @escaping () -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { _ in
            completion()
        }
    }
}


fileprivate func setupCustomer(firstName: String, lastName: String, email: String, completion: @escaping (Bool) -> Void) {
    
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
                    createUserDocumentOverFirebase(firebaseId: Auth.auth().currentUser!.uid, APIId: customer_id, email: email, img: nil) {
                        createTwoDraftOrders(email: email) { ids in
                            attachIdsToCustomer(ids, customer_id, network) { success in
                                UserDefaultsManager.shared.saveUserInfoToUserDefaults(customerId: customer_id, ordersId: String(ids[0]), wishListId: String(ids[1]), firstName: firstName, lastName: lastName)
                                if success {
                                    completion(true)
                                } else {
                                    completion(false)
                                }
                            }
                        }
                    }
                }
            } else {
                completion(false)
                print("Request failed: \(message ?? "")")
            }
        }, onError: { error in
            completion(false)
            print("Request error: (error)")
        })
}


func createUserDocumentOverFirebase(firebaseId: String, APIId: String, email: String, img: Data?, completion: @escaping () -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(firebaseId)
    
    let userData: [String: Any] = [
        "firebaseId": firebaseId,
        "APIId": APIId,
        "email": email,
        "otra": "another",
        "img": img ?? String()
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

func updateUserImage(data: Data, completion: @escaping (Bool) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        print("Error: Could not retrieve current user ID for image upload.")
        return
    }

    let storageRef = Storage.storage().reference()
    let imagesRef = storageRef.child("images/\(userID).jpg") // Consistent naming

    imagesRef.putData(data, metadata: nil) { metadata, error in
        if let error = error {
            print("Error uploading image: \(error)")
            completion(false)
            return
        }

        imagesRef.downloadURL { url, error in
            if let error = error {
                print("Error getting download URL: \(error)")
                return
            }

            guard let downloadURL = url else {
                print("Download URL is nil")
                return
            }
            updateUserImageURL(downloadURL.absoluteString){ complete in
                if complete {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
}

func updateUserImageURL(_ url: String, completion: @escaping (Bool) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        print("Error: Could not retrieve current user ID for image URL update.")
        return
    }

    let db = Firestore.firestore() // Concise variable name
    let userRef = db.collection("users").document(userID)

    userRef.updateData(["img": url]) { error in
        if let error = error {
            print("Error updating Firestore: \(error)")
            completion(false)
        } else {
            print("Image URL successfully updated in Firestore")
            completion(true)
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
            print("User Info Document does not exist")
        }
    }
}

func getUserImage(completion: @escaping (Data) -> Void) {
    guard let id = Auth.auth().currentUser?.uid else { return }
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(id)
    
    userRef.getDocument { document, error in
        if let document = document, document.exists {
            guard let data = document.data() else { return }
            guard let userImg = data["img"] else { return }
            print("User img fetched from firestore: \(userImg)")
            if let imgURL = userImg as? String {
                print("could")
                loadImageFromURL(imgURL) { data in
                    print("from load image url actual completion")
                    completion(data)
                }
            
            }
            //completion(userImg as! Data)
        } else {
            completion(Data())
            print("Image Document does not exist")
        }
    }
}

func loadImageFromURL(_ urlString: String, completion: @escaping (Data) -> Void) {
    print("from load image url")
    guard let url = URL(string: urlString) else {
        completion(Data())
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Failed to download image: \(String(describing: error))")
            return
        }
        completion(data)
    }.resume()
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
    let lineItem = LineItem(title: "dummy", price: "0", quantity: 1)
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

func attachIdsToCustomer(_ ids: [Int], _ customer_id: String, _ network: NetworkService, completion: @escaping (Bool) -> Void) {
    let customer = Customer(tags: ids.map{String($0)}.joined(separator: ","))
    _ = network.put(endpoint: "/customers/\(customer_id).json", body: CustomerResponse(customer: customer), responseType: CustomerResponse.self).subscribe(onNext: {_,_,_ in
            completion(true)
    }, onError: { error in
        completion(false)
        print("Error: \(error)")
    })
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

func isEmailVerified(vc: UIViewController, completion: @escaping (Bool) -> Void) {
    if AuthenticationManager.shared.isUserLoggedIn() {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let user = Auth.auth().currentUser {
                if user.isEmailVerified {
                    completion(true)
                } else {
                    let action1 = UIAlertAction(title: "Verify", style: .default) { _ in
                        AuthenticationManager.shared.resendEmailVerificaiton() {
                            _ = showToast(message: "Email verification sent", vc: vc)
                        }
                    }
                    let action2 = UIAlertAction(title: "Cancel", style: .destructive)
                    _ = showToast(title: "Email Verification Required", message: "You must verify your email in order to proceed", vc: vc, actions: [action2, action1], style: .alert, selfDismiss: false, completion: nil)
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    } else {
        completion(false)
    }
}



