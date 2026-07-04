//
//  CategoryRepository.swift
//  alivium
//

protocol CategoryRepository {
    func fetchTopLevelCategories() async throws -> [Category]
}
