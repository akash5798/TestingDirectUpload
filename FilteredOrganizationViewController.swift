//
//  FilteredOrganizationViewController.swift
//  Prayer Pulse
//
//  Created by mac on 10/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyUserDefaults

protocol FilteredOrganizationDelegate {
    func didSelected(ChurchesArray church: [Church])
}

class FilteredOrganizationViewController: UIViewController {
    
    
    var delegate: FilteredOrganizationDelegate?
    
    private let cellIdCountriesAndCity = "cell"
    private let cellIdChurch = "cellChurch"
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableFilteredList: UITableView!
    @IBOutlet weak var searchTF: SearchTextFieldCustom!
    
    @IBOutlet weak var btnAdd: PrayerPulseRoundedButton!
    
    @IBOutlet weak var containerViewAddBtn: UIView!
    @IBOutlet weak var titleBackgrounView: UIView!
    @IBOutlet weak var filterContainerVIew: UIView!
    
    
    @IBOutlet weak var tableFilteredBottomConstraint: NSLayoutConstraint!
    
    /*
     0 show all
     1 by nation
     2 by city
     3 affiliation/ denominations
     4 nearest to me
     clear
     */
    
    enum filterOptions: String {
        case showAll = "All churches"
        case byNation = "Churches by nation"
        case byCity = "Churches by city"
        case affiliation = "Affiliation/Denominations"
        case nearest = "Churches nearest to you"
    }
    
    var selectedFilterOption = 0
    
    var selectedLocationName = ""
    
    var pageNumberToRequest = 1
    
    
    var arrayLocationList: [Location] = []
    var arraySearchedLocationList: [Location] = []
    
    var arrayChurchList = [Church]()
    var arraySearchedChurchList = [Church]()
    var arraySelectedChurchesList = [Church]()
    
    //location Type will hold 0( for city) or 1(country/nation) depending on filter option selection
    var locationTypeCityOrCountryOrAffiliateOrLocation = 999
    
    var current_Table_Is_Location_Or_Organization = 0
    
    var isDataLoadedForFirstTime = true
    var isSearching = false
    
    var selectedNationName = ""
    var selectedCityName = ""
    
    var totalCount: Int = 1
    
    var isManagingOrganization = false
    
    var isLocationUpdated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleBackgroundViewLayer()
        setCurrentTableVar ()
        toggleAddBtn()
        setTableviewFiltered()
        setTitleLabelOfView()
        setPagination()
        setupFilterContainerView()
        
        
        if isManagingOrganization {
            lblTitle.text = "MANAGE ORGANIZATION"
        }else {
            lblTitle.text = "SELECT ORGANIZATION"
        }
        searchTF.addTarget(self, action: #selector(searchFunciton), for: .editingChanged)
    }
    
    @objc func searchFunciton(textfield: UITextField) {
        isSearching = !(textfield.text ?? "").isEmpty
        
        if isSearching {
            infiniteScrollingOfTableShould(Enable: false)
        }else{
            if current_Table_Is_Location_Or_Organization == 0 {
                infiniteScrollingOfTableShould(Enable: false)
            }else{
//                infiniteScrollingOfTableShould(Enable: true)
                if totalCount == self.arrayChurchList.count || locationTypeCityOrCountryOrAffiliateOrLocation == 3 {
                    self.infiniteScrollingOfTableShould(Enable: false)
                }else{
                    self.infiniteScrollingOfTableShould(Enable: true)
                }
                
            }
        }
        
        if current_Table_Is_Location_Or_Organization == 1 {
            print("searching church")
            arraySearchedChurchList = arrayChurchList.filter({$0.name.localizedCaseInsensitiveContains(textfield.text ?? "")  })
        }else{
            print("searching location")
            switch selectedFilterOption {
            case 1:
                if locationTypeCityOrCountryOrAffiliateOrLocation != 0 {
                    //                showAllLocationApiCall(CityOrCountryOrAffiliate: 1)
                    arraySearchedLocationList = arrayLocationList.filter({$0.country.localizedCaseInsensitiveContains(textfield.text ?? "")  })
                }else{
                    //            case 2:
                    //lblTitle.text = filterOptions.byCity.rawValue
                    //                showAllLocationApiCall(CityOrCountryOrAffiliate: 0)
                    arraySearchedLocationList = arrayLocationList.filter({$0.city.localizedCaseInsensitiveContains(textfield.text ?? "")  })
                }
            case 2:
                //lblTitle.text = filterOptions.affiliation.rawValue
                //                showAllLocationApiCall(CityOrCountryOrAffiliate: 2)
                arraySearchedLocationList = arrayLocationList.filter({$0.affiliate.localizedCaseInsensitiveContains(textfield.text ?? "")  })
            default:
                
                if isManagingOrganization {
                    lblTitle.text = "MANAGE ORGANIZATION"
                }else {
                    lblTitle.text = "SELECT ORGANIZATION"
                }
            }
        }
        
        tableFilteredList.reloadData()
    }
    
    fileprivate func setTitleLabelOfView() {
        
        switch selectedFilterOption {
        case 0:
            //lblTitle.text = filterOptions.showAll.rawValue
            showAllChurchApiCall(withPage: pageNumberToRequest)
        case 1:
            showAllLocationApiCall(CityOrCountryOrAffiliate: 1)
            //        case 2:
            //lblTitle.text = filterOptions.byCity.rawValue
        //            showAllLocationApiCall(CityOrCountryOrAffiliate: 0)
        case 2:
            //lblTitle.text = filterOptions.affiliation.rawValue
            showAllLocationApiCall(CityOrCountryOrAffiliate: 2)
        case 3:
            //lblTitle.text = filterOptions.nearest.rawValue
            LocationManager.sharedInstance.delegate = self
            LocationManager.sharedInstance.startLocationTracking()
            locationTypeCityOrCountryOrAffiliateOrLocation = 3
            if isLocationUpdated {
                //                nearMeApiMethodCalling()
            }else{
                initiateLocationManager()
            }
            
        default:
            
            if isManagingOrganization {
                lblTitle.text = "MANAGE ORGANIZATION"
            }else {
                lblTitle.text = "SELECT ORGANIZATION"
            }
        }
    }
    
    private func initiateLocationManager() {
        
        if isLocationUpdated {
            //            nearMeApiMethodCalling()
        }else{
            //                openSettings()
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus(){
                case .restricted:
                    print("location restricted ")
                case .denied:
                    alertForSetting()
                case .authorizedAlways:
                    print("location authorizedAlways")
                    Loader.showLoader()
                //                    nearMeApiMethodCalling()
                case .authorizedWhenInUse:
                    print("location authorizedWhenInUse")
                    Loader.showLoader()
                //                    nearMeApiMethodCalling()
                case .notDetermined:
                    print("location notDetermined")
                }
            }
        }
    }
    
    private func alertForSetting() {
        let alert = UIAlertController(title: "Location permission", message: "We couldn't fetch your current location. \nTo re-enable location, please open Settings and turn on Location Service for this app.", preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.black
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            self.openSettings()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("cancel")
        }))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openSettings() {
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(settingsUrl)
        }
    }
    
    // MARK:  Near me api call
    fileprivate func nearMeApiMethodCalling() {
        if let location = LocationManager.sharedInstance.currentLocation {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            if latitude == 0.0 || longitude == 0.0 {
                showAlertExtWith(Message: "We couldn't able to fetch your current location, please check your GPS or try again later.")
                Loader.hideLoader()
            }else{
                self.getFilteredChurch(withCityOrCountryOrAffiliateOrLocation: self.locationTypeCityOrCountryOrAffiliateOrLocation, Name: self.selectedLocationName, andPageNumber: self.pageNumberToRequest)
            }
        }
    }
    
    // MARK:  Infinite scroll Pagination call Initiate
    fileprivate func setPagination(){
        tableFilteredList.addInfiniteScroll { (tableView) in
            if !UIApplication.shared.isNetworkActivityIndicatorVisible {
                
                if self.selectedFilterOption == 1 || self.selectedFilterOption == 2 || self.selectedFilterOption == 3 {
                    self.getFilteredChurch(withCityOrCountryOrAffiliateOrLocation: self.locationTypeCityOrCountryOrAffiliateOrLocation, Name: self.selectedLocationName, andPageNumber: self.pageNumberToRequest)
                }else {
                    self.showAllChurchApiCall(withPage: self.pageNumberToRequest)
                }
                
            }
        }
    }
    
    private func showLoaderWithFirstTimeLoadingCheck() {
        if isDataLoadedForFirstTime {
            Loader.showLoader()
        }else{
            
        }
    }
    
    
    fileprivate func setCurrentTableVar () {
        if selectedFilterOption == 1 || selectedFilterOption == 2 /*|| selectedFilterOption == 3*/ {
            current_Table_Is_Location_Or_Organization = 0
            self.searchTF.setPlaceholder(withString: "Search")
        }else {
            current_Table_Is_Location_Or_Organization = 1
            self.searchTF.setPlaceholder(withString: "Search")
        }
    }
    
    fileprivate func setupFilterContainerView() {
        
        filterContainerVIew.backgroundColor = .clear
        filterContainerVIew.layer.cornerRadius = 17.0
        filterContainerVIew.layer.borderWidth = 1.0
        filterContainerVIew.layer.borderColor = UIColor.white.cgColor
        filterContainerVIew.clipsToBounds = true
        
    }
    
    fileprivate func setTableviewFiltered(){
        tableFilteredList.delegate = self
        tableFilteredList.dataSource = self
        tableFilteredList.tableFooterView = UIView()
        tableFilteredList.register(UITableViewCell.self, forCellReuseIdentifier: cellIdCountriesAndCity)
        tableFilteredList.register(UINib(nibName: "ChurchTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdChurch)
    }
    
    // MARK:  Setup VC
    fileprivate func setupTitleBackgroundViewLayer() {
        //        self.titleBackgrounView.backgroundColor = UIColor.clear
        //        let selfViewFrame = self.view.frame
        //        let gradientLayer = GradientView.get(forSize: CGSize(width: selfViewFrame.width, height: titleBackgrounView.frame.height)).layer
        //        self.titleBackgrounView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    fileprivate func setLeftBarButton() {
        var image = UIImage(named: "back_arrow")
        image = image?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(leftBarButtonAction))
    }
    
    @objc func leftBarButtonAction() {
        dismissFilteredOrg()
    }
    
    fileprivate func toggleAddBtn(){
        if current_Table_Is_Location_Or_Organization == 0 {
            tableFilteredBottomConstraint.constant = 0
            containerViewAddBtn.isHidden = true
            //self.lblTitle.text = "Select Location"
            infiniteScrollingOfTableShould(Enable: false)
            self.searchTF.setPlaceholder(withString: "Search")
            
        }else {
            tableFilteredBottomConstraint.constant = 65
            containerViewAddBtn.isHidden = false
            current_Table_Is_Location_Or_Organization = 1
            //            infiniteScrollingOfTableShould(Enable: true)
            self.searchTF.setPlaceholder(withString: "Search")
        }
    }
    
    fileprivate func infiniteScrollingOfTableShould(Enable bool: Bool){
        self.tableFilteredList.setShouldShowInfiniteScrollHandler({ _ -> Bool in
            return bool
        })
    }
    
    
    // MARK:  IBActions
    @IBAction func addAction(_ sender: PrayerPulseRoundedButton) {
        //        print("Add organization to list and dismiss vc")
        //        dismissFilteredOrg()
        delegateMethodCall()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        if current_Table_Is_Location_Or_Organization == 0 && selectedNationName == "" {
            dismissFilteredOrg()
        }else {
            if (selectedFilterOption == 1 && selectedNationName != "") || selectedFilterOption == 2 /*|| selectedFilterOption == 3*/ {
                current_Table_Is_Location_Or_Organization = 0
                if locationTypeCityOrCountryOrAffiliateOrLocation == 0 && selectedCityName != "" {
                    pageNumberToRequest = 1
                    current_Table_Is_Location_Or_Organization = 0
                    showAllLocationApiCall(CityOrCountryOrAffiliate: 0)
                    selectedCityName = ""
                    toggleAddBtn()
                    return
                }else{
                    //                    locationTypeCityOrCountryOrAffiliateOrLocation = 999
                    selectedNationName = ""
                }
                tableFilteredList.reloadData()
                setTitleLabelOfView()
                pageNumberToRequest = 1
                //                self.lblTitle.text = "Select Locationssssss"
            }else {
                dismissFilteredOrg()
            }
        }
        toggleAddBtn()
    }
    
    
    @IBAction func filterAction(_ sender: UIButton) {
        if ApiService.isConnectedToNetwork() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.filterPopUpVC) as! FilterViewController
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }else {
            showAlertExtWith(Message: "Can't connect to the internet.")
        }
    }
    
    // MARK:  API Call
    fileprivate func showAllChurchApiCall(withPage page: Int) {
        showLoaderWithFirstTimeLoadingCheck()
        Church.getAllChurch(withPageNumber: page, success: { (allChurchArray, count, messageReceived) in
            //            print("All church count \(allChurchArray.count)")
            self.arrayChurchList.append(contentsOf: allChurchArray)
            self.tableFilteredList.reloadData()
            self.pageNumberToRequest += 1
            self.tableFilteredList.finishInfiniteScroll()
            self.isDataLoadedForFirstTime = false
            self.totalCount = count
            Loader.hideLoader()
            
            if count == self.arrayChurchList.count {
                self.infiniteScrollingOfTableShould(Enable: false)
            }else{
                self.infiniteScrollingOfTableShould(Enable: true)
            }
            
        }) { (error) in
            //            if error == "Data not found" {
            //                self.tableFilteredList.setShouldShowInfiniteScrollHandler({ _ -> Bool in
            //                    return false
            //                })
            //            }
            //            print("error: \(error)")
            Loader.hideLoader()
            self.tableFilteredList.finishInfiniteScroll()
            //            self.showAlertExtWith(Message: error)
        }
    }
    
    
    fileprivate func showAllLocationApiCall(CityOrCountryOrAffiliate option: Int) {
        Loader.showLoader()
        locationTypeCityOrCountryOrAffiliateOrLocation = option
        Location.getAllLocation(ofCityOrCountryOrAffiliate: option, countryNameIfOption0: selectedNationName, success: { (locationArray) in
            self.arrayLocationList = locationArray
            self.tableFilteredList.reloadData()
            self.setSearchTFEmpty()
            Loader.hideLoader()
        }) { (error) in
            self.showAlertExtWith(Message: error)
            Loader.hideLoader()
        }
    }
    
    fileprivate func getFilteredChurch(withCityOrCountryOrAffiliateOrLocation optionPassed: Int, Name name: String, andPageNumber pageNo: Int) {
        showLoaderWithFirstTimeLoadingCheck()
        Church.getFilteredChurch(withCityOrCountryOrAffiliateOrLocation: optionPassed, Name: name, andPageNumber: pageNo, success: { (churchArray, count, messageReceived) in
            
            //            self.arrayChurchList.removeAll()
            self.arrayChurchList.append(contentsOf: churchArray)
            //            self.current_Table_Is_Location_Or_Organization = 1
            self.tableFilteredList.reloadData()
            self.setSearchTFEmpty()
            self.pageNumberToRequest += 1
            self.tableFilteredList.finishInfiniteScroll()
            self.isDataLoadedForFirstTime = false
            
            if count == self.arrayChurchList.count {
                self.infiniteScrollingOfTableShould(Enable: false)
            }else{
                if optionPassed != 3 {
                    self.infiniteScrollingOfTableShould(Enable: true)
                }else{
                    //disable pagination if nearest to me selected
                    self.infiniteScrollingOfTableShould(Enable: false)
                }
            }
            
            Loader.hideLoader()
            
        }) { (errorrr) in
            print("getFilteredChurch error: \(errorrr)")
            Loader.hideLoader()
            self.tableFilteredList.finishInfiniteScroll()
        }
    }
    
    
    // MARK:  Set empty tf
    func setSearchTFEmpty() {
        
        self.searchTF.text = "a"
        self.searchTF.text = ""
        self.searchFunciton(textfield: self.searchTF)
    }
    
    // MARK:  Dismiss VC
    
    private func dismissFilteredOrg() {
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK:  Delegate Function
    private func delegateMethodCall(){
        
        arraySelectedChurchesList.removeAll()
        for church in arrayChurchList {
            if church.isTicked {
                arraySelectedChurchesList.append(church)
            }
        }
        
        if arraySelectedChurchesList.count > 0 {
            dismissFilteredOrg()
            if let delegate = self.delegate{
                delegate.didSelected(ChurchesArray: arraySelectedChurchesList)
                //                let savedNation: Bool = KeychainWrapper.standard.set(selectedLocationName, forKey: keychainKeys.selectedNationFilter)
                
                if locationTypeCityOrCountryOrAffiliateOrLocation == 1 {
                    Defaults[.savedNation] = selectedLocationName
                }
                
            }
        }else{
            self.showAlertExtWith(Message: "Please select minimum 1 church.")
        }
    }
    
}// Class end here

// MARK:  Tableview Datasource Methods
extension FilteredOrganizationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tableFilteredList.removeEmptyMessage()
        if current_Table_Is_Location_Or_Organization == 0 {
            
            //location list
            if isSearching {
                if arraySearchedLocationList.count == 0 {
                    self.tableFilteredList.setEmptyMessage("No place found")
                }else{
                    self.tableFilteredList.removeEmptyMessage()
                }
                return arraySearchedLocationList.count
            }
            return arrayLocationList.count
        }else {
            //church list
            if isSearching {
                if arraySearchedChurchList.count == 0 {
                    self.tableFilteredList.setEmptyMessage("No organization found")
                }else{
                    self.tableFilteredList.removeEmptyMessage()
                }
                return arraySearchedChurchList.count
            }
            return arrayChurchList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if current_Table_Is_Location_Or_Organization == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdCountriesAndCity)
            
            //            if locationTypeCityOrCountryOrAffiliate == 0 {
            //                cell?.textLabel?.text = arrayLocationList[indexPath.row].city
            //            }else {
            //                cell?.textLabel?.text = arrayLocationList[indexPath.row].country
            //            }
            
            
            let currentLocation: Location
            
            if isSearching {
                currentLocation = arraySearchedLocationList[indexPath.row]
                
            }else{
                currentLocation = arrayLocationList[indexPath.row]
            }
            
            switch locationTypeCityOrCountryOrAffiliateOrLocation {
            case 0:
                //                cell?.textLabel?.text = arrayLocationList[indexPath.row].city
                cell?.textLabel?.text = currentLocation.city
            case 1:
                cell?.textLabel?.text = currentLocation.country
            case 2:
                cell?.textLabel?.text = currentLocation.affiliate
            default:
                cell?.textLabel?.text = "Title"
            }
            
            return cell!
        }else {
            let cellOrg = tableView.dequeueReusableCell(withIdentifier: cellIdChurch) as! ChurchTableViewCell
            let currentModel: Church
            if isSearching {
                currentModel = arraySearchedChurchList[indexPath.row]
                
            }else{
                currentModel = arrayChurchList[indexPath.row]
            }
            cellOrg.selectionStyle = .none
            //            cellOrg.configureWith(Model: currentModel, isAdding: true)
            cellOrg.configureWith(Model2: currentModel, isAdding: true)
            cellOrg.churchActionButton.isUserInteractionEnabled = false
            return cellOrg
        }
    }
    
}

// MARK:  Tableview Delegate Methods
extension FilteredOrganizationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //select location (city or country)
        if current_Table_Is_Location_Or_Organization == 0 {
            Loader.showLoader()
            
            let currentLocation: Location
            
            if isSearching {
                currentLocation = arraySearchedLocationList[indexPath.row]
                
            }else{
                currentLocation = arrayLocationList[indexPath.row]
            }
            
            switch locationTypeCityOrCountryOrAffiliateOrLocation {
            case 0:
                //self.lblTitle.text = arrayLocationList[indexPath.row].city
                selectedCityName = currentLocation.city
                selectedLocationName = currentLocation.city
            case 1:
                //self.lblTitle.text = arrayLocationList[indexPath.row].country
                //                selectedLocationName = currentLocation.country
                selectedNationName = currentLocation.country
                current_Table_Is_Location_Or_Organization = 0
                showAllLocationApiCall(CityOrCountryOrAffiliate: 0)
                return
                
            case 2:
                //self.lblTitle.text = arrayLocationList[indexPath.row].affiliate
                selectedLocationName = currentLocation.affiliate
            default:
                //self.lblTitle.text = "Title"
                selectedLocationName = "Title"
            }
            
            getFilteredChurch(withCityOrCountryOrAffiliateOrLocation: locationTypeCityOrCountryOrAffiliateOrLocation, Name: selectedLocationName, andPageNumber: 1)
            current_Table_Is_Location_Or_Organization = 1
            
            self.arrayChurchList.removeAll()
            //            self.tableFilteredList.reloadData()
            
            
        }
        else{//select church
            if isSearching {
                arraySearchedChurchList[indexPath.row].isTicked = !arraySearchedChurchList[indexPath.row].isTicked
                /*if let index = arrayChurchList.index(where: {$0.id == arraySearchedChurchList[indexPath.row].id}){
                 arrayChurchList[index].isTicked = !arrayChurchList[index].isTicked
                 }*/
            }else{
                if arrayChurchList.count != 0 {
                    arrayChurchList[indexPath.row].isTicked = !arrayChurchList[indexPath.row].isTicked
                }
            }
            self.tableFilteredList.reloadRows(at: [indexPath], with: .automatic)
        }
        toggleAddBtn()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if current_Table_Is_Location_Or_Organization == 0 {
            return 44
        } else {
            return 92
        }
    }
}

// MARK:  LocationManager Delegate
extension FilteredOrganizationViewController: LocationManagerDelegate {
    func locationDidUpdated(success: Bool) {
        if success {
            print("Location has been updated in FIltered_ORG")
            isLocationUpdated = true
            nearMeApiMethodCalling()
        }
    }
}

// MARK:  Delegate method of filterViewControler
extension FilteredOrganizationViewController: FilterViewDelegate {
    func didSelected(FilterNumber number: Int) {
        print("Did selected option in FilteredOrganizationVC: \(number)")
        
        //Removing and resetting all data on this page
        selectedFilterOption = number
        selectedLocationName = ""
        pageNumberToRequest = 1
        arrayLocationList.removeAll()
        arraySearchedChurchList.removeAll()
        
        arrayChurchList.removeAll()
        arraySearchedChurchList.removeAll()
        arraySelectedChurchesList.removeAll()
        
        locationTypeCityOrCountryOrAffiliateOrLocation = 999
        
        current_Table_Is_Location_Or_Organization = 0
        isDataLoadedForFirstTime = true
        isSearching = false
        
        selectedNationName = ""
        selectedCityName = ""
        isLocationUpdated = false
        
        totalCount = 1
        setSearchTFEmpty()
        
        setCurrentTableVar()
        toggleAddBtn()
        setTitleLabelOfView()
        setPagination()
        
    }
    
}




