//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation


class SearchTrainInteractor: TrainUseCase {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    var networkManager = NetworkManager()
    
    func fetchAllStations() {
        if Reach().isNetworkReachable() == true {
            let endpoint = "http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML"
            
            networkManager.fetchAllStation(for: endpoint) { (station, error) in
                
                self.presenter?.stationListFetched(list: station?.stationsList ?? [])
            }
        } else {
            self.presenter?.showNoInterNetAvailabilityMessage()
        }
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        let endpoint = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=\(sourceCode)"
        
        if Reach().isNetworkReachable() {
            networkManager.fetchTrainsFromSource(for: endpoint) { (stationData, error) in
                if let _trainsList = stationData?.trainsList {
                    self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                } else {
                    self.presenter?.showNoTrainAvailbilityFromSource()
                }
            }
        }
        else {
            self.presenter?.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            
            let endpoint = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            
            if Reach().isNetworkReachable() {
                
                networkManager.fetchTrainMovementsData(for: endpoint) { (trainMovements, error) in
                    
                    if let _movements = trainMovements?.trainMovements {
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1
                        
                        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                    }
                    group.leave()
                }
            } else {
                self.presenter?.showNoInterNetAvailabilityMessage()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter?.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
