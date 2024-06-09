struct Address: Codable {
    var id: Int?
    var customerId: Int?
    var firstName: String?
    var lastName: String?
    var address1: String?
    var address2: String?
    var city: String?
    var country: String?
    var phone: String?
    var name: String?
    var `default`: Bool?
    

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case address1
        case address2
        case city
        case country
        case phone
        case name
        case `default`
    }
}

struct AddressList: Codable {
    var addresses: [Address]?

    enum CodingKeys: String, CodingKey {
        case addresses = "addresses"
    }
}


struct AddressRequestRoot: Codable {
    var address: Address
    init(address: Address) {
        self.address = address
    }
}


struct AddressResponseRoot: Codable {
    var customer_address: Address
    init(address: Address) {
        self.customer_address = address
    }
}

class CustomerResponse: Codable {
    var customer: Customer?
    init(customer: Customer? = nil) {
        self.customer = customer
    }
}

class Customer: Codable {
    var id: Int?
    var email: String?
    var firstName: String?
    var lastName: String?
    var ordersCount: Int?
    var totalSpent: String?
     var lastOrderId: Int?
     var note: String?
     var verifiedEmail: Bool?
    
    init(firstName : String , lastName : String , email : String , note : String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.note = note
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email , note
        case firstName = "first_name"
        case lastName = "last_name"
        case ordersCount = "orders_count"
        case totalSpent = "total_spent"
        case lastOrderId = "last_order_id"
        case verifiedEmail = "verified_email"
    }
}



