//
//  GridCell.swift
//  Blog
//
//  Created by Amini on 25/11/22.
//

import Foundation
import UIKit

class GridCell: UICollectionViewCell {

    static let identifier = "grid-cell-identifier"

    lazy private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    lazy private var thumbnail: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.image = UIImage(systemName: "photo.artframe")
        thumbnail.contentMode = .center
        thumbnail.tintColor = .black
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnail)
        contentView.addSubview(dateLabel)
        
        let inset = CGFloat(8)
        NSLayoutConstraint.activate([
            
            thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            thumbnail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            thumbnail.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            titleLabel.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: inset/2),
            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -inset),
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            
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
        titleLabel.text = post.title
        dateLabel.text = post.date.getDateAndMonth()
        
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
}
