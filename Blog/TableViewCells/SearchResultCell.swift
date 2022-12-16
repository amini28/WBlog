//
//  SearchResultCell.swift
//  Blog
//
//  Created by Amini on 26/11/22.
//

import UIKit

class SearchResultCell: UITableViewCell {
    static let identifier = "search-result-cell-identifier"
    
    lazy private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 1
        return titleLabel
    }()
    
    lazy private var thumbnail: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.image = UIImage(systemName: "photo.artframe")
        thumbnail.contentMode = .center
        thumbnail.tintColor = .black
        thumbnail.backgroundColor = .lightGray.withAlphaComponent(0.5)
        thumbnail.layer.cornerRadius = 4
        thumbnail.layer.masksToBounds = true
        return thumbnail
    }()
    
    lazy private var excerptLabel: UILabel = {
        let excerptLabel = UILabel()
        excerptLabel.translatesAutoresizingMaskIntoConstraints = false
        excerptLabel.adjustsFontForContentSizeCategory = true
        excerptLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        excerptLabel.backgroundColor = .white
        excerptLabel.layer.cornerRadius = 4
        excerptLabel.layer.masksToBounds = true
        excerptLabel.numberOfLines = 3
        return excerptLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnail)
        contentView.addSubview(excerptLabel)
        
        
        titleLabel.text = "Make Design Systems People want to use."
        excerptLabel.text = "Yet, as a system designer, i'm often in the position to provoke and validate color decisions as a system takes shape"
        let inset = CGFloat(8)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            
            excerptLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            excerptLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: inset/2),
            
            thumbnail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            thumbnail.heightAnchor.constraint(equalToConstant: 100),
            thumbnail.widthAnchor.constraint(equalToConstant: 100),
            thumbnail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            
            titleLabel.trailingAnchor.constraint(equalTo: thumbnail.leadingAnchor, constant: -inset),
            excerptLabel.trailingAnchor.constraint(equalTo: thumbnail.leadingAnchor, constant: -inset)
        ])
    }
        
    public func configure(post: Post) {
        titleLabel.text = post.title
        excerptLabel.attributedText = post.excerpt.convertToAttributedFromHTML()
        excerptLabel.font = UIFont.preferredFont(forTextStyle: .caption2)

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
