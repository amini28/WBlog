//
//  Attachments.swift
//  Blog
//
//  Created by Amini on 28/11/22.
//

import Foundation

struct DecodeAttachments: Decodable {
    var object: [Attachments]?
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempArray = [Attachments]()
        
        for key in container.allKeys {
            let decodedObject = try container.decode(Attachments.self, forKey: DynamicCodingKeys.init(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }
        
        object = tempArray
    }
}

struct Attachments: Decodable {
    let ID: Int
    let URL: String
    let date: String
    let thumbnails: AttachmentsThumbnail
    
}

struct AttachmentsThumbnail: Decodable {
    let thumbnail: String
    let medium: String
    let large: String
}

enum DecodingError: Error {
    case corruptedData
}
