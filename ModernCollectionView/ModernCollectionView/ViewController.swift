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
            .debounce(.microseconds(200), scheduler: MainScheduler.instance).map ({ [weak self] keyword in
                self?.tvTrigger.onNext(1)
                return keyword
            })
        
        let input = ViewModel.

//        let output =
        
    }
    
    private func bindView() {
        
    }
    
    public func createLayout() -> UICollectionViewCompositionalLayout {
        
    }
    
    
    
    


}

