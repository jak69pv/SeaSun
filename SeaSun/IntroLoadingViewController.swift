//
//  IntroLoadingViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 18/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Darwin

class IntroLoadingViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK -- Model
    
    // perc. de la estimación actual para mostrar barra de carga
    private struct progressPercentage {
        static let initialization: Float = 0.0
        static let localizationLoaded: Float = 0.55
        static let nextBeachPrepared: Float = 1.0
    }
    
    @IBOutlet weak var logoIW: UIImageView!
    
    // Gestor de localización del usuario
    private let locationManager = CLLocationManager()
    
    // Variable de localización
    private var localizationPoint: CLLocationCoordinate2D? {
        didSet {
            // -- TEST --
            print(localizationPoint.debugDescription)
            // Paramos el monitoreo
            locationManager.stopUpdatingLocation()
            if !nearestBeachGetted {
                InitialProgressView.setProgress(progressPercentage.localizationLoaded,animated: true)
                // Buscamos la playa mas cercana con la nueva localizacion
                
                if let _beaches = searchAllBeaches() {
                    beaches = _beaches
                    let nearBeach = DispatchWorkItem() {
                        if let _nearestBeach = self.searchNearestBeach(_beaches) {
                            self.nearestBeach = _nearestBeach
                        }
                    }
                    serialQueue.sync(execute: nearBeach)
                    InitialProgressView.setProgress(progressPercentage.nextBeachPrepared,animated: true)
                    print("La mas cercana es \(nearestBeach?.name)")
                    print("situada en \(nearestBeach?.city)")
                    print("En lat \(nearestBeach?.lat)")
                    print("Y long \(nearestBeach?.long)")
                    nearestBeachGetted = true
                    performSegue()
                }
            }
        }
    }
    
    //Playa mas cercana
    var nearestBeach : Beach?
    
    // Todas las playas
    var beaches: [Beach]?
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.stack.context

    // Barra de inicio
    @IBOutlet weak var InitialProgressView: UIProgressView!
    
    // Hilo para hacer tareas de manera en serie
    let serialQueue = DispatchQueue(label: "serialQueue")
    
    // Variable parea eliminar lo de hacer dos veces la currentloc
    var nearestBeachGetted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initApp()
    }
    
    private func initApp() {
        logoIW.image = #imageLiteral(resourceName: "seaSunIcon")
        logoIW.contentMode = .scaleAspectFill
        InitialProgressView.setProgress(progressPercentage.initialization,animated: true)
        let activate = DispatchWorkItem() { self.activateLocalization() }
        serialQueue.sync(execute: activate)
    }
    
    private func performSegue() {
        // Presentamos el Main.storyboard
        let storyboard = self.storyboard
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextInitView: InitViewController = storyboard?.instantiateViewController(withIdentifier: "InitViewController") as! InitViewController
        nextInitView.nearestBeach = nearestBeach
        // Inicializamos el view controller y le pasamos el VC
        let navigationController = UINavigationController(rootViewController: nextInitView)
        self.present(navigationController, animated: true, completion: nil)
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
    
    
    private func searchNearestBeach(_ allBeaches: [Beach]) -> Beach? {
        let currentLat = localizationPoint?.latitude
        let currentLong = localizationPoint?.longitude
        var currentNearestBeach : Beach?
        var count = 0
        // Hacemos la búsqueda de las playas mas cercanas en la BBDD
        if let allBeaches = searchAllBeaches() {
            var minHaversine: Double = DBL_MAX
            // Recorreremos todas las playas para buscar la mas cercana
            for beach in allBeaches {
                let currentHaversine = haversineInKilometers(
                    currentLat: currentLat!,
                    currentLong: currentLong!,
                    latToCompare: beach.lat,
                    longToCompare: beach.long
                )
                count += 1
                
                if currentHaversine < minHaversine {
                    minHaversine = currentHaversine
                    currentNearestBeach = beach
                }
            }
        }
        print("Hemos analizado un total de \(count) playas")
        return currentNearestBeach
        
    }
    
    private func searchAllBeaches() -> [Beach]?  {
        var allBeaches = [Beach]()
        managedObjectContext?.performAndWait {
            let fetchRequest = NSFetchRequest<Beach>(entityName: "Beach")
            do {
                let allBeaches__ = try self.managedObjectContext?.fetch(fetchRequest)
                allBeaches = allBeaches__!

            } catch let error{
                print("Error retrieve beaches: \(error)")
            }
        }
        return allBeaches
    }
    
    // Calculo de la distancia entre dos puntos mediante su latitud y longitud
    private func haversineInKilometers(currentLat: Double, currentLong: Double, latToCompare: Double, longToCompare: Double) -> Double {
        let distanceToRadius = M_PI / 180.0
        let dLat = (latToCompare - currentLat) * distanceToRadius
        let dLong = (longToCompare - currentLong) * distanceToRadius
        let a = pow(sin(dLat/2.0), 2)
            + cos(currentLat * distanceToRadius)
            * cos(latToCompare * distanceToRadius)
            * pow(sin(dLong/2.0), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let distance = 6367 * c
        
        return distance
    }
    
    // Obtener localizacion
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        localizationPoint = userLocation.coordinate
    }
    
    // En el prepare for segue tendremos que tener lista la localización actual

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.introToInit {
            // Hemos usado la extension de abajo
            if let ivc = segue.destination as? InitViewController {
                // Pasamos la playa mas cercana
                ivc.nearestBeach = nearestBeach
            }
        }    
    }*/
 

}
