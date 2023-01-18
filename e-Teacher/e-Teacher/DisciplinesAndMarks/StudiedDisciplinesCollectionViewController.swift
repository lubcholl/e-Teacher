

import UIKit

private let reuseIdentifier = "Item"
private let columnReuseIdentifier = "ColumnItem"
private let headerIdentifier = "Header"
private let headerKind = "header"

class StudiedDisciplinesCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet weak var layoutButton: UIBarButtonItem!
   
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    private var sections: [Section] = []
    
    enum Layout {
        case grid
        case column
    }
    
    var activeLayout: Layout = .column {
        didSet {
            if let layout = layout[activeLayout] {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                
                collectionView.setCollectionViewLayout(layout, animated: true) { (_) in
                    switch self.activeLayout {
                    case .grid:
                        self.layoutButton.image = UIImage(systemName: "rectangle.grid.1x2")
                    case .column:
                        self.layoutButton.image = UIImage(systemName: "square.grid.2x2")
                    }
                }
            }
        }
    }
    
    var layout: [Layout: UICollectionViewLayout] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMarks), name: NSNotification.Name("ReloadMarks"), object: nil)
        addSwipeBackGesture()
        collectionView.register(DisciplineAndMarksCollectionViewHeader.self, forSupplementaryViewOfKind: headerKind, withReuseIdentifier: headerIdentifier)
        
        layout[.grid]   = generateGridLayout()
        layout[.column] = generateColumnLayout()
        
        if let layout = layout[activeLayout] {
            collectionView.collectionViewLayout = layout
        }
    }
    
    @objc func reloadMarks() {
        updateSections()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateSections()
        collectionView.reloadData()
    }
    
    
    
    func generateColumnLayout() -> UICollectionViewLayout {
        let padding: CGFloat = 10
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            ),
            subitem: item,
            count: 1
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: padding,
            bottom: 0,
            trailing: padding
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = padding

        section.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: 0,
            bottom: padding,
            trailing: 0
        )

        section.boundarySupplementaryItems = [generateHeader()]

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func generateGridLayout() -> UICollectionViewLayout {
        let padding: CGFloat = 20
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/4)
            ),
            subitem: item,
            count: 2
        )
        
        group.interItemSpacing = .fixed(padding)
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: padding,
            bottom: 0,
            trailing: padding
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = padding
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: 0,
            bottom: padding,
            trailing: 0
        )
        
        section.boundarySupplementaryItems = [generateHeader()]

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func generateHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(40)
            ),
            elementKind: headerKind,
            alignment: .top
        )
        
        header.pinToVisibleBounds = true

        return header
    }
    
    func updateSections() {
        sections.removeAll()

        let grouped = Dictionary(grouping: Model.studentDisciplinesNMarks, by: { $0.sectionTitle })
        
        for (title, disciplines) in grouped.sorted(by: { $0.0 < $1.0 }) {
            sections.append(Section(title: "Семестър \(title)", disciplines: disciplines.sorted(by: {$0.semes ?? 0 < $1.semes ?? 0})))
        }
    }
    
    
    @IBAction func activeLayout(_ sender: Any) {
        switch activeLayout {
        case .grid:
            activeLayout = .column
        case .column:
            activeLayout = .grid
        }
    }
    

    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].disciplines.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = activeLayout == .grid ? reuseIdentifier : columnReuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DisciplineAndMAarksCollectionViewCell
        let discipline = sections[indexPath.section].disciplines[indexPath.item]
        cell.update(with: discipline)
        cell.layer.cornerRadius = 25
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! DisciplineAndMarksCollectionViewHeader
        
        header.titleLabel.text = sections[indexPath.section].title
        
        return header
    }

    
    @IBSegueAction func addEditEmoji(_ coder: NSCoder, sender: Any?) -> DisciplineDetailTableViewController? {
        if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            // Editing Emoji
            let chosenDiscipline = sections[indexPath.section].disciplines[indexPath.item]
            return DisciplineDetailTableViewController(coder: coder, discipline: chosenDiscipline)
        } else {
            // Adding Emoji
            return DisciplineDetailTableViewController(coder: coder, discipline: nil)
        }
    }
    
    func indexPath(for discipline: DisciplineAndMarks) -> IndexPath? {
        if let sectionIndex = sections.firstIndex(where: { $0.title == discipline.discname }),
            let index = sections[sectionIndex].disciplines.firstIndex(where: { $0 == discipline })
        {
            return IndexPath(item: index, section: sectionIndex)
        }
        
        return nil
    }
 
}
