import UIKit
import MapKit
import CoreLocation
import SwiftCSV

class HomeViewController: UIViewController, CLLocationManagerDelegate, SearchViewControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let mapView = MKMapView()
    let addressButton = UIButton(type: .system)
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var collectionView: UICollectionView!
    let kakaoApiKey = KeySet.kakaoKey.rawValue
    var administrativeCode: String? {
        didSet {
            if let code = administrativeCode {
                print("법정동 코드 업데이트: \(code)")
            }
        }
    }
    
    var shelters: [Shelter] = []
    var filteredShelters: [Shelter] = []
    
    let facilityTypeDictionary: [String: String] = [
        "1": "노인시설", "2": "복지회관", "3": "마을회관", "4": "보건소",
        "5": "주민센터", "6": "면동사모소", "7": "종교시설", "8": "금융기관",
        "9": "정자", "10": "공원", "11": "정자,파고라", "12": "공원",
        "13": "교량하부", "14": "나무그늘", "15": "하천둔치", "99": "기타"
    ]
    
    let moveToCurrentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("현재 위치", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(moveToCurrentLocationTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        
        self.navigationItem.titleView = UIView()
        
        setupMapView()
        setupLocationManager()
        setupAddressButton()
        setupMoveToCurrentLocationButton()
        setupCollectionView()
        loadShelters()
        addShelterAnnotations()
    }
    
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        mapView.setRegion(MKCoordinateRegion(center: defaultLocation, span: defaultSpanValue), animated: true)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupAddressButton() {
        addressButton.setTitle("현재 위치 확인 중...", for: .normal)
        addressButton.translatesAutoresizingMaskIntoConstraints = false
        addressButton.backgroundColor = .white
        addressButton.setTitleColor(.black, for: .normal)
        addressButton.addTarget(self, action: #selector(addressButtonTapped), for: .touchUpInside)
        addressButton.layer.cornerRadius = 10
        addressButton.layer.shadowColor = UIColor.black.cgColor
        addressButton.layer.shadowOpacity = 0.2
        addressButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addressButton.layer.masksToBounds = false
        self.view.addSubview(addressButton)
        
        NSLayoutConstraint.activate([
            addressButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            addressButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addressButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addressButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupMoveToCurrentLocationButton() {
        view.addSubview(moveToCurrentLocationButton)
        
        NSLayoutConstraint.activate([
            moveToCurrentLocationButton.topAnchor.constraint(equalTo: addressButton.bottomAnchor, constant: 10),
            moveToCurrentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            moveToCurrentLocationButton.widthAnchor.constraint(equalToConstant: 80),
            moveToCurrentLocationButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: view.frame.width - 100, height: 200)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func addressButtonTapped() {
        let searchViewController = SearchViewController()
        searchViewController.delegate = self
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc func moveToCurrentLocationTapped() {
        if let currentLocation = locationManager.location {
            let adjustedCenter = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude - 0.0015, longitude: currentLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: adjustedCenter, span: span)
            mapView.setRegion(region, animated: true)
            updateAddressLabel(for: currentLocation.coordinate)
            updateNearbyShelters(for: currentLocation.coordinate)
        }
    }
    
    private func loadShelters() {
        guard let csvPath = Bundle.main.path(forResource: "shelter_seoul", ofType: "csv") else { return }
        
        do {
            let csv = try CSV<Named>(url: URL(fileURLWithPath: csvPath))
            for row in csv.rows {
                if let title = row["쉼터명칭"],
                   let address = row["도로명주소"],
                   let latString = row["위도"], let latitude = Double(latString),
                   let lonString = row["경도"], let longitude = Double(lonString),
                   let type = row["시설유형"],
                   let capacityString = row["이용가능인원"], let capacity = Int(capacityString),
                   let nightOpenString = row["야간개방"],
                   let holidayOpenString = row["휴일개방"],
                   let lodgingAvailableString = row["숙박가능여부"],
                   let notes = row["비고"] {
                    
                    let nightOpen = nightOpenString == "Y"
                    let holidayOpen = holidayOpenString == "Y"
                    let lodgingAvailable = lodgingAvailableString == "Y"
                    
                    shelters.append(Shelter(title: title, address: address, latitude: latitude, longitude: longitude, type: type, capacity: capacity, nightOpen: nightOpen, holidayOpen: holidayOpen, lodgingAvailable: lodgingAvailable, notes: notes))
                }
            }
        } catch {
            print("CSV 파일을 로드하는 데 실패했습니다: \(error)")
        }
    }
    
    private func addShelterAnnotations() {
        DispatchQueue.main.async {
            for shelter in self.shelters {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
                annotation.title = shelter.title
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func updateAddressLabel(for coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let address = "\(placemark.administrativeArea ?? "") \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                DispatchQueue.main.async {
                    self.addressButton.setTitle(address, for: .normal)
                }
            }
        }
    }
    
    private func updateNearbyShelters(for coordinate: CLLocationCoordinate2D) {
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let nearbyShelters = shelters.filter { shelter in
            let shelterLocation = CLLocation(latitude: shelter.latitude, longitude: shelter.longitude)
            return shelterLocation.distance(from: userLocation) <= 600
        }
        filteredShelters = nearbyShelters.sorted {
            let location1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let location2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        updateAddressLabel(for: center)
        updateNearbyShelters(for: center)
    }
    
    private func getAdministrativeCode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let urlStr = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=\(longitude)&y=\(latitude)"
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(kakaoApiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let documents = json["documents"] as? [[String: Any]],
                   let firstDocument = documents.first,
                   let code = firstDocument["code"] as? String {
                    completion(code)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let adjustedCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.0015, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: adjustedCenter, span: span)
            mapView.setRegion(region, animated: true)
            
            getAdministrativeCode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] bCode in
                guard let self = self else { return }
                self.administrativeCode = bCode
                
                self.updateAddressLabel(for: location.coordinate)
                self.updateNearbyShelters(for: location.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보를 가져오지 못했습니다: \(error)")
    }
    
    func didSelectLocation(_ location: CLLocationCoordinate2D, name: String) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = name
        mapView.addAnnotation(annotation)
        
        self.addressButton.setTitle(name, for: .normal)
        self.updateNearbyShelters(for: location)
    }
    
    func didSelectFavoriteShelter(_ shelter: Shelter) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
        annotation.title = shelter.title
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .blue
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredShelters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let shelter = filteredShelters[indexPath.item]
        cell.configure(with: shelter, typeDictionary: facilityTypeDictionary)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShelter = filteredShelters[indexPath.item]
        moveToShelterLocation(shelter: selectedShelter)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sideInset = CGFloat(20)
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    private func moveToShelterLocation(shelter: Shelter) {
        let coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = shelter.title
        mapView.addAnnotation(annotation)
    }
}

class CardCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let typeLabel = UILabel()
    private let capacityLabel = UILabel()
    private let nightOpenLabel = UILabel()
    private let holidayOpenLabel = UILabel()
    private let lodgingAvailableLabel = UILabel()
    private let notesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.masksToBounds = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        addressLabel.font = UIFont.systemFont(ofSize: 16)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressLabel)
        
        typeLabel.font = UIFont.systemFont(ofSize: 14)
        typeLabel.textColor = .gray
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLabel)
        
        capacityLabel.font = UIFont.systemFont(ofSize: 14)
        capacityLabel.textColor = .gray
        capacityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(capacityLabel)
        
        nightOpenLabel.font = UIFont.systemFont(ofSize: 14)
        nightOpenLabel.textColor = .gray
        nightOpenLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nightOpenLabel)
        
        holidayOpenLabel.font = UIFont.systemFont(ofSize: 14)
        holidayOpenLabel.textColor = .gray
        holidayOpenLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(holidayOpenLabel)
        
        lodgingAvailableLabel.font = UIFont.systemFont(ofSize: 14)
        lodgingAvailableLabel.textColor = .gray
        lodgingAvailableLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lodgingAvailableLabel)
        
        notesLabel.font = UIFont.systemFont(ofSize: 14)
        notesLabel.textColor = .gray
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notesLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            capacityLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            capacityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            capacityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nightOpenLabel.topAnchor.constraint(equalTo: capacityLabel.bottomAnchor, constant: 5),
            nightOpenLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nightOpenLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            holidayOpenLabel.topAnchor.constraint(equalTo: nightOpenLabel.bottomAnchor, constant: 5),
            holidayOpenLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            holidayOpenLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lodgingAvailableLabel.topAnchor.constraint(equalTo: holidayOpenLabel.bottomAnchor, constant: 5),
            lodgingAvailableLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lodgingAvailableLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesLabel.topAnchor.constraint(equalTo: lodgingAvailableLabel.bottomAnchor, constant: 5),
            notesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with shelter: Shelter, typeDictionary: [String: String]) {
        titleLabel.text = shelter.title
        addressLabel.text = shelter.address
        typeLabel.text = "유형: \(typeDictionary[shelter.type] ?? shelter.type)"
        capacityLabel.text = "이용가능인원: \(shelter.capacity)명"
        nightOpenLabel.text = "야간개방: \(shelter.nightOpen ? "개방" : "안 함")"
        holidayOpenLabel.text = "휴일개방: \(shelter.holidayOpen ? "개방" : "안 함")"
        lodgingAvailableLabel.text = "숙박가능여부: \(shelter.lodgingAvailable ? "가능" : "불가능")"
    }
}

