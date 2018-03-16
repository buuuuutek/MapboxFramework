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
    
    private func addAnnotations(from json: JSON, to map: MGLMapView) {
        
        let features = json["features"].arrayValue
        
        for item in features {
            let name = item["properties"]["name"].stringValue
            
            let x = item["geometry"]["coordinates"][0].doubleValue
            let y = item["geometry"]["coordinates"][1].doubleValue
            let coordinates = (x, y)
            
            addAnnotations(to: map, by: coordinates, with: name)
        }
    }
    
    private func addAnnotations(to map: MGLMapView, by coordinates: (longitude: Double, latitude: Double), with name: String) {
        
        let newAnnotation = MGLPointAnnotation()
        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        newAnnotation.title = name
        
        map.addAnnotation(newAnnotation)
    }
    
    private func createMap() -> MGLMapView {
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 55.75, longitude: 37.61), zoomLevel: 11, animated: false)
        view.addSubview(mapView)
        
        mapView.delegate = self
        
        return mapView
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    private func getFileData(fileName: String, fileType: String) -> Data {
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
}

