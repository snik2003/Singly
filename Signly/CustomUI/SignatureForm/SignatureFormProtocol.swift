//
//  SignatureFormProtocol.swift
//  Signly
//
//  Created by Сергей Никитин on 08.09.2022.
//

import UIKit

protocol SignatureFormProtocol {
    func formWasAdded(_ form: SignatureForm, toPage page: Int)
    func formWasRemoved(_ form: SignatureForm, fromPage page: Int)
    func formNeedCopyInAllPages(_ form: SignatureForm)
    func formNeedCopyInCurrentPage(_ form: SignatureForm)
    func formNeedEdit(_ form: SignatureForm, with type: SigningToolbarModel)
    
}
