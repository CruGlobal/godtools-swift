import Foundation

class TemplateDomainInterfaceDependencies {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    private let dataLayer: TemplateDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: TemplateDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
}
