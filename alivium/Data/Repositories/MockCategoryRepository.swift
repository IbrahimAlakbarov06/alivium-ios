//
//  MockCategoryRepository.swift
//  alivium
//

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Category endpoints are wired (CLAUDE.md Phase 2). "Clothing" carries real subcategories so
/// Discover's expandable category list has actual hierarchy to render, not a flat list;
/// Shoes/Bags/Accessories stay leaf categories, doubling as Discover's banner set.
final class MockCategoryRepository: CategoryRepository {
    func fetchTopLevelCategories() async throws -> [Category] {
        try await Task.sleep(for: .seconds(1))
        return [
            Category(id: "new-in", name: "New In", parentId: nil, subcategories: [], itemCount: 52),
            Category(
                id: "clothing", name: "Clothing", parentId: nil,
                subcategories: [
                    Category(id: "dresses", name: "Dresses", parentId: "clothing", subcategories: [], itemCount: 36),
                    Category(id: "skirts", name: "Skirts", parentId: "clothing", subcategories: [], itemCount: 40),
                    Category(id: "jackets", name: "Jackets", parentId: "clothing", subcategories: [], itemCount: 128),
                    Category(id: "sweaters", name: "Sweaters", parentId: "clothing", subcategories: [], itemCount: 64),
                    Category(id: "jeans", name: "Jeans", parentId: "clothing", subcategories: [], itemCount: 58),
                    Category(id: "t-shirts", name: "T-Shirts", parentId: "clothing", subcategories: [], itemCount: 74),
                    Category(id: "pants", name: "Pants", parentId: "clothing", subcategories: [], itemCount: 45)
                ],
                itemCount: 0
            ),
            Category(id: "shoes", name: "Shoes", parentId: nil, subcategories: [], itemCount: 88),
            Category(id: "bags", name: "Bags", parentId: nil, subcategories: [], itemCount: 67),
            Category(id: "accessories", name: "Accessories", parentId: nil, subcategories: [], itemCount: 112),
            Category(id: "sale", name: "Sale", parentId: nil, subcategories: [], itemCount: 39)
        ]
    }
}
