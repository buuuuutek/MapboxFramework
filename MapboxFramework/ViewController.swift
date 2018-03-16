//
//  ViewController.swift
//  MapboxFramework
//
//  Created by ApplePie on 15.03.18.
//  Copyright © 2018 VictorVolnukhin. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON

class ViewController: UIViewController, MGLMapViewDelegate {
    
    var hexMarkerColor = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let map = createMap()

        let fileData = getFileData(fileName: "map", fileType: "geojson")
        
        if let json = try? JSON(data: fileData){
            addAnnotations(from: json, to: map)
        }
        else {
            print("Application couldn't parse this data to JSON.")
        }
    }
    
    private func addAnnotations(from json: JSON, to mapView: MGLMapView) {
        
        let features = json["features"].arrayValue
        
        for item in features {
            
            let newAnnotation = MGLPointAnnotation()
            newAnnotation.title = item["properties"]["name"].stringValue

            let x = item["geometry"]["coordinates"][0].doubleValue
            let y = item["geometry"]["coordinates"][1].doubleValue
            newAnnotation.coordinate = CLLocationCoordinate2D(latitude: y, longitude: x)
            
            hexMarkerColor = item["properties"]["marker-color"].stringValue
            
            mapView.addAnnotation(newAnnotation)
        }
    }
    
    func createMap() -> MGLMapView {
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 55.75, longitude: 37.61), zoomLevel: 11, animated: false)
        view.addSubview(mapView)
        
        mapView.delegate = self
        
        return mapView
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            annotationView!.backgroundColor = hexStringToUIColor(hex: hexMarkerColor)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func getFileData(fileName: String, fileType: String) -> Data {
        var data = Data()
        
        if let path = Bundle.main.path(forResource: fileName, ofType: fileType) {
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            }
            catch {
                print("Contents could not be loaded.")
            }
        }
        else {
            print("\(fileName).\(fileType) not found.")
        }
        
        return data
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

