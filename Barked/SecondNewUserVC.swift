//
//  SecondNewUserVC.swift
//  Barked
//
//  Created by MacBook Air on 10/7/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

class SecondNewUserVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var email = ""
    var password = ""
let breedList:[(breed: String, group: String)] = [("Affenpinscher", breed.toy.rawValue), ("Afghan Hound", breed.hound.rawValue), ("Airedale Terrier", breed.terrier.rawValue), ("Akita", breed.working.rawValue), ("Alaskan Malamute", breed.working.rawValue), ("American English Coonhound", breed.hound.rawValue), ("American Eskimo Dog", breed.nonSporting.rawValue), ("American Foxhound", breed.hound.rawValue), ("American Hairless Terrier", breed.terrier.rawValue), ("American Leopard Hound", breed.terrier.rawValue), ("American Staffordshire Terrier", breed.terrier.rawValue),("American Water Spaniel", breed.sporting.rawValue), ("Anatolian Shepherd Dog", breed.herding.rawValue), ("Appenzeller Sennenhunde", breed.hound.rawValue),("Australian Cattle Dog", breed.herding.rawValue),("Austrailian Shepherd", breed.herding.rawValue),("Austrailian Terrier", breed.terrier.rawValue),("Azawakh", breed.hound.rawValue),("Barbet", breed.sporting.rawValue),("Basenji", breed.hound.rawValue),("Basset Fauve De Bretagne", breed.hound.rawValue),("Basset Hound", breed.hound.rawValue),("Beagle", breed.hound.rawValue),("Bearded Collie", breed.herding.rawValue),("Beauceron", breed.herding.rawValue),("Bedlington Terrier", breed.terrier.rawValue),("Belgian Laeknois", breed.misc.rawValue),("Belgian Malinois", breed.herding.rawValue),("Belgian Sheepdog", breed.herding.rawValue),("Belgian Tervuren", breed.herding.rawValue),("Bergamasco Sheepdog", breed.herding.rawValue),("Berger Picard", breed.herding.rawValue),("Bernese Mountain Dog", breed.working.rawValue),("Bichon Frise", breed.nonSporting.rawValue),("Biewer Terrier", breed.terrier.rawValue),("Black and Tan Coonhound", breed.hound.rawValue),("Bloodhound", breed.hound.rawValue),("Bluetick Coonhound", breed.hound.rawValue),("Boerboel", breed.working.rawValue),("Bolognese", breed.toy.rawValue),("Border Collie", breed.herding.rawValue),("Border Terrier", breed.terrier.rawValue),("Borzoi", breed.hound.rawValue),("Boston Terrier", breed.terrier.rawValue),("Bouvier Des Flandres", breed.herding.rawValue),("Boxer", breed.working.rawValue),("Boykin Spaniel", breed.sporting.rawValue),("Bracco Italiano", breed.hound.rawValue),("Braque Du Bourbonnais", breed.sporting.rawValue),("Braque Francais Pyrenean", breed.sporting.rawValue),("Briard", breed.herding.rawValue),("Brittany", breed.sporting.rawValue),("Broholmer", breed.working.rawValue),("Brussels Griffon", breed.toy.rawValue),("Bull Terrier", breed.terrier.rawValue),("Bulldog", breed.nonSporting.rawValue),("Bullmastiff", breed.working.rawValue),("Cairn Terrier", breed.terrier.rawValue),("Canaan Dog", breed.herding.rawValue),("Cane Corso", breed.misc.rawValue),("Cardigan Welsh Corgi", breed.herding.rawValue),("Catahoula Leopard Dog", breed.herding.rawValue),("Caucasian Shepherd Dog", breed.herding.rawValue),("Cavalier King Charles Spaniel", breed.sporting.rawValue),("Central Asian Shepherd Dog", breed.herding.rawValue),("Cesky Terrier", breed.terrier.rawValue),("Chesapeake Bay Retriever", breed.sporting.rawValue),("Chihuahua", breed.toy.rawValue),("Chinese Crested", breed.toy.rawValue),("Chinese Shar-Pei", breed.nonSporting.rawValue),("Chinook", breed.working.rawValue),("Chow Chow", breed.nonSporting.rawValue),("Cirneco Dell'Enta", breed.hound.rawValue),("Clumber Spaniel", breed.sporting.rawValue),("Cocker Spaniel", breed.sporting.rawValue),("Collie", breed.herding.rawValue),("Coton De Tulear", breed.nonSporting.rawValue),("Curly-Coated Retriever", breed.sporting.rawValue),("Czechoslovakian Vlcak", breed.working.rawValue),("Dachshund", breed.hound.rawValue),("Dalmatian", breed.nonSporting.rawValue),("Dandie Dinmont Terrier", breed.terrier.rawValue),("Danish-Swedish Farmdog", breed.working.rawValue),("Deutscher Wachtelhund", breed.sporting.rawValue),("Doberman Pinscher", breed.working.rawValue),("Dogo Argentino", breed.misc.rawValue),("Dogue De Bordeaux", breed.working.rawValue),("Drentsche Patrijshond", breed.sporting.rawValue),("Drever", breed.herding.rawValue),("Dutch Shepherd", breed.herding.rawValue),("English Cocker Spaniel", breed.sporting.rawValue),("English Foxhound", breed.hound.rawValue),("English Setter", breed.sporting.rawValue),("English Springer Spaniel", breed.sporting.rawValue),("English Toy Spaniel", breed.toy.rawValue),("Entlebucher Mountain Dog", breed.herding.rawValue),("Estrela Mountain Dog", breed.working.rawValue),("Eurasier", breed.nonSporting.rawValue),("Field Spaniel", breed.sporting.rawValue),("Finnish Lapphund", breed.herding.rawValue),("Finnish Spitz", breed.nonSporting.rawValue),("Flat-Coated Retriever", breed.sporting.rawValue),("French Bulldog", breed.nonSporting.rawValue),("French Spaniel", breed.sporting.rawValue),("German Longhaired Pointer", breed.sporting.rawValue),("German Pinscher", breed.working.rawValue),("German Shepherd", breed.working.rawValue),("German Shorthaired Pointer", breed.sporting.rawValue),("German Spitz", breed.nonSporting.rawValue),("German Wirehaired Pointer", breed.sporting.rawValue),("Giant Schnauzer", breed.sporting.rawValue),("Glen of Imaal Terrier", breed.terrier.rawValue),("Golden Retriever", breed.sporting.rawValue),("Golden Doodle", breed.sporting.rawValue),("Gordon Setter", breed.sporting.rawValue),("Grand Basset Griffon Vendeen", breed.misc.rawValue),("Great Dane", breed.working.rawValue),("Great Pyrenees", breed.working.rawValue),("Greater Swiss Mountain Dog", breed.working.rawValue),("Greyhound", breed.hound.rawValue),("Hamiltonstovare", breed.hound.rawValue),("Harrier", breed.hound.rawValue),("Havanese", breed.toy.rawValue),("Hokkaido", breed.working.rawValue),("Hovawart", breed.working.rawValue),("Ibizan Hound", breed.hound.rawValue),("Icelandic Sheepdog", breed.herding.rawValue),("Irish Red and White Setter", breed.sporting.rawValue),("Irish Setter", breed.sporting.rawValue),("Irish Terrier", breed.terrier.rawValue),("Irish Water Spaniel", breed.sporting.rawValue),("Irish Wolfhound", breed.hound.rawValue),("Italian Greyhound", breed.toy.rawValue),("Jagdterrier", breed.terrier.rawValue),("Japanese Chin", breed.toy.rawValue),("Jindo", breed.nonSporting.rawValue),("Kai Ken", breed.working.rawValue),("Karelian Bear Dog", breed.working.rawValue),("Keeshond", breed.nonSporting.rawValue),("Kerry Blue Terrier", breed.terrier.rawValue),("Kishu Ken", breed.working.rawValue),("Komondor", breed.working.rawValue),("Kromfohrlander", breed.nonSporting.rawValue),("Kuvasz", breed.working.rawValue),("Labrador (Yellow)", breed.sporting.rawValue),("Labrador (Chocolate)", breed.sporting.rawValue),("Labrador (Black)", breed.sporting.rawValue),("Lagotto Romagnolo", breed.sporting.rawValue),("Lakeland Terrier", breed.terrier.rawValue),("Lancashire Heeler", breed.herding.rawValue),("Leonberger", breed.working.rawValue),("Lhasa Apso", breed.nonSporting.rawValue),("Lowchen", breed.nonSporting.rawValue),("Maltese", breed.toy.rawValue),("Manchester Terrier", breed.terrier.rawValue),("Mastiff", breed.working.rawValue),("Miniature American Shepherd", breed.herding.rawValue),("Miniature Bull Terrier", breed.terrier.rawValue),("Miniature Pinscher", breed.toy.rawValue),("Miniature Schnauzer", breed.terrier.rawValue),("Mixed", breed.misc.rawValue),("Mudi", breed.herding.rawValue),("Neapolitan Mastiff", breed.working.rawValue),("Nederlandse Kooikerhondje", breed.misc.rawValue),("Newfoundland", breed.working.rawValue),("Norfolk Terrier", breed.terrier.rawValue),("Norrbottenspets", breed.misc.rawValue),("Norwegian Buhund", breed.herding.rawValue),("Norwegian Elkhound", breed.hound.rawValue),("Norwegian Lundehund", breed.nonSporting.rawValue),("Norwich Terrier", breed.terrier.rawValue),("Nova Scotia Duck Tolling Retriever", breed.sporting.rawValue),("Old English Sheepdog", breed.herding.rawValue),("Other", breed.misc.rawValue),("Otterhound", breed.hound.rawValue),("Papillon", breed.toy.rawValue),("Parson Russell Terrier", breed.terrier.rawValue),("Pekingese", breed.toy.rawValue),("Pembroke Welsh Corgi", breed.herding.rawValue),("Perro De Presa Canario", breed.working.rawValue),("Peruvian Inca Orchid", breed.misc.rawValue),("Petit Basset Griffon Vendeen", breed.hound.rawValue),("Pharaoh Hound", breed.hound.rawValue),("Pit Bull", breed.working.rawValue),("Plott", breed.hound.rawValue),("Pointer", breed.sporting.rawValue),("Polish Lowland Sheepdog", breed.herding.rawValue),("Pomeranian", breed.toy.rawValue),("Poodle", breed.nonSporting.rawValue),("Porcelaine", breed.hound.rawValue),("Portuguese Podengo", breed.misc.rawValue),("Portuguese Podengo Pequeno", breed.hound.rawValue),("Portuguese Pointer", breed.sporting.rawValue),("Portuguese Sheepdog", breed.herding.rawValue),("Portuguese Water Dog", breed.working.rawValue),("Pudelpointer", breed.sporting.rawValue),("Pug", breed.toy.rawValue),("Puli", breed.herding.rawValue),("Pumi", breed.herding.rawValue),("Pyrenean Mastiff", breed.working.rawValue),("Pyrenean Shepherd", breed.herding.rawValue),("Rafeiro Do Alentejo", breed.working.rawValue),("Rat Terrier", breed.terrier.rawValue),("Redbone Coonhound", breed.hound.rawValue),("Rhodesian Ridgeback", breed.hound.rawValue),("Rottweiler", breed.working.rawValue),("Russell Terrier", breed.terrier.rawValue),("Russian Toy", breed.toy.rawValue),("Russian Tsvetnaya Bolonka", breed.toy.rawValue),("Saluki", breed.hound.rawValue),("Samoyed", breed.working.rawValue),("Schapendoes", breed.herding.rawValue),("Schipperke", breed.nonSporting.rawValue),("Scottish Deerhound", breed.hound.rawValue),("Scottish Terrier", breed.terrier.rawValue),("Sealyham Terrier", breed.terrier.rawValue),("Shetland Sheepdog", breed.herding.rawValue),("Shiba Inu", breed.nonSporting.rawValue),("Shih Tzu", breed.toy.rawValue),("Siberian Husky", breed.working.rawValue),("Silky Terrier", breed.terrier.rawValue),("Skye Terrier", breed.terrier.rawValue),("Sloughi", breed.hound.rawValue),("Slovensky Cuvac", breed.herding.rawValue),("Slovensky Kopov", breed.hound.rawValue),("Small Munsterlander Pointer", breed.sporting.rawValue),("Smooth Fox Terrier", breed.terrier.rawValue),("Soft Coated Wheaten Terrier", breed.terrier.rawValue),("Spanish Mastiff", breed.working.rawValue),("Spanish Water Dog", breed.herding.rawValue),("Spinone Italiano", breed.sporting.rawValue),("St. Bernard", breed.working.rawValue),("Stabyhoun", breed.sporting.rawValue),("Staffordshire Bull Terrier", breed.terrier.rawValue),("Standard Schnauzer", breed.working.rawValue),("Sussex Spaniel", breed.sporting.rawValue),("Swedish Lapphund", breed.herding.rawValue),("Swedish Vallhund", breed.herding.rawValue),("Teddy Roosevelt Terrier", breed.terrier.rawValue),("Taiwan Dog", breed.nonSporting.rawValue),("Thai Ridgeback", breed.hound.rawValue),("Tibetan Mastiff", breed.working.rawValue),("Tibetan Spaniel", breed.sporting.rawValue),("Tibetan Terrier", breed.terrier.rawValue),("Tornjak", breed.working.rawValue),("Tosa", breed.working.rawValue),("Toy Fox Terrier", breed.terrier.rawValue),("Transylvanian Hound", breed.hound.rawValue),("Treeding Tennessee Brindle", breed.hound.rawValue),("Treeing Walker Coonhound", breed.hound.rawValue),("Vizsla", breed.sporting.rawValue),("Weimaraner", breed.sporting.rawValue),("Welsh Springer Spaniel", breed.sporting.rawValue),("Welsh Terrier", breed.terrier.rawValue),("West Highland White Terrier", breed.terrier.rawValue),("Whippet", breed.hound.rawValue),("Wire Fox Terrier", breed.terrier.rawValue),("Wirehaired Pointing Griffon", breed.sporting.rawValue),("Wirehaired Vizsla", breed.sporting.rawValue),("Working Kelpie", breed.herding.rawValue),("Xoloitzuintli", breed.nonSporting.rawValue),("Yorkshire Terrier", breed.terrier.rawValue)]
    
    var selectedBreed: String?
    var breedGroup: String?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var groupName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    // PickerView //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breedList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return breedList[row].breed
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBreed = breedList[row].breed
        breedGroup = breedList[row].group
        groupName.text = breedGroup
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "SanFranciscoText-Light", size: 12)
        
        // where data is an Array of String
        label.text = breedList[row].breed
        
        return label
    }
    
    // MARK: Actions 
    
    @IBAction func nextPress(_ sender: Any) {
        
        guard let username = usernameField.text, username != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid username!")
            return
        }
        
        guard let breed = selectedBreed, breed != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid breed!")
            return
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdNewUserVC") as! ThirdNewUserVC
        vc.password = password
        vc.email = email
        vc.selectedBreed = selectedBreed!
        vc.username = username
        vc.breedGroup = breedGroup!
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
