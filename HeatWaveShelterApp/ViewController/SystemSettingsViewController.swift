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
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let favoritesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        return tableView
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "무더위 쉼터란 무엇인가요?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "노인·어린이·취약계층이 시원한 여름을 보낼 수 있도록 언제든 자유롭게 머무를 수 있는 경로당, 마을회관, 주민센터, 아동센터 등 시설을 말합니다."
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let usageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 대상"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private let usageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        - 폭염 및 한파에 취약한 노인과 거동이 불편하거나 신체가 허약한 사람
        - 무더위 및 추위에 장기간 노출된 사람
        - 상기의 사람을 보호하는 보호자
        - 폭염 및 한파에 취약한 사람을 보호·관리하는 재난도우미 등
        """
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let favoriteShelters: [[String: Any]] = [
        ["title": "쉼터1", "address": "서울특별시 종로구 세종대로 110", "latitude": 37.5663, "longitude": 126.9779, "type": "1", "capacity": 100, "nightOpen": true, "holidayOpen": true, "lodgingAvailable": false, "notes": "예시 비고"],
        ["title": "쉼터2", "address": "서울특별시 중구 남대문로 5가 63-1", "latitude": 37.5600, "longitude": 126.9758, "type": "1", "capacity": 150, "nightOpen": true, "holidayOpen": false, "lodgingAvailable": false, "notes": "예시 비고"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        title = "System Settings"
        
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        setupLayout()
        
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
        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(usageTitleLabel)
        view.addSubview(usageDescriptionLabel)
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesTableView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        usageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        usageDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoritesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            favoritesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            favoritesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            favoritesTableView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 15),
            favoritesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            favoritesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoritesTableView.heightAnchor.constraint(equalToConstant: 280),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: favoritesTableView.bottomAnchor, constant: 20),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            usageTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            usageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            usageDescriptionLabel.topAnchor.constraint(equalTo: usageTitleLabel.bottomAnchor, constant: 5),
            usageDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usageDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportButton.heightAnchor.constraint(equalToConstant: 50),
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
        
        let titleLabel = UILabel()
        titleLabel.text = shelter["title"] as? String
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let addressLabel = UILabel()
        addressLabel.text = shelter["address"] as? String
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .gray
        
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
        guard let title = selectedShelter["title"] as? String,
              let address = selectedShelter["address"] as? String,
              let latitude = selectedShelter["latitude"] as? Double,
              let longitude = selectedShelter["longitude"] as? Double,
              let type = selectedShelter["type"] as? String,
              let capacity = selectedShelter["capacity"] as? Int,
              let nightOpen = selectedShelter["nightOpen"] as? Bool,
              let holidayOpen = selectedShelter["holidayOpen"] as? Bool,
              let lodgingAvailable = selectedShelter["lodgingAvailable"] as? Bool,
              let notes = selectedShelter["notes"] as? String else {
            return
        }
        
        let shelter = Shelter(title: title, address: address, latitude: latitude, longitude: longitude, type: type, capacity: capacity, nightOpen: nightOpen, holidayOpen: holidayOpen, lodgingAvailable: lodgingAvailable, notes: notes)
        delegate?.didSelectFavoriteShelter(shelter)
        navigationController?.popViewController(animated: true)
    }
}

