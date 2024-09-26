//
//  BigImageCollectionViewCell.swift
//  ModernCollectionView2
//
//  Created by yujaehong on 7/28/24.
//

import UIKit
import SnapKit
import Kingfisher

final class BigImageCollectionViewCell: UICollectionViewCell {
    static let id = "BigImageCollectionViewCell"
    
    private let posterImage = UIImageView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(posterImage)
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(reviewLabel)
        stackView.addArrangedSubview(descLabel)
        
        posterImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(500)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(posterImage.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(title: String, overview: String, review: String, url: String) {
        titleLabel.text = title
        reviewLabel.text = review
        descLabel.text = overview
        posterImage.kf.setImage(with: URL(string: url))
    }
    
}
