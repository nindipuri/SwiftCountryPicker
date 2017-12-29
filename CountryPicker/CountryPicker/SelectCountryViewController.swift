//
//  SelectCountryViewController.swift
//  CountryPicker
//
//  Created by debut on 28/12/17.
//  Copyright © 2017 debut. All rights reserved.
//

import UIKit

struct Country {
  let country_code : String
  let country_name : String
  let emoji : String
  let countryPhoneCode : String

}


class SelectCountryViewController: UITableViewController {
  
  var countries = [[String: String]]()
  var countriesFiltered = [Country]()
  var countriesModel = [Country]()
  let cellIdentifier = "countryCell"
  
  var selectionTintColor:UIColor = .red
  
  
  var navigationBarTintColor:UIColor = .red
  var navigationBarTextColor:UIColor = .white
  var navigationTitle:String = "Select Country"
  var navigationBackButtonTitle = "Done"

  var selectedCountry:Country!
  
  let searchBar = UISearchBar()
  var searchBarPlaceholder = "Search"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLeftBarButton()
    configureSearchBar()
    jsonSerial()
    collectCountries()
    
    self.title = navigationTitle
    self.navigationController?.navigationBar.barTintColor = self.navigationBarTintColor
    self.navigationController?.navigationBar.tintColor = self.navigationBarTextColor
    let textAttributes = [NSAttributedStringKey.foregroundColor:self.navigationBarTextColor]
    navigationController?.navigationBar.titleTextAttributes = textAttributes

  }
  
  private func setupLeftBarButton(){
    let leftbarButton = UIBarButtonItem(title: navigationBackButtonTitle, style: .plain, target: self, action: #selector(self.doneSelection))
    self.navigationItem.leftBarButtonItem = leftbarButton
    self.navigationItem.leftItemsSupplementBackButton = true

  }
  
  func configureSearchBar() {
    searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
    searchBar.barStyle = .default
    searchBar.barTintColor = .red
    searchBar.isTranslucent = true
    searchBar.placeholder = searchBarPlaceholder
    searchBar.delegate = self
    self.tableView.keyboardDismissMode = .onDrag
    self.tableView.tableHeaderView = searchBar
  }
  
  @objc private func doneSelection(){
    print(getCountryPhonceCode(selectedCountry.country_code))
    self.dismiss(animated: true, completion: nil)
  }
  
  private func jsonSerial() {
    let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "countries", ofType: "json")!))
    do {
      let parsedObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
      countries = parsedObject as! [[String : String]]
      //      print("country list \(countries)")
    }catch{
      print("not able to parse")
    }
  }
  
  func collectCountries() {
    for country in countries  {
      let code = country["code"] ?? ""
      let name = country["name"] ?? ""
      let emoji = country["emoji"] ?? ""
      let countryPhoneCode = getCountryPhonceCode(code)

      countriesModel.append(Country(country_code:code, country_name:name,emoji:emoji,countryPhoneCode:countryPhoneCode))
    }
    countriesModel = countriesModel.sorted { (country1, country2) -> Bool in
      return country1.country_name.compare(country2.country_name) == ComparisonResult.orderedAscending
    }
  }
  
  func checkSearchBarActive() -> Bool {
    
    if searchBar.text != "" {
      return true
    }else {
      return false
    }
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if checkSearchBarActive(){
      return countriesFiltered.count
    }
    return countries.count
  }
  

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
    
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    
    cell?.tintColor = selectionTintColor
    let contry: Country
    
    if checkSearchBarActive() {
      contry = countriesFiltered[indexPath.row]
    }else{
      contry = countriesModel[indexPath.row]
    }
    
    cell?.textLabel?.text = contry.emoji + " " + contry.country_name + " (" + contry.countryPhoneCode + ")"
    
    if selectedCountry != nil{
        cell?.accessoryType = .none
        if contry.country_name == selectedCountry.country_name{
          cell?.accessoryType = .checkmark
        }
    }
    
    return cell!
   }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    selectedCountry = nil
    if checkSearchBarActive() {
      selectedCountry = countriesFiltered[indexPath.row]
    }else{
      selectedCountry = countriesModel[indexPath.row]
    }
    self.tableView.reloadData()
  }
  
}

extension SelectCountryViewController:UISearchBarDelegate{
  
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.filtercountry(searchText)
  }
  
  func filtercountry(_ searchText: String) {
    countriesFiltered = countriesModel.filter({(country ) -> Bool in
      let value = country.country_name.lowercased().contains(searchText.lowercased()) || country.country_code.lowercased().contains(searchText.lowercased())
      return value
    })
    countriesFiltered = countriesFiltered.sorted { (country1, country2) -> Bool in
      return country1.country_name.compare(country2.country_name) == ComparisonResult.orderedAscending
    }
    tableView.reloadData()
  }
  
}
