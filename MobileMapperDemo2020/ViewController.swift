//
//  ViewController.swift
//  MobileMapperDemo2020
//
//  Created by Christopher Walter on 11/19/20.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation = CLLocation()
    
    var parks = [MKMapItem]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func zoomButtonTapped(_ sender: UIBarButtonItem)
    {
        // get region to zoom in on. Each region has a center and a span... So I need a center and span first
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem)
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Parks"
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {
            response, error in
            
            guard let response = response else {
                print("no response")
                return
            }
            for mapItem in response.mapItems {
                self.parks.append(mapItem)
                // add a pin to the map for the park (annotation)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
            
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
//        print(locations)
        
        currentLocation = locations[0]
    }

    
    

}

