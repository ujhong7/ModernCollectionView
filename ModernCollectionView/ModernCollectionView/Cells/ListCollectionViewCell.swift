//
//  ListCollectionViewCell.swift
//  ModernCollectionView2
//
//  Created by yujaehong on 7/28/24.
//

import UIKit
import SnapKit
import Kingfisher

class ListCollectionViewCell: UICollectionViewCell {
    
    static let id = "ListCollectionViewCell"
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(image)
        addSubview(titleLabel)
        addSubview(releaseDateLabel)
        
        image.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(8)
            make.top.equalToSuperview()
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(title: String, releaseDate: String, url: String) {
        titleLabel.text = title
        releaseDateLabel.text = releaseDate
        image.kf.setImage(with: URL(string: url))
    }
    
}
