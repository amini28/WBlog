//
//  BlogAPI.swift
//  Blog
//
//  Created by Amini on 20/11/22.
//

import Foundation

class BlogAPI {
    static let share = BlogAPI()
    
    static let baseURL = "https://public-api.wordpress.com/rest/v1.1/"
    
    private let site = "landofminds.wordpress.com"
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func getAllPost(completion: @escaping (Posts?, Error?) -> (Void)) {
        let url = URL(string: "https://public-api.wordpress.com/rest/v1.1/sites/\(site)/posts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print(error!)
                    completion(nil, error)
                }
                return
            }
            
            do {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let posts = try JSONDecoder().decode(Posts.self, from: data)
                DispatchQueue.main.async {
                    completion(posts, nil)
                }
            } catch let error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    func getBlogPosts(search: String, completion: @escaping (Posts?, Error?) -> (Void)) {
        let url = URL(string: "https://public-api.wordpress.com/rest/v1.1/sites/\(site)/posts/?search=\(search)&number=20")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            do {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let posts = try JSONDecoder().decode(Posts.self, from: data)
                DispatchQueue.main.async {
                    completion(posts, nil)
                }
            } catch let error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
}
