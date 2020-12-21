import Foundation
import Combine


struct _PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

/**
Multiple status values can be provided with comma separated strings

Responses:
   - 200: successful operation
   - 400: Invalid status value
*/
static func findPetsByStatus(status: String? = "available", authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<[_Pet], Error> {
var path = NetworkManager.basePath! + "/pet/findByStatus"
    
path += "?\(status != nil ? "&status=\(status?.description ?? "")" : "")"

    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: [_Pet].self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

}
