import Foundation

class TemplateDataLayerDependencies: TemplateDataLayerDependenciesInterface {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
    }
}
