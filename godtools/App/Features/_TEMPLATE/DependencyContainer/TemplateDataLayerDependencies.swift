import Foundation

class TemplateDataLayerDependencies: TemplateDataLayerDependenciesInterface {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
}
