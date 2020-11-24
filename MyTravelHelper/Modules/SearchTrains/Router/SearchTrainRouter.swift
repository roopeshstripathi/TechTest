//
//  SearchTrainRouter.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
class SearchTrainRouter: TrainViewWireframe {
    static func createModule() -> SearchTrainViewController {
        let view = mainstoryboard.instantiateViewController(withIdentifier: "searchTrain") as! SearchTrainViewController
        let presenter: TrainViewPresentation & InteractorToPresenterProtocol = SearchTrainPresenter()
        let interactor: TrainUseCase = SearchTrainInteractor()
        let router:TrainViewWireframe = SearchTrainRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }

    static var mainstoryboard: UIStoryboard{
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
}
