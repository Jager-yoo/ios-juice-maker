//
//  EditAmountViewController.swift
//  JuiceMaker
//
//  Created by Yohan on 2021/10/27.
//

import UIKit

class EditAmountViewController: UIViewController {
    private let fruitStore = FruitStore.shared
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    @IBOutlet var fruitImages: [UILabel]!
    
    @IBOutlet private weak var strawberryAmountLabel: UILabel!
    @IBOutlet private weak var bananaAmountLabel: UILabel!
    @IBOutlet private weak var mangoAmountLabel: UILabel!
    @IBOutlet private weak var kiwiAmountLabel: UILabel!
    @IBOutlet private weak var pineappleAmountLabel: UILabel!
    
    @IBOutlet private weak var strawberryAmountStepper: UIStepper!
    @IBOutlet private weak var bananaAmountStepper: UIStepper!
    @IBOutlet private weak var mangoAmountStepper: UIStepper!
    @IBOutlet private weak var kiwiAmountStepper: UIStepper!
    @IBOutlet private weak var pineappleAmountStepper: UIStepper!
    
    @IBAction private func fruitAmountSteppersHandler(_ stepper: UIStepper) {
        switch stepper {
        case strawberryAmountStepper:
            editFruitAmount(fruit: .strawberry, from: stepper)
        case bananaAmountStepper:
            editFruitAmount(fruit: .banana, from: stepper)
        case mangoAmountStepper:
            editFruitAmount(fruit: .mango, from: stepper)
        case kiwiAmountStepper:
            editFruitAmount(fruit: .kiwi, from: stepper)
        case pineappleAmountStepper:
            editFruitAmount(fruit: .pineapple, from: stepper)
        default:
            showAppTerminatingAlert()
        }
        
        feedbackGenerator.selectionChanged()
    }

    @IBAction func touchUpDismissButton(_ sender: UIBarButtonItem) {
        notificationCenter.post(name: .didEditAmount, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyAccessibility()
        do {
            try updateAllFruitAmountLabels()
            try initializeAllFruitAmountSteppers()
        } catch {
            showAppTerminatingAlert()
        }
    }
    
    private func updateAllFruitAmountLabels() throws {
        guard let strawberryAmount = fruitStore.inventory[.strawberry],
              let bananaAmount = fruitStore.inventory[.banana],
              let mangoAmount = fruitStore.inventory[.mango],
              let kiwiAmount = fruitStore.inventory[.kiwi],
              let pineappleAmount = fruitStore.inventory[.pineapple] else {
                  throw JuiceMakerError.fruitNotFound
              }
        
        strawberryAmountLabel.text = String(strawberryAmount)
        strawberryAmountLabel.accessibilityLabel = "\(strawberryAmount)개"
        bananaAmountLabel.text = String(bananaAmount)
        bananaAmountLabel.accessibilityLabel = "\(bananaAmount)개"
        mangoAmountLabel.text = String(mangoAmount)
        mangoAmountLabel.accessibilityLabel = "\(mangoAmount)개"
        kiwiAmountLabel.text = String(kiwiAmount)
        kiwiAmountLabel.accessibilityLabel = "\(kiwiAmount)개"
        pineappleAmountLabel.text = String(pineappleAmount)
        pineappleAmountLabel.accessibilityLabel = "\(pineappleAmount)개"
    }
    
    private func initializeAllFruitAmountSteppers() throws {
        guard let strawberryAmount = fruitStore.inventory[.strawberry],
              let bananaAmount = fruitStore.inventory[.banana],
              let mangoAmount = fruitStore.inventory[.mango],
              let kiwiAmount = fruitStore.inventory[.kiwi],
              let pineappleAmount = fruitStore.inventory[.pineapple] else {
                  throw JuiceMakerError.fruitNotFound
              }
        
        strawberryAmountStepper.value = Double(strawberryAmount)
        bananaAmountStepper.value = Double(bananaAmount)
        mangoAmountStepper.value = Double(mangoAmount)
        kiwiAmountStepper.value = Double(kiwiAmount)
        pineappleAmountStepper.value = Double(pineappleAmount)
    }
    
    private func updateFruitStoreInventory(fruit: Fruit, from stepper: UIStepper) throws {
        let stepperValue = Int(stepper.value)
        
        guard let inventoryValue = fruitStore.inventory[fruit] else {
            throw JuiceMakerError.fruitNotFound
        }
        
        if stepperValue >= inventoryValue {
            try fruitStore.increase(fruit, amount: stepperValue - inventoryValue)
        } else {
            try fruitStore.decrease(fruit, amount: inventoryValue - stepperValue)
        }
    }
    
    private func editFruitAmount(fruit: Fruit, from stepper: UIStepper) {
        do {
            try updateFruitStoreInventory(fruit: fruit, from: stepper)
            try updateAllFruitAmountLabels()
        } catch {
            showAppTerminatingAlert()
        }
    }
    
    private func showAppTerminatingAlert() {
        let title = "시스템 오류가 발생했습니다."
        let message = "앱이 5초 뒤 종료됩니다...\n개발자에게 문의해주세요."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let terminateAction = UIAlertAction(title: "지금 종료", style: .destructive) { _ in
            self.terminateAppGracefullyAfter(second: 0)
        }
        
        alert.addAction(terminateAction)
        present(alert, animated: true) {
            self.terminateAppGracefullyAfter(second: 5.0)
        }
    }
    
    private func terminateAppGracefullyAfter(second: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + second) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(-1)
            }
        }
    }
    
    private func applyAccessibility() {
        fruitImages.forEach { image in
            image.accessibilityLabel = "현재 \(image.text!) 재고"
        }
        
        strawberryAmountStepper.accessibilityUserInputLabels = ["감소", "증가"]
    }
}
