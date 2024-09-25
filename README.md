# ModernCollectionView

모던 컬렉션 뷰(Modern Collection View)는 iOS 13에서 도입된 새로운 방식의 `UICollectionView`로,  
더 효율적으로 데이터를 관리하고 복잡한 레이아웃을 구현할 수 있도록 설계된 기능입니다.  
기존의 `UICollectionView`는 데이터 소스와 레이아웃을 수동으로 관리해야 했지만,  
모던 컬렉션 뷰는 `Diffable Data Source`와 `Compositional Layout`이라는 두 가지 핵심 기능을 제공하여 이를 쉽게 처리할 수 있습니다.  

<p align="center" witdh="50%">
<img src="" width="17%">
<img src="" width="17%">
</p>

## [🟡 데이터소스](#custom-anchor2)  
`UICollectionViewDiffableDataSource`, `NSDiffableDataSourceSnapshot`  
컬렉션 뷰에 표시할 데이터를 관리하는 역할을 합니다.  
섹션과 아이템을 정의하고, 데이터를 스냅샷으로 적용하여 동적으로 업데이트할 수 있습니다.  

## [🟢 레이아웃](#custom-anchor)   
`UICollectionViewCompositionalLayout`  
컬렉션 뷰의 아이템들이 어떻게 배치될지, 레이아웃이 어떻게 구성될지를 관리합니다.  
섹션마다 다른 레이아웃을 적용할 수 있어 유연한 화면 구성이 가능합니다.

<br>

---
<a name="custom-anchor2"></a>
<br>

### 🟡 UICollectionViewDiffableDataSource

`UICollectionViewDiffableDataSource`는 컬렉션 뷰의 데이터 소스를 효율적으로 관리하는 객체로,  
데이터를 스냅샷으로 캡처하여 UI와 쉽게 동기화할 수 있게 도와줍니다.   
이 데이터 소스는 변경 사항을 간단하게 적용할 수 있는 API를 제공하여,  
데이터 업데이트 시 보다 직관적이고 간편한 방법으로 UI를 갱신할 수 있습니다.  

<br>

#### 기본 구조

- `섹션 (Section)` : UICollectionView의 여러 영역을 나타냅니다.   
                 예를 들어, "추천 영상", "인기 영상" 등 다양한 카테고리로 나누어 관리할 수 있습니다.  
- `아이템 (Item)` : 각 섹션 내의 개별 요소를 의미합니다. 예를 들어, 각 영상 정보를 담고 있는 셀을 말합니다.  

#### 사용 예시  

- 데이터 소스 정의: UICollectionViewDiffableDataSource를 정의할 때, 섹션과 아이템 타입을 지정합니다.  
    ```Swift
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
    ```

- 섹션 및 아이템 타입 정의: 섹션과 아이템을 나타내는 enum과 구조체를 정의합니다.  
    ```Swift
    enum Section: Hashable {
        case double
        case banner
        case horizontal(String) 
        case vertical(String)
    }

    enum Item: Hashable {
        case normal(Content) 
        case bigImage(Movie)
        case list(Movie)
    }
    ```

- 데이터 업데이트: 데이터 변경 사항을 반영하기 위해 스냅샷을 생성하고, 이를 데이터 소스에 적용합니다.  
    ```Swift
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.double, .banner, .horizontal("horizontal"), .vertical("vertical")])
    snapshot.appendItems([item1, item2], toSection: .horizontal("horizontal"))
    snapshot.appendItems([item3, item4], toSection: .vertical("vertical"))
    dataSource.apply(snapshot, animatingDifferences: true)
    ```

- `UICollectionViewDiffableDataSource` 사용 시 장점  
  - 효율성: 데이터 소스 변경 시 애니메이션 효과를 통해 사용자 경험을 개선  
  - 간편한 업데이트: 단순한 API를 통해 복잡한 데이터 변경을 쉽게 처리
  - 스냅샷 기반: 상태를 스냅샷으로 저장하여 이전 상태와의 차이를 자동으로 관리
  

<br>

### 🟡 Snapshot
`NSDiffableDataSourceSnapshot`은 컬렉션 뷰나 테이블 뷰의 **데이터 상태를 스냅샷으로 캡처한 객체**입니다.  
이 스냅샷은 현재의 섹션과 아이템 구조를 나타내며, 데이터의 변경 사항을 쉽게 관리하고 적용할 수 있도록 도와줍니다.

<br>

### 🟡 왜 Snapshot을 사용?

- 간편한 데이터 관리: 
기존의 `UICollectionViewDataSource`와 달리, 
스냅샷을 사용하면 데이터의 섹션과 아이템을 명확하게 정의할 수 있습니다.
- 자동 애니메이션: 
스냅샷을 적용할 때, 
변경된 부분에 대해 자동으로 애니메이션이 적용되어 UI 업데이트가 부드럽게 이루어집니다.
- 안전성: 
데이터의 일관성을 유지하면서 변경 사항을 적용할 수 있어, 
데이터 소스와 UI 간의 불일치 문제를 줄일 수 있습니다.
- 편리한 업데이트: 
스냅샷을 통해 섹션과 아이템을 추가, 삭제, 변경하는 작업이 간편해집니다.

<br>

### 🟡 사용방법

1️⃣ Snapshot 생성  
```Swift
var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
```
- 새로운 스냅샷 객체를 생성합니다.  
여기서 Section과 Item은 각각 섹션과 아이템의 타입을 나타내는 제네릭 타입입니다.
    

2️⃣ 섹션 추가  
```Swift
snapshot.appendSections([section])
```
- 스냅샷에 섹션을 추가합니다.  
Section 열거형을 사용하여 다양한 섹션 타입을 정의할 수 있습니다.

3️⃣ 아이템 추가  
```Swift
snapshot.appendItems(items, toSection: section)
```
- 특정 섹션에 아이템을 추가합니다.  
이 예제에서는 TV 리스트를 `Item.normal(Content(tv: $0))` 형태로 변환하여 추가하고 있습니다.

4️⃣ Snapshot 적용:
```Swift
private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
```
```Swift
self?.dataSource?.apply(snapshot)
```
- 생성한 스냅샷을 `UICollectionViewDiffableDataSource`에 적용하여 
컬렉션 뷰의 데이터를 업데이트합니다.
- `apply(snapshot)` 메서드를 호출하면, 
데이터 소스는 현재 스냅샷과 비교하여 필요한 변경 사항을 자동으로 계산하고 UI를 업데이트합니다.

<br>

### 🟡 사용예제

<img width="500" alt="스크린샷 2024-09-18 오후 3 43 50" src="https://github.com/user-attachments/assets/e1c0d6f5-797b-4264-bd40-accbf9b7e3ea">  

- TV 리스트를 받으면
    - 새로운 스냅샷을 생성하고, 
    TV 리스트 데이터를 아이템으로 변환하여 섹션에 추가합니다.
    - 스냅샷을 데이터 소스에 적용하여 컬렉션 뷰를 업데이트합니다.

<br>

### 🟡 정리  
- Snapshot이란?
    - `NSDiffableDataSourceSnapshot`은 
    컬렉션 뷰나 테이블 뷰의 데이터 상태를 스냅샷 형태로 캡처한 객체
- Snapshot의 역할
    - 현재 데이터 상태를 정의하고, 변경 사항을 안전하고 효율적으로 적용
- Snapshot 사용 이유
    - 간편한 데이터 관리, 자동 애니메이션, 데이터 일관성 유지, 편리한 업데이트 등 다양한 장점
- Snapshot 적용 과정
    1. 스냅샷 생성
    2. 섹션 및 아이템 추가
    3. 데이터 소스에 스냅샷 적용 `(apply(snapshot))`


<br>

---
<a name="custom-anchor"></a>
<br>

### 🟢 UICollectionViewCompositionalLayout

UICollectionViewCompositionalLayout은 
복잡한 컬렉션 뷰 레이아웃을 유연하게 구성할 수 있는 새로운 방식입니다.  
기존의 UICollectionViewFlowLayout보다 더 세밀하고 다양한 레이아웃 구성을 할 수 있게 도와줍니다.  
이 방식은 섹션별로 서로 다른 레이아웃을 정의할 수 있어, 콘텐츠가 다양하고 동적인 앱에 적합합니다.

UICollectionViewCompositionalLayout은 주로 다음 세 가지 요소로 구성됩니다:

- **아이템(NSCollectionLayoutItem)**:  
컬렉션 뷰의 각 셀에 해당하는 가장 기본적인 단위입니다.
- **그룹(NSCollectionLayoutGroup)**:  
하나 이상의 아이템을 묶어 배치하는 단위로, 
가로 또는 세로 방향으로 여러 개의 아이템을 그룹화할 수 있습니다.
- **섹션(NSCollectionLayoutSection)**:  
그룹을 담는 상위 개념으로, 각 섹션마다 다른 레이아웃을 설정할 수 있습니다.  
섹션 내에서 스크롤 방향을 가로 혹은 세로로 설정하거나, 페이징 등의 스크롤 동작을 제어할 수 있습니다.
<img width="240" alt="스크린샷 2024-09-18 오후 6 31 20" src="https://github.com/user-attachments/assets/e2b165d1-91ca-4ca6-be0b-7bfaadcf2f66">

<br>

### 🟢 구성 요소

1. NSCollectionLayoutItem
    - 레이아웃의 기본 단위로, 각 셀에 대한 크기와 여백을 정의합니다.  
```Swift
let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
let item = NSCollectionLayoutItem(layoutSize: itemSize)
item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
```
    
2. NSCollectionLayoutGroup
    - 여러 개의 아이템을 묶는 역할을 하며, 가로/세로 방향으로 그룹을 만들 수 있습니다.  
```Swift
let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
```
    
3. NSCollectionLayoutSection
    - 그룹을 모아 하나의 섹션을 구성하며, 섹션 내의 스크롤 동작 등을 제어할 수 있습니다.     
```Swift
let section = NSCollectionLayoutSection(group: group)
section.orthogonalScrollingBehavior = .continuous
```

<br>

### 🟢 특징

- 동적 레이아웃:  
섹션마다 다른 레이아웃을 적용할 수 있습니다.  
예를 들어, 하나의 섹션은 가로 스크롤 배너로 설정하고, 다른 섹션은 세로로 나열된 리스트 형태로 만들 수 있습니다.
- 고급 스크롤 동작:  
각 섹션에 대해 orthogonalScrollingBehavior를 설정하여 섹션별로 스크롤 방향을 다르게 할 수 있습니다.
- 레이아웃 설정의 유연성:  
각 섹션마다 헤더, 푸터, 그룹 내의 아이템 크기 등을 세밀하게 조정할 수 있어 다양한 화면 구성을 쉽게 구현할 수 있습니다.  

이 구조를 활용하면 UICollectionView 내에서 복잡한 레이아웃을 유연하게 관리할 수 있고, 다중 섹션으로 구성된 앱을 구현할 때 사용

<br>

### 🟢 사용예제  

#### 1️⃣ UICollectionViewCompositionalLayout 생성
코드에서는 UICollectionViewCompositionalLayout을 createLayout() 메서드로 정의하고 있습니다.  
(이 레이아웃은 섹션별로 레이아웃이 달라지는 구조를 처리)  

```Swift
private func createLayout() -> UICollectionViewCompositionalLayout {
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 14 // 섹션 간의 간격을 14로 설정
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
```

- UICollectionViewCompositionalLayout:  
이 메서드는 sectionProvider 클로저를 사용하여 각 섹션에 맞는 레이아웃을 정의합니다.  
sectionProvider는 각 섹션마다 다른 레이아웃을 설정할 수 있도록 유연성을 제공합니다.

- UICollectionViewCompositionalLayoutConfiguration:  
이 설정을 통해 전체 레이아웃에 대한 공통 설정을 지정합니다.  
여기서는 interSectionSpacing을 사용하여 섹션 간 간격을 조정합니다.  

<br>

#### 2️⃣ NSCollectionLayoutSection 생성
NSCollectionLayoutSection은 각 섹션에서의 레이아웃을 정의하는 역할을 합니다.  
이 코드는 여러 가지 섹션 타입을 정의하고 있으며, 각 섹션마다 다른 레이아웃을 제공하고 있습니다.  
아래는 각 섹션의 예시입니다.  

1. createVerticalSection() - 수직 레이아웃 섹션

    이 섹션은 수직으로 3개의 아이템을 배치하고, 연속적인 스크롤이 가능하도록 설정된 레이아웃입니다.
     
```Swift
private func createVerticalSection() -> NSCollectionLayoutSection {
    // 아이템 크기 설정
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
    
    // 그룹 크기 설정
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
    
    // 섹션 설정
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    
    // 헤더 추가
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
    section.boundarySupplementaryItems = [header]
    
    return section
}
```

- 아이템(NSCollectionLayoutItem): 각 아이템의 크기를 지정합니다. 여기서는 아이템이 섹션 너비의 100%, 높이의 30%를 차지합니다.  
- 그룹(NSCollectionLayoutGroup): 3개의 아이템을 수직으로 배치하는 그룹을 설정합니다.
- 섹션(NSCollectionLayoutSection): 그룹을 담아 수직으로 스크롤 가능한 섹션을 정의하며, 연속적인 스크롤이 가능하게 설정(orthogonalScrollingBehavior = .continuous)됩니다.
- 헤더(NSCollectionLayoutBoundarySupplementaryItem): 섹션의 상단에 헤더를 추가하여 추가적인 정보나 제목을 보여줍니다.  

<br>

2. createHorizontalSection() - 수평 레이아웃 섹션  
   
    이 섹션은 수평으로 아이템을 배치하고, 가로 스크롤이 가능하게 구성된 레이아웃입니다.   
     
```Swift
private func createVerticalSection() -> NSCollectionLayoutSection {
    // 아이템 크기 설정
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
    
    // 그룹 크기 설정
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
    
    // 섹션 설정
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    
    // 헤더 추가
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
    section.boundarySupplementaryItems = [header]
    
    return section
}
```
 
 - 아이템: 수평으로 배치할 아이템의 크기와 여백을 정의합니다.  
 - 그룹: 수평으로 아이템을 배치하고, 각 아이템이 전체 너비의 40%를 차지하도록 설정합니다.  
 - 섹션: 연속적인 가로 스크롤이 가능하도록 구성된 섹션입니다.    

<br>

3. createBannerSection() - 배너 섹션  
    배너와 같은 큰 이미지를 하나의 섹션으로 구성할 때 사용합니다.  
    
```Swift
private func createBannerSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(640))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
        
    return section
}
```

  
- 배너 섹션: 큰 이미지 또는 광고 배너와 같은 요소를 표시하는 데 사용됩니다. 하나의 아이템을 섹션 전체에 배치하며, 그룹 페이징 스크롤이 적용됩니다.    

 <br>
 
4. createDoubleSection() - 2열 레이아웃 섹션  
두 개의 아이템을 나란히 배치하는 2열 레이아웃을 구성합니다.  
    
```Swift
private func createDoubleSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
    
    let section = NSCollectionLayoutSection(group: group)
    
    return section
}  
```

- 2열 레이아웃: 두 개의 아이템을 가로로 배치하는 그룹입니다.    


---
