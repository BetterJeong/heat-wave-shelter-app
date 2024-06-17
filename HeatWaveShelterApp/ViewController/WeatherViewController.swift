import UIKit

struct CurrentWeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherDetail]
    let name: String
}

struct ForecastWeatherResponse: Codable {
    let list: [Forecast]
    let city: City
}

struct MainWeather: Codable {
    let temp: Double
}

struct WeatherDetail: Codable {
    let description: String
    let icon: String
}

struct Forecast: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherDetail]
    let dt_txt: String
}

struct City: Codable {
    let name: String
}

struct SpecialWeatherWarningResponse: Codable {
    let response: SpecialWeatherWarningBody
}

struct SpecialWeatherWarningBody: Codable {
    let body: SpecialWeatherWarningItems
}

struct SpecialWeatherWarningItems: Codable {
    let items: [SpecialWeatherWarningItem]
}

struct SpecialWeatherWarningItem: Codable {
    let title: String
    let tmFc: String
}

class WeatherViewController: UIViewController {

    private let temperatureLabel = UILabel()
    private let locationLabel = UILabel()
    private let hourlyForecastView = UIView()
    private let weeklyForecastView = UIView()
    private let alertLabel = UILabel()
    
    private let openWeatherKey = KeySet.openWeatherKey.rawValue
    private let specialWeatherWarningKey = KeySet.publicKey.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        title = "Weather"
        
        setupViewsAndLayout()
        fetchCurrentWeather()
        fetchForecastWeather()
        fetchSpecialWeatherWarnings()
    }
    
    private func setupViewsAndLayout() {
        alertLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        alertLabel.textColor = .red
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        alertLabel.backgroundColor = .yellow.withAlphaComponent(0.8)
        alertLabel.layer.cornerRadius = 5
        alertLabel.layer.masksToBounds = true
        
        temperatureLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        temperatureLabel.textColor = .black
        temperatureLabel.textAlignment = .center
        
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        locationLabel.textColor = .gray
        locationLabel.textAlignment = .center
        
        hourlyForecastView.backgroundColor = .white
        hourlyForecastView.layer.cornerRadius = 10
        hourlyForecastView.layer.shadowColor = UIColor.black.cgColor
        hourlyForecastView.layer.shadowOpacity = 0.1
        hourlyForecastView.layer.shadowOffset = CGSize(width: 0, height: 1)
        hourlyForecastView.layer.shadowRadius = 10
        
        weeklyForecastView.backgroundColor = .white
        weeklyForecastView.layer.cornerRadius = 10
        weeklyForecastView.layer.shadowColor = UIColor.black.cgColor
        weeklyForecastView.layer.shadowOpacity = 0.1
        weeklyForecastView.layer.shadowOffset = CGSize(width: 0, height: 1)
        weeklyForecastView.layer.shadowRadius = 10
        
        view.addSubview(alertLabel)
        view.addSubview(hourlyForecastView)
        view.addSubview(weeklyForecastView)
        
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, locationLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastView.translatesAutoresizingMaskIntoConstraints = false
        weeklyForecastView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            alertLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            alertLabel.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.topAnchor.constraint(equalTo: alertLabel.bottomAnchor, constant: 60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hourlyForecastView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 80),
            hourlyForecastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hourlyForecastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hourlyForecastView.heightAnchor.constraint(equalToConstant: 100),
            
            weeklyForecastView.topAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: 20),
            weeklyForecastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weeklyForecastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weeklyForecastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchCurrentWeather() {
        print("Starting network request for current weather...")
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=37.5665&lon=126.9780&units=metric&appid=\(openWeatherKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                print("Data received, attempting to decode JSON...")
                let weatherResponse = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
                print("JSON decoding successful")
                print("Current weather response: \(weatherResponse)")
                DispatchQueue.main.async {
                    self.updateCurrentWeatherUI(with: weatherResponse)
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    private func fetchForecastWeather() {
        print("Starting network request for forecast weather...")
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=37.5665&lon=126.9780&units=metric&appid=\(openWeatherKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                print("Data received, attempting to decode JSON...")
                let weatherResponse = try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
                print("JSON decoding successful")
                print("Forecast weather response: \(weatherResponse)")
                DispatchQueue.main.async {
                    self.updateForecastWeatherUI(with: weatherResponse)
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    private func fetchSpecialWeatherWarnings() {
        print("Starting network request for special weather warnings...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let calendar = Calendar.current
        let toDate = Date()
        let fromDate = calendar.date(byAdding: .day, value: -3, to: toDate)!
        
        let fromTmFc = dateFormatter.string(from: fromDate)
        let toTmFc = dateFormatter.string(from: toDate)
        
        let urlString = "http://apis.data.go.kr/1360000/WthrWrnInfoService/getWthrWrnList?serviceKey=\(specialWeatherWarningKey)&numOfRows=10&pageNo=1&stnId=108&fromTmFc=\(fromTmFc)&toTmFc=\(toTmFc)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                print("Data received, attempting to decode XML...")
                let parser = XMLParser(data: data)
                let xmlDelegate = SpecialWeatherWarningParserDelegate()
                parser.delegate = xmlDelegate
                
                if parser.parse() {
                    let warnings = xmlDelegate.warnings
                    print("XML parsing successful")
                    DispatchQueue.main.async {
                        self.updateAlertLabel(with: warnings)
                    }
                } else {
                    print("XML parsing failed")
                }
            } catch {
                print("XML parsing error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    private func updateCurrentWeatherUI(with weatherResponse: CurrentWeatherResponse) {
        print("Updating UI with current weather data...")
        temperatureLabel.text = "\(Int(weatherResponse.main.temp))°C"
        locationLabel.text = weatherResponse.name
    }
    
    private func updateForecastWeatherUI(with weatherResponse: ForecastWeatherResponse) {
        print("Updating UI with forecast weather data...")
        
        updateHourlyForecast(with: weatherResponse.list)
        
        updateWeeklyForecast(with: weatherResponse.list)
    }
    
    private func updateAlertLabel(with warnings: [SpecialWeatherWarningItem]) {
        if warnings.isEmpty {
            alertLabel.text = "현재 특보가 없습니다."
        } else {
            let warningMessages = warnings.map { warning -> String in
                let titleComponents = warning.title.split(separator: "/")
                let title = titleComponents.last?.replacingOccurrences(of: "(*)", with: "").trimmingCharacters(in: .whitespaces) ?? ""
                let dateTime = formatDateString(warning.tmFc)
                return "[특보] \(title) (\(dateTime))"
            }
            alertLabel.text = warningMessages.joined(separator: "\n")
        }
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private func createHourlyForecastStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
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
    
    private func updateHourlyForecast(with hourlyWeather: [Forecast]) {
        print("Updating hourly forecast...")
        let stackView = createHourlyForecastStackView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let nearestHour = (currentHour / 3) * 3
        
        let nearestHourIndex = hourlyWeather.firstIndex { forecast in
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let forecastHour = calendar.component(.hour, from: forecastDate)
            return forecastHour == nearestHour
        } ?? 0
        
        let start = max(0, nearestHourIndex)
        let end = min(hourlyWeather.count, start + 6)
        
        for hourOffset in start..<end {
            let weather = hourlyWeather[hourOffset]
            let date = Date(timeIntervalSince1970: TimeInterval(weather.dt))
            let time = dateFormatter.string(from: date)
            
            print("Hour \(hourOffset): \(time) - \(weather.main.temp)°C - Icon: \(weather.weather.first?.icon ?? "N/A")")
            
            let view = createHourlyForecastView(time: time, iconName: getWeatherIconName(for: weather.weather.first?.icon ?? "cloud.fill"), temperature: "\(Int(weather.main.temp))°C", isFirst: hourOffset == start)
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
    
    private func createWeeklyForecastStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
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
    
    private func updateWeeklyForecast(with dailyWeather: [Forecast]) {
        print("Updating weekly forecast...")
        let weeklyStackView = createWeeklyForecastStackView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        var daysDisplayed = Set<String>()
        
        for (index, daily) in dailyWeather.enumerated() where index % 8 == 0 && daysDisplayed.count < 7 {
            let date = Date(timeIntervalSince1970: TimeInterval(daily.dt))
            let day = dateFormatter.string(from: date)
            
            if !daysDisplayed.contains(day) {
                daysDisplayed.insert(day)
                print("Day: \(day) - \(daily.main.temp))°C - Icon: \(daily.weather.first?.icon ?? "N/A")")
                
                let view = createWeeklyForecastView(day: day, iconName: getWeatherIconName(for: daily.weather.first?.icon ?? "cloud.fill"), temperature: "\(Int(daily.main.temp))°C", isToday: isToday(day))
                weeklyStackView.addArrangedSubview(view)
            }
        }
        
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
    
    private func getWeatherIconName(for icon: String) -> String {
        switch icon {
        case "01d":
            return "sun.max.fill"
        case "01n":
            return "moon.fill"
        case "02d":
            return "cloud.sun.fill"
        case "02n":
            return "cloud.moon.fill"
        case "03d", "03n":
            return "cloud.fill"
        case "04d", "04n":
            return "smoke.fill"
        case "09d", "09n":
            return "cloud.drizzle.fill"
        case "10d":
            return "cloud.sun.rain.fill"
        case "10n":
            return "cloud.moon.rain.fill"
        case "11d", "11n":
            return "cloud.bolt.fill"
        case "13d", "13n":
            return "snow"
        case "50d", "50n":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
}

class SpecialWeatherWarningParserDelegate: NSObject, XMLParserDelegate {
    var warnings: [SpecialWeatherWarningItem] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentTmFc = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "tmFc":
            currentTmFc += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let warning = SpecialWeatherWarningItem(title: currentTitle, tmFc: currentTmFc)
            warnings.append(warning)
            currentTitle = ""
            currentTmFc = ""
        }
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

