import UIKit

protocol SystemSettingsViewControllerDelegate: AnyObject {
    func didSelectFavoriteShelter(_ shelter: Shelter)
}

class SystemSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SystemSettingsViewControllerDelegate?
    
    private let reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("쉼터 제보하기", for: .normal)
        button.backgroundColor = UIColor(hex: "1E88E5")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let favoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기한 쉼터"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let favoritesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        return tableView
    }()
    
    private let favoriteShelters = [
        Shelter(title: "쉼터1", address: "서울특별시 종로구 세종대로 110"),
        Shelter(title: "쉼터2", address: "서울특별시 중구 남대문로 5가 63-1"),
        Shelter(title: "쉼터3", address: "서울특별시 용산구 이태원로 29"),
        Shelter(title: "쉼터4", address: "서울특별시 성북구 정릉로 77"),
        Shelter(title: "쉼터5", address: "서울특별시 강남구 테헤란로 521")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        title = "System Settings"
        
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        setupLayout()
        
        // Configure table view appearance
        favoritesTableView.layer.cornerRadius = 10
        favoritesTableView.layer.shadowColor = UIColor.black.cgColor
        favoritesTableView.layer.shadowOpacity = 0.1
        favoritesTableView.layer.shadowOffset = CGSize(width: 0, height: 1)
        favoritesTableView.layer.shadowRadius = 10
    }
    
    private func setupLayout() {
        view.addSubview(reportButton)
        view.addSubview(favoritesLabel)
        view.addSubview(favoritesTableView)
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportButton.heightAnchor.constraint(equalToConstant: 50),
            
            favoritesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            favoritesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            favoritesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            favoritesTableView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 15),
            favoritesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            favoritesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoritesTableView.bottomAnchor.constraint(equalTo: reportButton.topAnchor, constant: -20)
        ])
    }
    
    @objc private func reportButtonTapped() {
        // Report button action
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteShelters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        
        let shelter = favoriteShelters[indexPath.row]
        
        // Create custom labels for title and address
        let titleLabel = UILabel()
        titleLabel.text = shelter.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let addressLabel = UILabel()
        addressLabel.text = shelter.address
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .gray
        
        // Create a vertical stack view to hold the labels
        let stackView = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        
        cell.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedShelter = favoriteShelters[indexPath.row]
        delegate?.didSelectFavoriteShelter(selectedShelter)
        navigationController?.popViewController(animated: true)
    }
}
