import UIKit

public enum GliderError: Error {
    case localResourceNotFound
    case dataRequestError(Error)
    case invalidStatusCode(Int)
    case emptyOrInvalidData
    case badFormat
}

public enum GliderResourceType {
    case inBundle(String)
    case inDataAsset(String)
    case remote(URL)
    case ready(Data)
}

public enum GliderLoadResult {
    case success(CALayer)
    case error(Error)
}

public typealias GliderLoadCompletion = (GliderLoadResult) -> ()
