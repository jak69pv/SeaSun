//
//  MapRoadToViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import MapKit

class MapRoadToViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

   
    // Playa a mostrar recorrido
    var goToBeach: Beach?
    
    // Outlet del mapa
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private var sourceLocation: CLLocationCoordinate2D? {
        didSet{
            // Paramos el monitoreo
            locationManager.stopUpdatingLocation()
            drawRoute()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }
    

    
    private func drawRoute() {
        // Obtenemos coordenadas de destino
        let destinationLocation = CLLocationCoordinate2D(
            latitude: goToBeach!.lat, longitude: goToBeach!.long)
        
        // Creamos los placemark
        let sourcePlacemark = MKPlacemark(coordinate: self.sourceLocation!, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // Creamos los map item, usados para enrutar
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Creamos las anotaciones, nos aseguraos de que 
        // las coordenadas son alcanzables y las añadimos al mapa
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = labelsText.currentLocation
        
        if let sLocation = sourcePlacemark.location {
            sourceAnnotation.coordinate = sLocation.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = goToBeach!.name
        
        if let dLocation = destinationPlacemark.location {
            destinationAnnotation.coordinate = dLocation.coordinate
        }
        
        // Las mostramos en el mapa
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        // Inicializamos la ruta a crear
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculamos la direccion 
        let directions = MKDirections(request: directionRequest)
        
        // Dibujamos la ruta
        directions.calculate { (response, error) in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        
            
        }
        
    }
    
    // Metedo que retorna la linea de mapa para renderizar
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    private func activateLocalization() {
        // Preguntamos por la autorización de localizacion
        self.locationManager.requestAlwaysAuthorization()
        
        // Para usar en segundo plano
        locationManager.requestWhenInUseAuthorization()
        
        // Si tenemos permiso
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            // Precisión. Bajar para disminuir gasto de bateria
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
    }
    
    // Obtener localizacion
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        self.sourceLocation = userLocation.coordinate
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
