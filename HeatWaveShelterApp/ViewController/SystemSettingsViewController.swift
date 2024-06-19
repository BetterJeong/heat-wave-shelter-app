import UIKit

class SystemSettingsViewController: UIViewController {
    
    private let reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("쉼터 제보하기", for: .normal)
        button.backgroundColor = UIColor(hex: "1E88E5")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        title = " "
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(reportButton)
        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(usageTitleLabel)
        view.addSubview(usageDescriptionLabel)
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        usageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        usageDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
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
        let shelterReportVC = ShelterReportViewController()
        navigationController?.pushViewController(shelterReportVC, animated: true)
    }
}

