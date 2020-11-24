//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!

    var stationsList: [Station] = [Station]()
    var trains: [StationTrain] = [StationTrain]()
    var presenter: TrainViewPresentation?
    var dropDown = DropDown()
    var transitPoints: (source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        let sText = "Source:  " + (UserDefaults.standard.string(forKey: "Source_Key") ?? "___")
        sourceButton.setTitle(sText, for: .normal)
        
        let dText = "Destination:  " + (UserDefaults.standard.string(forKey: "Destination_Key") ?? "___")
        
        destinationButton.setTitle(dText, for: .normal)
        
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
    }
    
    @IBAction func makeSourceFavorite(_ sender: Any) {
        view.endEditing(true)
        
        UserDefaults.standard.set(sourceTxtField.text, forKey: "Source_Key") //setObject

        
        let text = "Source: " + (sourceTxtField.text ?? "")
        sourceButton.setTitle(text, for: .normal)
    }
    
    @IBAction func makeDestinationFavorite(_ sender: Any) {
        view.endEditing(true)
        UserDefaults.standard.set(destinationTextField.text, forKey: "Destination_Key")
        
        let text = "Destination: " + (destinationTextField.text ?? "")

        destinationButton.setTitle(text, for: .normal)
    }
    
    @IBAction func applyFavoriteSource(_ sender: Any) {
        view.endEditing(true)
        
        sourceTxtField.text = UserDefaults.standard.string(forKey: "Source_Key")
    }
    
    @IBAction func applyFavoriteDestination(_ sender: Any) {
        view.endEditing(true)
        destinationTextField.text = UserDefaults.standard.string(forKey: "Destination_Key")
    }
}

extension SearchTrainViewController: TrainView {
    func showNoInterNetAvailabilityMessage() {
        
        DispatchQueue.main.async {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
        }
       
    }

    func showNoTrainAvailbilityFromSource() {
        DispatchQueue.main.async {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
        }
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        DispatchQueue.main.async {
            hideProgressIndicator(view: self.view)
            self.trains = trainsList
            self.trainsListTable.isHidden = false
            self.trainsListTable.reloadData()
        }
    }

    func showNoTrainsFoundAlert() {
        DispatchQueue.main.async {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.trainsListTable.isHidden = true
            self.showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
        }
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidSourceOrDestinationAlert() {
        DispatchQueue.main.async {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
        }
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
          self.stationsList = _stations
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc}
        
        dropDown.selectionAction = { (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
            }else {
                self.transitPoints.destination = item
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            dropDown.dataSource = stationsList.map {$0.stationDesc}
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
        let train = trains[indexPath.row]
        cell.trainCode.text = train.trainCode
        cell.souceInfoLabel.text = train.stationFullName
        cell.sourceTimeLabel.text = train.expDeparture
        if let _destinationDetails = train.destinationDetails {
            cell.destinationInfoLabel.text = _destinationDetails.locationFullName
            cell.destinationTimeLabel.text = _destinationDetails.expDeparture
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
