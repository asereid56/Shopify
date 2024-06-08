struct Address: Codable {
    var id: Int?
    var customerId: Int?
    var firstName: String?
    var lastName: String?
    var company: String?
    var address1: String?
    var address2: String?
    var city: String?
    var province: String?
    var country: String?
    var zip: String?
    var phone: String?
    var name: String?
    var provinceCode: String?
    var countryCode: String?
    var countryName: String?
    var `default`: Bool?
    

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case company
        case address1
        case address2
        case city
        case province
        case country
        case zip
        case phone
        case name
        case provinceCode = "province_code"
        case countryCode = "country_code"
        case countryName = "country_name"
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
