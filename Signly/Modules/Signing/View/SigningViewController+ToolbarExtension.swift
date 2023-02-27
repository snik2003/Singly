//
//  SigningViewController+ToolbarExtension.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit
import IQKeyboardManager

extension SigningViewController {
    
    var toolbarShown: Bool {
        return toolbarViewBottomConstraint.constant == 10
    }
    
    func setupToolbarInitialState() {
        animationDuration = KeyboardService.keyboardAnimationDuration()
        animationCurve = KeyboardService.keyboardAnimationCurve()
        
        toolbar.backgroundColor = .white
        toolbar.clipsToBounds = true
        toolbar.layer.cornerRadius = 12
        toolbarView.backgroundColor = .white
        toolbarView.clipsToBounds = true
        toolbarView.layer.cornerRadius = 12
        toolbarView.dropShadow(color: .appDarkTextColor60, opacity: 0.5, offSet: CGSize(width: 0.3, height: 0.3), radius: 12, scale: false)
        
        toolbarViewHeightConstraint.constant = KeyboardService.keyboardHeight() + toolbarHeightConstraint.constant + 10
        toolbarViewBottomConstraint.constant = toolbarViewHeightConstraint.constant
        
        textTableView.delegate = self
        textTableView.dataSource = self
        textTableView.register(FormProfileCell.self)
        textTableView.register(FormHistoryCell.self)
        textTableView.register(FormPaintbrushCell.self)
        
        updateToolbarButtonsState()
        addKeyboardObservers()
        addSwipeGesture()
    }
    
    func initToolbarView(form: SignatureForm, textField: UITextField) {
        self.focusedForm = form
        
        self.textField = textField
        self.textField.backgroundColor = .appSystemColor10
        self.textField.text = form.type == .date ? SignatureForm.dateFormatter.string(from: form.signDate) : form.signText
        self.textField.font = PaintbrushSettings.shared.currentFont()
        
        self.textField.delegate = self
        self.textField.removeTarget(self, action: nil, for: .allEvents)
        self.textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        
        self.keyboardButton.alpha = form.type == .date ? 0.0 : 1.0
        self.profileButton.alpha = form.type == .date ? 0.0 : 1.0
        self.historyButton.alpha = form.type == .date ? 0.0 : 1.0
        self.brushButton.alpha = form.type == .date ? 0.0 : 1.0
        
        self.toolbarViewHeightConstraint.constant = KeyboardService.keyboardHeight() + toolbarHeightConstraint.constant + 10
        self.toolbarViewBottomConstraint.constant = toolbarViewHeightConstraint.constant
        
        guard form.type == .text else {
            self.hideCalendarView() {
                self.brushButtonAction()
                self.showToolbarView()
            }
            return
        }
        
        self.textField.becomeFirstResponder()
        self.showToolbarView()
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    private func addSwipeGesture() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .down
        swipe.addTarget(self, action: #selector(toolbarTapHandler))
        toolbarView.addGestureRecognizer(swipe)
    }
    
    private func updateToolbarButtonsState(sender: UIButton? = nil) {
        profileButton.tintColor = .appSystemColor60
        historyButton.tintColor = .appSystemColor60
        brushButton.tintColor = .appSystemColor60
        keyboardButton.tintColor = .appSystemColor60
        saveTextButton.tintColor = .appSystemColor
        
        guard let sender = sender else { return }
        sender.tintColor = .appSystemColor
    }
    
    @IBAction func profileButtonAction() {
        guard let textField = textField, let text = textField.text, !text.isEmpty else { return }
        guard let form = focusedForm else { return }
        
        self.textModel = .profile
        self.dataSource2 = textModel.dataSource(presenter)
        self.textTableView.reloadData()
        self.updateToolbarButtonsState(sender: profileButton)
        
        profileButton.viewTouched {
            textField.resignFirstResponder()
            form.prepareAfterEditTextField(text: text, showMenu: false)
        }
    }
    
    @IBAction func historyButtonAction() {
        guard let textField = textField, let text = textField.text, !text.isEmpty else { return }
        guard let form = focusedForm else { return }
        
        self.textModel = .history
        self.dataSource2 = textModel.dataSource(presenter)
        self.textTableView.reloadData()
        self.updateToolbarButtonsState(sender: historyButton)
        
        historyButton.viewTouched {
            textField.resignFirstResponder()
            form.prepareAfterEditTextField(text: text, showMenu: false)
        }
    }
    
    @IBAction func brushButtonAction() {
        guard let textField = textField, let text = textField.text, !text.isEmpty else { return }
        guard let form = focusedForm else { return }
        
        self.textModel = .paintbrush
        self.dataSource2 = textModel.dataSource(presenter)
        self.textTableView.reloadData()
        self.updateToolbarButtonsState(sender: brushButton)
        
        brushButton.viewTouched {
            textField.resignFirstResponder()
            form.prepareAfterEditTextField(text: text, showMenu: false)
        }
    }
    
    @IBAction func editDateStyleButtonAction() {
        guard let form = calendarView.delegate as? SignatureForm else { return }
        form.prepareBeforeEditDate()
    }
    
    @IBAction func keyboardButtonAction() {
        guard let textField = textField else { return }
        guard let form = focusedForm else { return }
        
        keyboardButton.viewTouched {
            textField.text = form.signText
            form.selectKeyboardEditingType()
            textField.becomeFirstResponder()
        }
    }
    
    func showToolbarView(animated: Bool = true, completion: EmptyBlock? = nil) {
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: animationCurve),
                       animations: {
            self.blockView.alpha = 1.0
            self.toolbarViewBottomConstraint.constant = 10
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    func hideToolbarView(animated: Bool = true, completion: EmptyBlock? = nil) {
        self.view.endEditing(true)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: animationCurve),
                       animations: {
            self.blockView.alpha = 0.0
            self.toolbarViewBottomConstraint.constant = self.toolbarViewHeightConstraint.constant - 10
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        updateToolbarButtonsState(sender: keyboardButton)
    }
    
    @objc func toolbarTapHandler() {
        guard let textField = textField else { return }
        guard let text = textField.text, !text.isEmpty else { return }
        guard let form = focusedForm else { return }
        
        guard form.type == .text else {
            form.prepareAfterEditDate()
            hideToolbarView()
            return
        }
        
        textField.resignFirstResponder()
        form.prepareAfterEditTextField(text: text)
        hideToolbarView() {
            self.presenter?.saveInHistoryCache(text)
        }
    }
    
    @IBAction func saveTextButtonAction() {
        guard let textField = textField else { return }
        guard let text = textField.text, !text.isEmpty else { return }
        guard let form = focusedForm else { return }
        
        saveTextButton.viewTouched {
            guard form.type == .text else {
                form.prepareAfterEditDate()
                self.hideToolbarView()
                return
            }
            
            textField.resignFirstResponder()
            form.prepareAfterEditTextField(text: text)
            self.hideToolbarView() {
                self.presenter?.saveInHistoryCache(text)
            }
        }
    }
}

extension SigningViewController: UITextFieldDelegate {
    
    @objc
    func textFieldTextDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let form = focusedForm else { return }
        form.updateTextField(text: text)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let position = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        guard let form = focusedForm else { return false }
        
        textField.resignFirstResponder()
        form.prepareAfterEditTextField(text: text)
        hideToolbarView()  {
            self.presenter?.saveInHistoryCache(text)
        }
        
        return true
    }
}

extension SigningViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource2.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return textModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if textModel == .profile, let model = dataSource2[indexPath.row] as? SettingsModel {
            let cell: FormProfileCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model)
            return cell
        } else if textModel == .history, let model = dataSource2[indexPath.row] as? HistoryCacheModel {
            let cell: FormHistoryCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model)
            return cell
        } else if textModel == .paintbrush, let model = dataSource2[indexPath.row] as? PaintbrushModel {
            let cell: FormPaintbrushCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(model: model)
            return cell
        }
        
        return UITableViewCell()
    }
}
