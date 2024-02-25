//
//  LightningServiceProvider.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/24/24.
//

import Foundation

struct LightningServiceProvider {
    let address: String
    let nodeId: String
    let token: String
}

let mutiny_lsp_address = "3.84.56.108:39735"
let mutiny_lsp_node_id = "0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b"
let mutiny_lsp_token = "lspstoken"

let mutinyLSP = LightningServiceProvider(
    address: mutiny_lsp_address,
    nodeId: mutiny_lsp_node_id,
    token: mutiny_lsp_token
)
