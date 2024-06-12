//
//  ContactUsViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit
import MapKit
class ContactUsViewController: UIViewController , Storyboarded {
    @IBOutlet weak var mapView: MKMapView!
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addAnnotation()
    }
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.goBack()
    }
    
    func addAnnotation() {
        let annotationCoordinate = CLLocationCoordinate2D(latitude: 30.0653, longitude: 31.2157)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate
        annotation.title = "El Zamalek"
        annotation.subtitle = "Cairo, Egypt"
        mapView.addAnnotation(annotation)
        zoomInOn(annotation: annotation)
    }
    
    func zoomInOn(annotation: MKPointAnnotation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
