//
//  ContentViewController.swift
//  Blog
//
//  Created by Amini on 26/11/22.
//

import UIKit
import SwiftSoup

class ContentViewController: UIViewController {
    
    private var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.isScrollEnabled = true
        return scrollview
    }()
    
    private var stackview: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        return stack
    }()
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private var thumbnail: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.image = UIImage(systemName: "photo.artframe")
        thumbnail.contentMode = .center
        thumbnail.backgroundColor = .lightGray.withAlphaComponent(0.1)
        thumbnail.layer.cornerRadius = 16
        thumbnail.layer.masksToBounds = true
        return thumbnail
    }()
    
    private var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        dateLabel.textColor = UIColor.systemGray
        return dateLabel
    }()
    
    private var contentTextview: UILabel = {
        let contentTextview = UILabel()
        contentTextview.translatesAutoresizingMaskIntoConstraints = false
        contentTextview.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentTextview.numberOfLines = 0
        contentTextview.lineBreakMode = .byWordWrapping
        return contentTextview
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureViews()
        
    }
    
    private func configureViews() {
        stackview.axis = .vertical
        stackview.distribution = .equalSpacing
        
        view.addSubview(scrollview)
        scrollview.addSubview(stackview)
        
        let inset = CGFloat(8)
        NSLayoutConstraint.activate([
            scrollview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            
            stackview.topAnchor.constraint(equalTo: scrollview.topAnchor),
            stackview.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
            stackview.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor),
            stackview.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor),
            
            thumbnail.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        stackview.addArrangedSubview(thumbnail)
        stackview.addArrangedSubview(dateLabel)
        stackview.addArrangedSubview(titleLabel)
        stackview.addArrangedSubview(contentTextview)

    }
    
    public func configure(post: Post) {

        if let imageStringURL = post.attachments.object?.first?.thumbnails.medium {
            let imageURL = URL(string: imageStringURL)
            
            let task = URLSession.shared.dataTask(with: imageURL!) { [weak self] data, _, _ in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self?.thumbnail.image = UIImage(data: data)
                    self?.thumbnail.contentMode = .scaleAspectFill
                }
            }
            
            task.resume()
            
            
        }

        
        dateLabel.text = post.date.getDateAndMonth()
        titleLabel.text = post.title
        
        let htmlString = modifiedHtml(htmlString: post.content)
        contentTextview.attributedText = htmlString.convertToAttributedFromHTML()
        contentTextview.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    private func modifiedHtml(htmlString: String) -> String {
        do {
            guard let doc: Document = try? SwiftSoup.parse(htmlString) else { return htmlString }
            
            print(doc)
            
            let images: Elements = try doc.select("img")
            if images.count > 0 {
                var imgWidth: [Int] = []
                for image in images {
                    let imgsource: String = try image.attr("src")
                    let src = imgsource.components(separatedBy: "?w=")[1]
                    let width: Int = Int(src) ?? 0
                    imgWidth.append(width)
                    print(imgWidth)
                }
                
                let scaler = CGFloat(imgWidth.max()!) / UIScreen.main.bounds.width
                
                let figures: Elements = try doc.select("figure")
                
                for figure in figures {
                    try figure.removeClass("wp-block-image")
                    try figure.removeClass("size-large")
                    
                    let image: Element = try figure.select("img").first()!
                    try image.removeAttr("data-image-meta")
                    try image.removeAttr("data-large-file")
                    try image.removeAttr("data-comments-opened")
                    try image.removeAttr("data-image-title")
                    try image.removeAttr("data-image-meta")
                    try image.removeAttr("data-image-caption")
                    try image.removeAttr("data-permalink")
                    try image.removeAttr("data-attachment-id")
                    try image.removeAttr("data-image-description")
                    try image.removeAttr("data-orig-file")
                    try image.removeAttr("data-orig-size")
                    try image.removeAttr("loading")
                    try image.removeAttr("srcset")
                    try image.removeAttr("height")
                    
                    let imageWidth = try image.attr("width")
                    let float = CGFloat((imageWidth as NSString).floatValue)
                    
                    if float > 0 {
                        let scaled = CGFloat((imageWidth as NSString).floatValue) / scaler
                        try image.attr("width", "\(scaled)")
                    } else {
                        let width = UIScreen.main.bounds.width
                        try image.attr("width", "\(width)")
                    }
                    
                    try figure.children().remove()
                    try figure.addChildren(image)
                }
            }
            
            let htmlsstr = try doc.html()
            print(htmlsstr)
            
            return htmlsstr
            
        } catch Exception.Error(_, let message) {
            print(message)
            return htmlString
        } catch {
            print("error")
            return htmlString
        }
    }
}

extension String {
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
}
