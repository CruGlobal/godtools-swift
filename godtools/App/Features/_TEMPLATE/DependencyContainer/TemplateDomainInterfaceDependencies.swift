import Foundation

class TemplateDomainInterfaceDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: TemplateDataLayerDependenciesInterface
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: TemplateDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
}
