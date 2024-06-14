import UIKit
import MapKit
import CoreLocation

struct Shelter {
    let title: String
    let address: String
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, SearchViewControllerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let mapView = MKMapView()
    let addressButton = UIButton(type: .system)
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var collectionView: UICollectionView!
    
    let shelters = [
        Shelter(title: "쉼터1", address: "서울특별시 종로구 세종대로 110"),
        Shelter(title: "쉼터2", address: "서울특별시 중구 남대문로 5가 63-1"),
        Shelter(title: "쉼터3", address: "서울특별시 용산구 이태원로 29"),
        Shelter(title: "쉼터4", address: "서울특별시 성북구 정릉로 77"),
        Shelter(title: "쉼터5", address: "서울특별시 강남구 테헤란로 521")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#fafcfc")
        
        self.navigationItem.titleView = UIView()
        
        setupMapView()
        setupLocationManager()
        setupAddressButton()
        setupCollectionView()
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
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: view.frame.width - 100, height: 100)
        
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
            collectionView.heightAnchor.constraint(equalToConstant: 100) // 컬렉션 뷰 높이 조정
        ])
    }
    
    @objc func addressButtonTapped() {
        let searchViewController = SearchViewController()
        searchViewController.delegate = self
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    private func addShelterAnnotations() {
        for shelter in shelters {
            geocodeAndAddAnnotation(address: shelter.address, title: shelter.title)
        }
    }
    
    private func geocodeAndAddAnnotation(address: String, title: String) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("주소 변환 오류: \(error)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    let address = "\(placemark.administrativeArea ?? "") \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                    self.addressButton.setTitle(address, for: .normal)
                }
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
        return shelters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let shelter = shelters[indexPath.item]
        cell.configure(with: shelter.title, address: shelter.address)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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
}

class CardCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    
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
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    func configure(with title: String, address: String) {
        titleLabel.text = title
        addressLabel.text = address
    }
}

