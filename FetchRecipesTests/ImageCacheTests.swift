import XCTest
@testable import Recipes

final class ImageCacheTests: XCTestCase {
    var sut: ImageCache!
    
    override func setUp() {
        super.setUp()
        sut = ImageCache.shared
    }
    
    override func tearDown() {
        // Clear cache after each test
        sut = nil
        super.tearDown()
    }
    
    func testImageCaching() async {
        let testImage = UIImage()
        let testKey = "test-key"
        
        // Test setting image
        await sut.set(testImage, forKey: testKey)
        
        // Test retrieving image
        let cachedImage = await sut.object(forKey: testKey)
        XCTAssertNotNil(cachedImage)
    }
    
    func testCacheMiss() async {
        let cachedImage = await sut.object(forKey: "non-existent-key")
        XCTAssertNil(cachedImage)
    }
} 
