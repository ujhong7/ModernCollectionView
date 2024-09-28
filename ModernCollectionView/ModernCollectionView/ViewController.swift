//
//  ViewController.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/14/24.
//

import UIKit
import SnapKit
import RxSwift

fileprivate enum Section: Hashable {
    case double
    case banner
    case horizontal(String)
    case vertical(String)
}

fileprivate enum Item: Hashable {
    case normal(Content)
    case bigImage(Movie)
    case list(Movie)
}

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let buttonView = ButtonView()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.register(NormalCollectionViewCell.self, forCellWithReuseIdentifier: NormalCollectionViewCell.id)
        collectionView.register(BigImageCollectionViewCell.self, forCellWithReuseIdentifier: BigImageCollectionViewCell.id)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.id)
        return collectionView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let textfield: UITextField = {
        let textfield = UITextField()
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.layer.cornerRadius = 6
        textfield.tintColor = .black
        textfield.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        textfield.leftViewMode = .always
        return textfield
    }()
    
    let viewModel = ViewModel()
    
    let tvTrigger = BehaviorSubject<Int>(value: 1)
    let movieTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setDataSource()
        bindViewModel()
        bindView()
        tvTrigger.onNext(1)
    }
    
    private func setUI() {
        self.view.addSubview(stackView)
        stackView.addArrangedSubview(textfield)
        stackView.addArrangedSubview(buttonView)
        self.view.addSubview(collectionView)
        
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        textfield.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        buttonView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom)
        }
        
    }
    
    private func bindViewModel() {
        let keyword = textfield.rx.text.orEmpty.distinctUntilChanged()
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance).map({ [weak self] keyword in
                self?.tvTrigger.onNext(1)
                return keyword
            })
        
        let input = ViewModel.Input(keyword: keyword,
                                    tvTrigger: tvTrigger.asObservable(),
                                    movieTrigger: movieTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.tvList.bind { [weak self] tvList in
            print("TV List: \(tvList)")
            var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
            let items = tvList.map{ Item.normal(Content(tv: $0))}
            let section = Section.double
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            self?.dataSource?.apply(snapshot)
        }.disposed(by: disposeBag)
        
        output.movieList.bind { [weak self] result in
            print("Movie Result: \(result)")
            
            switch result {
            case .success(let movieResult):
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                
                let bigImageList = movieResult.nowPlaying.results.map { movie in
                    return Item.bigImage(movie)
                }
                let bannerSection = Section.banner
                snapshot.appendSections([bannerSection])
                snapshot.appendItems(bigImageList, toSection: bannerSection)
                
                let horizontalSection = Section.horizontal("Popular Movies")
                let normalList = movieResult.popular.results.map { movie in
                    return Item.normal(Content(movie: movie))
                }
                snapshot.appendSections([horizontalSection])
                snapshot.appendItems(normalList, toSection: horizontalSection)
                
                
                let verticalSection = Section.vertical("Upcoming Movies")
                let itemList = movieResult.upcoming.results.map { movie in
                    return Item.list(movie)
                }
                snapshot.appendSections([verticalSection])
                snapshot.appendItems(itemList, toSection: verticalSection)
                
                self?.dataSource?.apply(snapshot)
            case .failure(let error):
                // Toast dialog
                print(error)
            }
            
        }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        buttonView.tvButton.rx.tap.bind { [weak self] in
            self?.textfield.isHidden = false
            self?.tvTrigger.onNext(1)
        }.disposed(by: disposeBag)
        
        buttonView.movieButton.rx.tap.bind { [weak self] in
            self?.textfield.isHidden = false
            self?.movieTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        // 화면전환
        collectionView.rx.itemSelected.bind { [weak self] indexPath in
            print(indexPath)
            let item = self?.dataSource?.itemIdentifier(for: indexPath)
            switch item {
            case .normal(let content):
                print(content)
                let navigationController = UINavigationController()
                let viewController = ReviewViewController(id: content.id, contentType: content.type)
                navigationController.viewControllers = [viewController]
                self?.present(navigationController, animated: true)
            case .list(let movie):
                print(movie)
                
            default:
                print("default")
            }
        }.disposed(by: disposeBag)
        
        // 페이지 네이션
        collectionView.rx.prefetchItems
            .filter ({ [weak self] _ in
                return self?.viewModel.currentContentType == .tv
            })
            .bind { [weak self] indexPath in
                print(indexPath)
                let snapshot = self?.dataSource?.snapshot()
                guard let lastIndexPath = indexPath.last,
                      let section = self?.dataSource?.sectionIdentifier(for: lastIndexPath.section),
                      let itemCount = snapshot?.numberOfItems(inSection: section),
                      let currentPage = try? self?.tvTrigger.value() else { return }
                if lastIndexPath.row > itemCount - 4 {
                    self?.tvTrigger.onNext(currentPage + 1)
                }
            }.disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 14
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            
            switch section {
            case .banner:
                return self?.createBannerSection()
            case .horizontal:
                return self?.createHorizontalSection()
            case .vertical:
                return self?.createVerticalSection()
            default:
                return self?.createDoubleSection()
            }
        }, configuration: config)
    }
    
    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(640))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createDoubleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .normal(let contentData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalCollectionViewCell.id, for: indexPath) as? NormalCollectionViewCell
                cell?.configure(title: contentData.title, review: contentData.vote, desc: contentData.overview, imageURL: contentData.posterURL)
                return cell
            case .bigImage(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigImageCollectionViewCell.id, for: indexPath) as? BigImageCollectionViewCell
                cell?.configure(title: movieData.title, overview: movieData.overview, review: movieData.vote, url: movieData.posterURL)
                return cell
            case .list(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell
                cell?.configure(title: movieData.title, releaseDate: movieData.releaseDate, url: movieData.posterURL)
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.id, for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case . horizontal(let title), .vertical(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                print("Default")
            }
            
            return header
        }
        
    }
    
}

