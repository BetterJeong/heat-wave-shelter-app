//
//  SearchViewController.swift
//  HeatWaveShelterApp
//
//  Created by 나은정 on 6/11/24.
//

import UIKit
import MapKit

protocol SearchViewControllerDelegate: AnyObject {
    func didSelectLocation(_ location: CLLocationCoordinate2D, name: String)
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    let searchBar = UISearchBar()
    let recentSearchesTableView = UITableView()
    var searchResults: [(name: String, address: String, coordinate: CLLocationCoordinate2D)] = []
    weak var delegate: SearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSearchBar()
        setupRecentSearchesTableView()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "주소 검색"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupRecentSearchesTableView() {
        recentSearchesTableView.delegate = self
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        recentSearchesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recentSearchesTableView)
        
        NSLayoutConstraint.activate([
            recentSearchesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            recentSearchesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentSearchesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recentSearchesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // UISearchBarDelegate 메서드
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(query: searchText)
    }
    
    func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)) // 서울을 중심으로 검색
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.searchResults = response.mapItems.map {
                let name = $0.name ?? "No Name"
                let address = $0.placemark.title ?? "No Address"
                return (name: name, address: address, coordinate: $0.placemark.coordinate)
            }
            self.recentSearchesTableView.reloadData()
        }
    }
    
    // UITableViewDataSource 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.name
        cell.detailTextLabel?.text = result.address
        return cell
    }
    
    // UITableViewDelegate 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLocation = searchResults[indexPath.row].coordinate
        let name = searchResults[indexPath.row].name
        delegate?.didSelectLocation(selectedLocation, name: name)
        navigationController?.popViewController(animated: true)
    }
}
