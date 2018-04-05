import UIKit

public class GliderResource: NSObject {
    let type: GliderResourceType

    @objc convenience public init(url: URL) {
        self.init(type: .remote(url))
    }

    @objc convenience public init(resourceNameInBundle: String) {
        self.init(type: .inBundle(resourceNameInBundle))
    }
    
    @objc convenience public init(assetName: String) {
        self.init(type: .inDataAsset(assetName))
    }

    public init(type: GliderResourceType) {
        self.type = type
    }

    private var data: Data?

    @objc var isDataAvailable: Bool {
        return data != nil
    }

    func load(_ completion: @escaping GliderLoadCompletion) {
        if let data = data {
            handleData(data, completion: completion)
            return
        }

        loadData(completion: completion)
    }

    @objc func load(with completion: @escaping (CALayer?, Error?) -> ()) {
        load { result in
            switch result {
            case .success(let layer):
                completion(layer, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }

    private func loadData(completion: @escaping GliderLoadCompletion) {
        switch type {
        case .inBundle(let name):
            loadLocalResource(named: name, completion: completion)
        case .inDataAsset(let assetName):
            guard let dataAsset = NSDataAsset(name: assetName) else {
                completion(.error(GliderError.emptyOrInvalidData))
                return
            }
            
            handleData(dataAsset.data, completion: completion)
        case .remote(let url):
            loadRemoteResource(at: url, completion: completion)
        case .ready(let data):
            handleData(data, completion: completion)
        }
    }

    private func loadLocalResource(named name: String, completion: @escaping GliderLoadCompletion) {
        guard let resourceURL = Bundle.main.url(forResource: name, withExtension: "caar") else {
            completion(.error(GliderError.localResourceNotFound))
            return
        }

        guard let data = try? Data(contentsOf: resourceURL) else {
            completion(.error(GliderError.emptyOrInvalidData))
            return
        }

        handleData(data, completion: completion)
    }

    private func loadRemoteResource(at url: URL, completion: @escaping GliderLoadCompletion) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("error \(error)")
                completion(.error(GliderError.dataRequestError(error)))
                return
            }

            if let response = response as? HTTPURLResponse {
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    completion(.error(GliderError.invalidStatusCode(response.statusCode)))
                    print("invalid status code")
                    return
                }
            }

            guard let data = data else {
                print("empty or invalid data")
                completion(.error(GliderError.emptyOrInvalidData))
                return
            }

            self.handleData(data, completion: completion)
            }.resume()
    }

    private func handleData(_ data: Data, completion: @escaping GliderLoadCompletion) {
        DispatchQueue.global().async {
            guard let layer = self.rootLayer(from: data) else {
                DispatchQueue.main.async {
                    completion(.error(GliderError.badFormat))
                }

                return
            }

            DispatchQueue.main.async {
                completion(.success(layer))
            }
        }
    }

    private func rootLayer(from data: Data) -> CALayer? {
        guard
            let rootObject = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? [String: Any],
            let layer = rootObject["rootLayer"] as? CALayer else {
                return nil
        }

        return layer
    }
}
