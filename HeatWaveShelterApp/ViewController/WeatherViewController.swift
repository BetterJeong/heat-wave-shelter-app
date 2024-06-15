import UIKit

class WeatherViewController: UIViewController {

    private let temperatureLabel = UILabel()
    private let locationLabel = UILabel()
    private let hourlyForecastView = UIView()
    private let weeklyForecastView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        title = "Weather"
        
        setupViewsAndLayout()
        updateHourlyForecast()
        updateWeeklyForecast()
    }
    
    private func setupViewsAndLayout() {
        // Temperature Label
        temperatureLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        temperatureLabel.textColor = .black
        temperatureLabel.textAlignment = .center
        temperatureLabel.text = "25°C"
        
        // Location Label
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        locationLabel.textColor = .gray
        locationLabel.textAlignment = .center
        locationLabel.text = "Seoul, South Korea"
        
        // Hourly Forecast View
        hourlyForecastView.backgroundColor = .white
        hourlyForecastView.layer.cornerRadius = 10
        hourlyForecastView.layer.shadowColor = UIColor.black.cgColor
        hourlyForecastView.layer.shadowOpacity = 0.1
        hourlyForecastView.layer.shadowOffset = CGSize(width: 0, height: 1)
        hourlyForecastView.layer.shadowRadius = 10
        
        // Weekly Forecast View
        weeklyForecastView.backgroundColor = .white
        weeklyForecastView.layer.cornerRadius = 10
        weeklyForecastView.layer.shadowColor = UIColor.black.cgColor
        weeklyForecastView.layer.shadowOpacity = 0.1
        weeklyForecastView.layer.shadowOffset = CGSize(width: 0, height: 1)
        weeklyForecastView.layer.shadowRadius = 10
        
        // Add subviews
        view.addSubview(hourlyForecastView)
        view.addSubview(weeklyForecastView)
        
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, locationLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastView.translatesAutoresizingMaskIntoConstraints = false
        weeklyForecastView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hourlyForecastView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 60),
            hourlyForecastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hourlyForecastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hourlyForecastView.heightAnchor.constraint(equalToConstant: 100),
            
            weeklyForecastView.topAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: 20),
            weeklyForecastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weeklyForecastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weeklyForecastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Add sample data to hourly forecast view
        let hourlyStackView = createHourlyForecastStackView()
        hourlyForecastView.addSubview(hourlyStackView)
        hourlyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hourlyStackView.topAnchor.constraint(equalTo: hourlyForecastView.topAnchor, constant: 10),
            hourlyStackView.leadingAnchor.constraint(equalTo: hourlyForecastView.leadingAnchor, constant: 10),
            hourlyStackView.trailingAnchor.constraint(equalTo: hourlyForecastView.trailingAnchor, constant: -10),
            hourlyStackView.bottomAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: -10)
        ])
        
        // Add sample data to weekly forecast view
        let weeklyStackView = createWeeklyForecastStackView()
        weeklyForecastView.addSubview(weeklyStackView)
        weeklyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weeklyStackView.topAnchor.constraint(equalTo: weeklyForecastView.topAnchor, constant: 10),
            weeklyStackView.leadingAnchor.constraint(equalTo: weeklyForecastView.leadingAnchor, constant: 10),
            weeklyStackView.trailingAnchor.constraint(equalTo: weeklyForecastView.trailingAnchor, constant: -10),
            weeklyStackView.bottomAnchor.constraint(equalTo: weeklyForecastView.bottomAnchor, constant: -10)
        ])
    }
    
    private func createHourlyForecastStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        // 샘플 데이터를 시간대별 예보 뷰에 추가
        return stackView
    }
    
    private func createHourlyForecastView(time: String, iconName: String, temperature: String, isFirst: Bool) -> UIView {
        let view = UIView()
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textAlignment = .center
        
        let icon = UIImageView()
        icon.image = UIImage(systemName: iconName)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = isFirst ? UIColor(hex: "1E88E5") : UIColor(hex: "BBDEFB")
        
        let tempLabel = UILabel()
        tempLabel.text = temperature
        tempLabel.font = UIFont.systemFont(ofSize: 12)
        tempLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [timeLabel, icon, tempLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    private func createWeeklyForecastStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        // Sample data for weekly forecast
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let icons = ["cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "cloud.bolt.fill", "sun.max.fill", "cloud.sun.fill", "cloud.drizzle.fill"]
        let temperatures = ["26°C / 18°C", "25°C / 17°C", "24°C / 16°C", "23°C / 15°C", "28°C / 20°C", "27°C / 19°C", "26°C / 18°C"]
        
        for (index, day) in days.enumerated() {
            let view = createWeeklyForecastView(day: day, iconName: icons[index], temperature: temperatures[index], isToday: isToday(day))
            stackView.addArrangedSubview(view)
        }
        
        return stackView
    }
    
    private func createWeeklyForecastView(day: String, iconName: String, temperature: String, isToday: Bool) -> UIView {
        let view = UIView()
        
        let dayLabel = UILabel()
        dayLabel.text = day
        dayLabel.font = UIFont.systemFont(ofSize: 14)
        
        let tempStackView = UIStackView()
        tempStackView.axis = .horizontal
        tempStackView.alignment = .center
        tempStackView.spacing = 5
        
        let icon = UIImageView()
        icon.image = UIImage(systemName: iconName)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = isToday ? UIColor(hex: "1E88E5") : UIColor(hex: "BBDEFB")
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let tempLabel = UILabel()
        tempLabel.text = temperature
        tempLabel.font = UIFont.systemFont(ofSize: 14)
        tempLabel.textAlignment = .right
        
        tempStackView.addArrangedSubview(icon)
        tempStackView.addArrangedSubview(tempLabel)
        
        let stackView = UIStackView(arrangedSubviews: [dayLabel, tempStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    private func updateHourlyForecast() {
        let stackView = createHourlyForecastStackView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        let icons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "cloud.bolt.fill"]
        let temperatures = ["25°C", "26°C", "27°C", "28°C", "29°C"]
        
        for hourOffset in 0..<5 {
            let hour = (currentHour + hourOffset) % 24
            let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
            let time = dateFormatter.string(from: date)
            
            let view = createHourlyForecastView(time: time, iconName: icons[hourOffset], temperature: temperatures[hourOffset], isFirst: hourOffset == 0)
            stackView.addArrangedSubview(view)
        }
        
        hourlyForecastView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: hourlyForecastView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: hourlyForecastView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: hourlyForecastView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: -10)
        ])
    }
    
    private func updateWeeklyForecast() {
        let weeklyStackView = createWeeklyForecastStackView()
        
        weeklyForecastView.addSubview(weeklyStackView)
        weeklyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weeklyStackView.topAnchor.constraint(equalTo: weeklyForecastView.topAnchor, constant: 10),
            weeklyStackView.leadingAnchor.constraint(equalTo: weeklyForecastView.leadingAnchor, constant: 10),
            weeklyStackView.trailingAnchor.constraint(equalTo: weeklyForecastView.trailingAnchor, constant: -10),
            weeklyStackView.bottomAnchor.constraint(equalTo: weeklyForecastView.bottomAnchor, constant: -10)
        ])
    }
    
    private func isToday(_ day: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: Date())
        return today == day
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8 * 1) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
