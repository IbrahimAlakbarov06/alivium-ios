//
//  MockCategoryRepository.swift
//  alivium
//

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Category endpoints are wired (CLAUDE.md Phase 2).
final class MockCategoryRepository: CategoryRepository {
    func fetchTopLevelCategories() async throws -> [Category] {
        try await Task.sleep(for: .seconds(1))
        return [
            Category(id: "new-in", name: "New In", parentId: nil, subcategories: []),
            Category(id: "dresses", name: "Dresses", parentId: nil, subcategories: []),
            Category(id: "tops", name: "Tops", parentId: nil, subcategories: []),
            Category(id: "skirts", name: "Skirts", parentId: nil, subcategories: []),
            Category(id: "pants", name: "Pants", parentId: nil, subcategories: []),
            Category(id: "shoes", name: "Shoes", parentId: nil, subcategories: []),
            Category(id: "bags", name: "Bags", parentId: nil, subcategories: []),
            Category(id: "accessories", name: "Accessories", parentId: nil, subcategories: []),
            Category(id: "sale", name: "Sale", parentId: nil, subcategories: [])
        ]
    }
}
