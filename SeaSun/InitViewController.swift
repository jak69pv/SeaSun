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
    
    // Datos de ese dia
    var dayData: DayXMLData?
    // Datos de los dos dias
    var prediction: [DayXMLData]?
    // Datos de origen 
    var origin: Origin?
    
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
        self.stateImage.image = BeachXMLModel.getStateImage(withCode: beachXML?.prediction?[0].skyState?[0].f)
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        self.nameBeachLabel?.text = (nearestBeach?.name) ?? "Error"
        self.cityBeachLabel?.text = (nearestBeach?.city) ?? "Error"
        self.tempLabel?.text =  String(describing: (beachXML?.prediction?[0].maxTemp)!)+"º"
        self.windSpeedLabel?.text = "Wind: " +
            BeachXMLModel.getWindString(withCode: beachXML?.prediction?[0].wind?[0].f)
        self.swellLabel?.text = "Swell: " + BeachXMLModel.getSwellString(withCode: beachXML?.prediction?[0].swell?[0].f)
        self.waterTempLabel?.text = "Water temperature: " + (beachXML?.prediction![0].waterTemp!.description)!
        self.UVLabel?.text = "Max UV: " + String(describing: (beachXML?.prediction?[0].maxUV)!)
    }

    
    private func getAemetXML(beachCode: String) {
        // URL Tipo
        // http://www.aemet.es/xml/playas/play_v2_3003605.xml
        print(AemetURL.url + beachCode + AemetURL.type)
        guard let beachURL = URL(string: AemetURL.url + beachCode + AemetURL.type) else {
            print("URL not defined properly")
            return
        }
        guard let parser = XMLParser(contentsOf: beachURL) else {
            print("Cannot Read Data")
            return
        }
        parser.delegate = self
        if !parser.parse(){
            print("Data Errors Exist:")
            let error = parser.parserError!
            print("Error Description:\(error.localizedDescription)")
            print("Line number: \(parser.lineNumber)")
        }
    }
    
    // Funcion que se hace al principio de cada elemento xml
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
            
        // Beach Elements
        case BeachXMLTags.beach:
            beachXML = BeachXMLModel()
        case BeachXMLTags.origin:
            origin = Origin()
        case BeachXMLTags.prediction:
            prediction = [DayXMLData]()
        case BeachXMLTags.day:
            dayData = DayXMLData()
            dayData?.date = attributeDict[DayXMLProperties.date]!
            
        // Days elements
        case DayXMLTags.skyState:
            dayData?.skyState = fillTwoValueData(with: attributeDict)
        case DayXMLTags.wind:
            dayData?.wind = fillTwoValueData(with: attributeDict)
        case DayXMLTags.swell:
            dayData?.swell = fillTwoValueData(with: attributeDict)
        case DayXMLTags.maxTemp:
            dayData?.maxTemp = Int(attributeDict[DayXMLProperties.value1]!)!
        case DayXMLTags.tempSensation:
            dayData?.termSensation?.f = Int(attributeDict[DayXMLProperties.value1]!)!
            dayData?.termSensation?.decription = attributeDict[DayXMLProperties.desc1]!
        case DayXMLTags.waterTemp:
            dayData?.waterTemp = Int(attributeDict[DayXMLProperties.value1]!)!
        case DayXMLTags.maxUV:
            dayData?.maxUV = Int(attributeDict[DayXMLProperties.value1]!)!
        default:
            print("Other element not saved")
        }
        currentContent = ""
    }
    
    private func fillTwoValueData(with dictionary: [String : String]) -> [TwoValueData] {
        var data = TwoValueData()
        var arrayData = [TwoValueData]()
        data.f = Int(dictionary[DayXMLProperties.f1]!)!
        data.decription = dictionary[DayXMLProperties.desc1]!
        arrayData.append(data)
        data.f = Int(dictionary[DayXMLProperties.f2]!)!
        data.decription = dictionary[DayXMLProperties.desc2]!
        arrayData.append(data)
        return arrayData
    }

        
    // Lo que hay dentro de la etiqueta XML
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentContent += string
    }
    
    // Llega al final de la etiqueta XML
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        // Origin elements
        case OriginXMLTags.productor:
            origin?.productor = currentContent
        case OriginXMLTags.web:
            origin?.web = currentContent
        case OriginXMLTags.language:
            origin?.language = currentContent
        case OriginXMLTags.copyright:
            origin?.copyrigth = currentContent
        case OriginXMLTags.legalNote:
            origin?.legalNote = currentContent
        // Beach elements
        case BeachXMLTags.origin:
            beachXML?.origin = origin!
        case BeachXMLTags.elaborated:
            beachXML?.elaborateDate = currentContent
        case BeachXMLTags.beachName:
            beachXML?.beachName = currentContent
        case BeachXMLTags.beachCityCode:
            beachXML?.city = currentContent
        case BeachXMLTags.day:
            prediction?.append(dayData!)
        case BeachXMLTags.prediction:
            beachXML?.prediction = prediction
        default:
            print("other tag not saved")
        }
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
