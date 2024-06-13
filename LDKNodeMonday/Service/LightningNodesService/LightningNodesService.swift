//
//  LightningNodesService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/31/24.
//

import Foundation

private struct NodeInfoService {
    func fetchNodeInfo(searchText: String) async throws -> LightningNodeInfo {
        guard
            let encodedSearchText = searchText.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string:
                    "https://mempool.space/api/v1/lightning/search?searchText=\(encodedSearchText)"
            )
        else {
            throw NodeInfoServiceError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode
        else {
            throw NodeInfoServiceError.invalidServerResponse
        }
        let jsonDecoder = JSONDecoder()
        let jsonObject = try jsonDecoder.decode(LightningNodeInfo.self, from: data)
        return jsonObject
    }
}

struct NodeInfoClient {
    let fetchNodeInfo: (_ searchText: String) async throws -> LightningNodeInfo
    private init(fetchNodeInfo: @escaping (_ searchText: String) async throws -> LightningNodeInfo)
    {
        self.fetchNodeInfo = fetchNodeInfo
    }
}

extension NodeInfoClient {
    static let live = Self(fetchNodeInfo: { searchText in
        try await NodeInfoService().fetchNodeInfo(searchText: searchText)
    })
}

#if DEBUG
    extension NodeInfoClient {
        static let mock = Self(fetchNodeInfo: { searchText in nodeInfoMock })
    }
#endif
