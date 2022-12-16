//
//  Posts.swift
//  Blog
//
//  Created by Amini on 28/11/22.
//

import Foundation

struct Posts: Decodable {
    let posts: [Post]
}

struct Post : Decodable {
    let ID: Int
    let site_ID: Int
    let author: Author
    let date: String
    let title: String
    let content: String
    let excerpt: String
    let attachments: DecodeAttachments
}
