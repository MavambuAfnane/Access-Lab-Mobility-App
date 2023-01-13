//
//  ViewController.swift
//  Tab_Bar
//
//  Created by Afnane Mavambu on 12/12/2022.
//

import UIKit
import MapKit
import CoreLocation
import Combine
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    
    var items = [String]()
    var textField = UITextField()
    var changeTextField : UITextField?
    var completition : ((CLLocation) -> Void)?
    var resultSearchController:UISearchController? = nil
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var mapLocation: MKMapView!
    @IBOutlet weak var mapRestaurant: MKMapView!
    @IBOutlet weak var mapTransport: MKMapView!
    
    //     Search for an address
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: false, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Chargement
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Request of search
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            
            if response == nil
            {
                print("Error")
            } else {
                //Delete back annotations
                let annotations = self.map.annotations
                self.map.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.map.addAnnotation(annotation)
                
                //Zoom in on annotation
                let cordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                let region = MKCoordinateRegion(center: cordinate, span: span)
                self.map.setRegion(region, animated: true)
                
            }
        }
    }
    
    @IBOutlet var list: UITableView!
    
    let Manager = CLLocationManager()
    
    
    @IBOutlet weak var geocoding: UILabel!
    

    
//    Localisation
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation] ) {
        if let location = locations.first {
            Manager.stopUpdatingLocation()
            
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        
        if map != nil {
            map.setRegion(region, animated: true)
            self.map.showsUserLocation = true
        }
        
        if mapLocation != nil {
            mapLocation.setRegion(region, animated: true)
            self.mapLocation.showsUserLocation = true
        }
        
        if mapRestaurant != nil {
            mapRestaurant.setRegion(region, animated: true)
            self.mapRestaurant.showsUserLocation = true
            mapRestaurant.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant])

        }
        
        if mapTransport != nil {
            mapTransport.setRegion(region, animated: true)
            self.mapTransport.showsUserLocation = true
            mapTransport.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])

        }

        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil {
                print("ERREUR")
            } else {
                if let place = placemark?[0] {
                    if self.mapLocation != nil {
                        self.geocoding.text = "\(String(describing: place.subThoroughfare!)) \(String(describing: place.thoroughfare!)) \(String(describing: place.subLocality!)) \(String(describing: place.locality!)) \(String(describing: place.country!))"
                    }
                }
            }
        }
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource, ObservableObject {
    
    
    @IBAction func poiButton(_ sender: Any) {
        let searchPoi = UISearchController(searchResultsController: nil)
        searchPoi.searchBar.delegate = self
        present(searchPoi, animated: false, completion: nil)
    }
    
    
    //    List of favourites
    @IBAction func addButton(_ sender: UIBarButtonItem) {
                    
        let alert = UIAlertController(title: "Ajoutez une adresse", message: "", preferredStyle: .alert)
            
        let cancel = UIAlertAction(title: "Annuler", style: .default) { (cancel) in
        }
            
        let save = UIAlertAction(title: "Sauvegarder", style: .default) { (save) in
                
            self.items.append(self.textField.text!)
                
            self.list.reloadData()
                
        }
            
        alert.addTextField { (text) in
            self.textField = text
            self.textField.placeholder = "Ajouter une nouvelle adresse"
        }
        alert.addAction(cancel)
        alert.addAction(save)
            
        self.present(alert, animated: true, completion: nil)
    }
    
    //Add adress
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellule = tableView.dequeueReusableCell(withIdentifier: "cellule", for: indexPath)
        cellule.textLabel?.text = items[indexPath.row]
        
        return cellule
    }
    
    //Delete adress
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            
            items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
        }
    }
    
    //Edit adress
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Modifier", message: "Modifier votre adresse", preferredStyle: .alert)
        
        let update = UIAlertAction(title: "Modifier", style: .default) { action in
            
            let updateItems = self.changeTextField?.text
            self.items[indexPath.row] = updateItems!
            
            DispatchQueue.main.async {
                
                self.list.reloadData()
                print("Boutton de modification")
            }
        }
        
        let cancel = UIAlertAction(title: "Annuler", style: .cancel) { action in
            print("Cancel btnTapped")
        }
        
        alert.addAction(update)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            self.changeTextField = textField
            self.changeTextField?.text = self.items[indexPath.row]
            self.changeTextField?.placeholder = "Modification de l'adresse"
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        showsPointsOfInterest()
        if list != nil {
            list.delegate = self
            list.dataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Manager.requestWhenInUseAuthorization()
        Manager.desiredAccuracy = kCLLocationAccuracyBest
        Manager.delegate = self
        Manager.startUpdatingLocation()
    }
    
}

