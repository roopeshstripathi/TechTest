//
//  NetworkManager.swift
//  MyTravelHelper
//
//  Created by roopesh.s.tripathi on 25/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation
import XMLParsing

public enum ServiceError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}

protocol NetworkManagerProtocol {
    
    /// fetching all stations
    /// - Parameters:
    ///   - urlString: endPoint string
    ///   - completionHandler: (Stations?, ServiceError?)
    func fetchAllStation(for urlString: String,
                         completionHandler: @escaping (Stations?, ServiceError?) -> Void)
    
    /// fetching Trains from source station
    /// - Parameters:
    ///   - endpoint: endPoint string
    ///   - completionHandler: (StationData?, ServiceError?)
    func fetchTrainsFromSource(for endpoint: String,
                               completionHandler: @escaping (StationData?, ServiceError?) -> Void)
    
    /// fetching trainMovementsData
    /// - Parameters:
    ///   - endpoint: endPoint string
    ///   - completionHandler: (TrainMovementsData?, ServiceError?)
    func fetchTrainMovementsData(for endpoint: String,
                                 completionHandler: @escaping (TrainMovementsData?, ServiceError?) -> Void)
}


class NetworkManager: NetworkManagerProtocol {
    
    func fetchAllStation(for endpoint: String,
                         completionHandler: @escaping (Stations?, ServiceError?) -> Void) {
        
        guard let endpointURL = URL(string: endpoint) else {
            completionHandler(nil, ServiceError.invalidURL(endpoint))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, ServiceError.forwarded(error!))
                return
            }
            
            guard let responseData = data else {
                completionHandler(nil, ServiceError.invalidPayload(endpointURL))
                return
            }
            
            do {
                let station = try XMLDecoder().decode(Stations.self, from: responseData)
                
                completionHandler(station, nil)
                
            } catch {
                completionHandler(nil, ServiceError.forwarded(error))
            }
        }
        dataTask.resume()
    }
    
    func fetchTrainsFromSource(for endpoint: String,
                               completionHandler: @escaping (StationData?, ServiceError?) -> Void) {
        guard let endpointURL = URL(string: endpoint) else {
            completionHandler(nil, ServiceError.invalidURL(endpoint))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, ServiceError.forwarded(error!))
                return
            }
            
            guard let responseData = data else {
                completionHandler(nil, ServiceError.invalidPayload(endpointURL))
                return
            }
            
            do {
                let stationData = try XMLDecoder().decode(StationData.self, from: responseData)
                
                completionHandler(stationData, nil)
                
            } catch {
                completionHandler(nil, ServiceError.forwarded(error))
            }
        }
        dataTask.resume()
    }
    
    func fetchTrainMovementsData(for endpoint: String,
                                 completionHandler: @escaping (TrainMovementsData?, ServiceError?) -> Void) {
        guard let endpointURL = URL(string: endpoint) else {
            completionHandler(nil, ServiceError.invalidURL(endpoint))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, ServiceError.forwarded(error!))
                return
            }
            
            guard let responseData = data else {
                completionHandler(nil, ServiceError.invalidPayload(endpointURL))
                return
            }
            
            do {
                let trainMovementsData = try XMLDecoder().decode(TrainMovementsData.self, from: responseData)
                
                completionHandler(trainMovementsData, nil)
                
            } catch {
                completionHandler(nil, ServiceError.forwarded(error))
            }
        }
        dataTask.resume()
    }
    
}
