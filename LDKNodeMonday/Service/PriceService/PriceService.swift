//
//  PriceService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/20/24.
//

import Foundation

private struct PriceService {
    func prices() async throws -> Price {
        guard let url = URL(string: "https://mempool.space/api/v1/prices") else {
            throw PriceServiceError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else { throw PriceServiceError.invalidServerResponse }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(Price.self, from: data)
        return jsonObject
    }
}

struct PriceClient {
    let fetchPrice: () async throws -> Price
    private init(fetchPrice: @escaping () async throws -> Price) {
        self.fetchPrice = fetchPrice
    }
}

extension PriceClient {
    static let live = Self(fetchPrice: { try await PriceService().prices() })
}

//#if DEBUG
extension PriceClient {
    static let mock = Self(fetchPrice: { currentPriceMock })
    static let mockPause = Self(fetchPrice: {
        try await Task.sleep(until: .now + .seconds(2))
        return currentPriceMock
    })
    static let mockZero = Self(fetchPrice: { currentPriceMockZero })
}
//#endif
