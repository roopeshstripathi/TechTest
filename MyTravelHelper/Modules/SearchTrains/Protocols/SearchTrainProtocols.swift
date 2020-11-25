//
//  SearchTrainProtocols.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

// TrainView Presenter Protocol
protocol TrainViewPresentation: class{
    var view: TrainView? {get set}
    var interactor: TrainUseCase? {get set}
    var router: TrainViewWireframe? {get set}
    func fetchallStations()
    func searchTapped(source:String,destination:String)
}

// TrainView View Protocol
protocol TrainView: class{
    func saveFetchedStations(stations:[Station]?)
    func showInvalidSourceOrDestinationAlert()
    func updateLatestTrainList(trainsList: [StationTrain])
    func showNoTrainsFoundAlert()
    func showNoTrainAvailbilityFromSource()
    func showNoInterNetAvailabilityMessage()
}

protocol TrainViewWireframe: class {
    static func createModule()-> SearchTrainViewController
}

protocol TrainUseCase: class {
    var presenter:InteractorToPresenterProtocol? {get set}
    func fetchAllStations()
    func fetchTrainsFromSource(sourceCode:String,destinationCode:String)
}

protocol InteractorToPresenterProtocol: class {
    func stationListFetched(list:[Station])
    func fetchedTrainsList(trainsList:[StationTrain]?)
    func showNoTrainAvailbilityFromSource()
    func showNoInterNetAvailabilityMessage()
}
