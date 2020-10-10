    import Foundation

    class _NewAddress: Codable {


    var  city: String?
    var  state: String?
    var  street: String?
    var  zip: String?

    init(city: String?, state: String?, street: String?, zip: String?) {

            self.zip = zip
    self.street = street
    self.state = state
    self.city = city
        }
        
    }
