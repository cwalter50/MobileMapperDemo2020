//
//  ViewController.swift
//  MobileMapperDemo2020
//
//  Created by Christopher Walter on 11/19/20.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation = CLLocation()
    
    var parks = [MKMapItem]()
    
    var isInitalMapLoaded = true
    var initialRegion = MKCoordinateRegion()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
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
    
    // MARK: MapViewDelegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        // keep the blue dot for userLocation
        if annotation.isEqual(mapView.userLocation)
        {
            return nil
        }
        
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "Image")
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        
        let zoomButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = zoomButton
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        // setup zoomout button
        let buttonPressed = control as! UIButton
        if buttonPressed.buttonType == .contactAdd
        {
            mapView.setRegion(initialRegion, animated: true)
            return
        }
        
        var currentMapItem = MKMapItem()
        if let coordinate = view.annotation?.coordinate {
            for mapItem in parks
            {
                if mapItem.placemark.coordinate.latitude == coordinate.latitude && mapItem.placemark.coordinate.longitude == coordinate.longitude
                {
                    currentMapItem = mapItem
                }
            }
        }
        
        
        let placemark = currentMapItem.placemark
        print(currentMapItem)
        
        if let parkName = placemark.name, let streetNumber = placemark.subThoroughfare, let streetName = placemark.thoroughfare
        {
            let streetAddress = streetNumber + " " + streetName
            let alert = UIAlertController(title: parkName, message: streetAddress, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isInitalMapLoaded
        {
            initialRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isInitalMapLoaded = false
        }
    }
    


    
    

}



