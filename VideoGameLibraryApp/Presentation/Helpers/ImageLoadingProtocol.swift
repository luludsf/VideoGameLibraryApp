//
//  ImageLoadingProtocol.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

protocol ImageLoadingProtocol {
    func loadImage(from url: URL) async -> UIImage?
}
