//
//  ScreenState.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

enum ScreenState<T> { 
    case loading
    case empty
    case content(items: [T], isLoadingNextPage: Bool = false, paginationErrorMessage: String? = nil)
    case error(String)
}
