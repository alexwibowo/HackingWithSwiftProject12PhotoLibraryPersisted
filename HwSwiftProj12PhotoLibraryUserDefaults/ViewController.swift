//
//  ViewController.swift
//  HwSwiftProj12PhotoLibraryUserDefaults
//
//  Created by Alex Wibowo on 25/9/21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))
        
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.load()
        }
        
        
        
    }
    
    @objc func addPicture(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let fullImagePath = getDocumentDirectory().appendingPathComponent(imageName)
        if let compressedImage = image.jpegData(compressionQuality: 0.8) {
            try? compressedImage.write(to: fullImagePath)
        }
        
        let person = Person(name: "unknown", image: imageName)
        people.append(person)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.save()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }                
        dismiss(animated: true)
    }
    
    func save(){
        let standards = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(people) {
            standards.setValue(encoded, forKey: "people")
        }
    }
    
    func load(){
        let standards = UserDefaults.standard
        if let loaded = standards.object(forKey: "people") as? Data {
            let decoder = JSONDecoder()
            do {
                people = try decoder.decode([Person].self, from: loaded)
                                
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            } catch {
                
            }
        }
    }
    
    func getDocumentDirectory() -> URL{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else {
            fatalError("Unable to create PersonCell")
        }
        
        let person = people[indexPath.item]
        cell.label.text = person.name
        
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uac = UIAlertController(title: "What name?", message: nil, preferredStyle: .alert)
        uac.addTextField()
        uac.addAction(UIAlertAction(title: "New name", style: .default, handler: { [weak self] action in
            guard let newName = uac.textFields?[0].text else { return }
            
            if let person = self?.people[indexPath.item] {
                person.name = newName
                self?.save()
                self?.collectionView.reloadItems(at: [indexPath])
            }
            
        }))
        
        present(uac, animated: true)
    }


}

