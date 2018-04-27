//
//  SpotifyRequest.swift
//  MusicMatchRev2
//
//  Created by Shukti Shaikh on 3/28/18.
//  Copyright © 2018 Shukti Shaikh. All rights reserved.
//

import Foundation

protocol SpotifyRequest: Encodable {
    
    associatedType Response: Decodable
    
    var resourceName: String { get }
}
