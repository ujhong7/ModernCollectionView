//
//  ReviewViewController.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/27/24.
//

import UIKit
import RxSwift

fileprivate enum Section {
    case list
}

fileprivate enum Item: Hashable {
    case header(ReviewHeader)
    case content(String)
}

fileprivate struct ReviewHeader: Hashable {
    let id: String
    let name: String
    let url: String
}

final class ReviewViewController: UIViewController {
    
    let viewModel: ReviewViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private let disposeBag = DisposeBag()
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ReviewHeaderCollectionViewCell.self, forCellWithReuseIdentifier: ReviewHeaderCollectionViewCell.id)
        collectionView.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: ReviewCollectionViewCell.id)
        return collectionView
    }()
    
    init(id: Int, contentType: ContentType) {
        self.viewModel = ReviewViewModel(id: id, contentType: contentType)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUI()
    }
    
    private func setUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setDataSource()
        collectionView.rx.itemSelected.bind { [weak self] IndexPath in
            guard let item = self?.dataSource?.itemIdentifier(for: IndexPath),
                  var sectionSnapshot = self?.dataSource?.snapshot(for: .list) else { return }
            if case .header = item {
                if sectionSnapshot.isExpanded(item) {
                    sectionSnapshot.collapse([item])
                } else {
                    sectionSnapshot.expand([item])
                }
                self?.dataSource?.apply(sectionSnapshot, to: .list)
            }
        }.disposed(by: disposeBag)
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .header(let header):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewHeaderCollectionViewCell.id, for: indexPath) as? ReviewHeaderCollectionViewCell
                cell?.configure(title: header.name, url: header.url)
                return cell
            case .content(let content):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.id, for: indexPath) as? ReviewCollectionViewCell
                cell?.configure(content: content)
                return cell
            }
        })
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        dataSourceSnapshot.appendSections([.list])
        dataSource?.apply(dataSourceSnapshot)
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(input: ReviewViewModel.Input())
        output.reviewResult.map { result -> [ReviewModel] in
            switch result {
            case .success(let reviewList):
                print(reviewList)
                return reviewList
            case .failure(let error):
                print(error)
                return []
            }
        }.bind { reviewList in
            guard !reviewList.isEmpty else { return }
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            reviewList.forEach { review in
                let header = ReviewHeader(id: review.id,
                                          name: review.author.name.isEmpty ? review.author.username : review.author.name,
                                          url: review.author.imageURL)
                let headerItem = Item.header(header)
                let contentItem = Item.content(review.content)
                sectionSnapshot.append([headerItem])
                sectionSnapshot.append([contentItem], to: headerItem)
            }
            self.dataSource?.apply(sectionSnapshot, to: .list)
        }
        .disposed(by: disposeBag)
    }
    
}
