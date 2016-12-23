//
//  InitViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 18/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit

class InitViewController: UIViewController, XMLParserDelegate {
    
    // MODEL
    // Datos XML de la playa
    var beachXML: BeachXMLModel?
    
    // Contenido de la linea actual del XMLParser
    var currentContent = String()
    
    // Playa mas cercana
    var nearestBeach: Beach? {
        didSet {
            if nearestBeach == nil {
                // Avisamos de que no se ha podido obtener la playa mas cercana
            }
        }
    }

    // Action de botón de favorito
    @IBAction func goToFavourites(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.initToFav, sender: sender)
    }
    
    // Outlet de boton de favoritos
    @IBOutlet weak var favouritesButton: UINavigationItem!
    
    // Barra de busqueda
    @IBOutlet weak var searchBeachBar: UISearchBar!
    
    // Imagen de la playa
    @IBOutlet weak var beachImage: UIImageView!
    
    // Label con temperatura de la playa
    @IBOutlet weak var tempLabel: UILabel!
    
    // Label con nombre playa
    @IBOutlet weak var nameBeachLabel: UILabel!
    
    // Label correspondiente al nombre de la ciudad donde esta la playa
    @IBOutlet weak var cityBeachLabel: UILabel!
    
    // Label con velocidad del viento
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    // Label con la marea
    @IBOutlet weak var swellLabel: UILabel!
    
    // Label con UV
    @IBOutlet weak var UVLabel: UILabel!
    
    // Label con temperatura de agua
    @IBOutlet weak var waterTempLabel: UILabel!
    
    // ImageView con el estado de las playas
    @IBOutlet weak var stateImage: UIImageView!
    
    // Table view de las grandez zonas
    @IBOutlet weak var beachBigZoneTableView: UITableView!
    
    // Vista con los datos de la playa mas cercna
    @IBOutlet weak var showDataCompositionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.showDataCompositionView.sendSubview(toBack: beachImage)
        getAemetXML(beachCode: (nearestBeach?.webCode)!)
        setNearestBeachUIData()
        initTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setNearestBeachUIData() {
        self.stateImage.image = getStateImage(withCode: beachXML?.prediction?[0].skyState?[0].f)
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        self.nameBeachLabel?.text = (nearestBeach?.name) ?? "Error"
        self.cityBeachLabel?.text = (nearestBeach?.city) ?? "Error"
        self.tempLabel?.text =  String(describing: (beachXML?.prediction?[0].maxTemp)!)+"º"
        self.windSpeedLabel?.text = "Wind: " +
            getWindString(withCode: beachXML!.prediction?[0].wind?[0].f)
        self.swellLabel?.text = "Swell: " + getSwellString(withCode: beachXML?.prediction?[0].swell?[0].f)
        self.waterTempLabel?.text = "Water temperature: " + (beachXML?.prediction![0].waterTemp!.description)!
        self.UVLabel?.text = "Max UV: " + String(describing: (beachXML?.prediction?[0].maxUV)!)
    }
    
    func getStateImage(withCode: Int?) -> UIImage {
        
        let code = withCode ?? -1
        
        switch code {
        case 100:
            return #imageLiteral(resourceName: "wi_sun")
        case 110:
            return #imageLiteral(resourceName: "wi_partly_cloudy")
        case 120:
            return #imageLiteral(resourceName: "wi_cloudy")
        case 130:
            return #imageLiteral(resourceName: "wi_partly_cloudy_rain")
        case 140:
            return #imageLiteral(resourceName: "wi_rain")
        default:
            return #imageLiteral(resourceName: "error")
        }
        
    }

    private func getAemetXML(beachCode: String) {
        // URL Tipo
        // http://www.aemet.es/xml/playas/play_v2_3003605.xml
        print(AemetURL.url + beachCode + AemetURL.type)
        beachXML = BeachXMLModel(with: beachCode)
        beachXML?.parser()
    }
    
    private func initTableView() {
    
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
