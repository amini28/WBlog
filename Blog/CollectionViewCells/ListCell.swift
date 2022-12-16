//
//  ListCell.swift
//  Blog
//
//  Created by Amini on 25/11/22.
//

import Foundation
import UIKit

class ListCell: UICollectionViewCell {
    static let identifier = "list-cell-identifier"
    
    lazy private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    lazy private var thumbnail: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.image = UIImage(systemName: "photo.artframe")
        thumbnail.tintColor = .black
        thumbnail.contentMode = .center
        thumbnail.backgroundColor = .lightGray.withAlphaComponent(0.5)
        thumbnail.layer.cornerRadius = 16
        thumbnail.layer.masksToBounds = true
        return thumbnail
    }()
    
    lazy private var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        dateLabel.backgroundColor = .white
        dateLabel.layer.cornerRadius = 4
        dateLabel.layer.masksToBounds = true
        return dateLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnail)
        contentView.addSubview(dateLabel)
                
        let inset = CGFloat(8)
        NSLayoutConstraint.activate([
            
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            thumbnail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            thumbnail.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(inset*3)),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            
            dateLabel.leadingAnchor.constraint(equalTo: thumbnail.leadingAnchor, constant: inset),
            dateLabel.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: inset),
        ])
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = UIImage(systemName: "photo.artframe")
        thumbnail.contentMode = .center
        thumbnail.tintColor = .black
        titleLabel.text = ""
        dateLabel.text = ""
    }
    
    public func configure(post: Post) {
        
        let titleText = NSAttributedString(string: "\n\(post.title)\n\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        let excerptText = post.excerpt.convertToAttributedFromHTML()!
        
        let attributedStrings: NSMutableAttributedString = NSMutableAttributedString(string: "")
        attributedStrings.append(excerptText)
        attributedStrings.setAttributes([.font: UIFont.systemFont(ofSize: 13, weight: .regular)], range: NSMakeRange(0, excerptText.length))
        attributedStrings.insert(titleText, at: 0)
        
        titleLabel.attributedText = attributedStrings
        dateLabel.text = "  \(post.date.getDateAndMonth())  "
        
        guard let imageStringURL = post.attachments.object?.first?.thumbnails.medium else { return }
        let imageURL = URL(string: imageStringURL)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.async {
                self.thumbnail.image = UIImage(data: data!)
            }
        }
        thumbnail.contentMode = .scaleAspectFill
    }
        
    // date format 2021-04-22T19:39:45+00:00"
}

extension String {
    func getDateAndMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "d MMM yyyy"
            return dateFormatter.string(from: date)
        }
        return self
    }
    
}

