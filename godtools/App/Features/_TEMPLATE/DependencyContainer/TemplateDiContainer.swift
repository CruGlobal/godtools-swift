import Foundation

class TemplateDiContainer {
        
    let dataLayer: TemplateDataLayerDependenciesInterface
    let domainInterfaceLayer: TemplateDomainInterfaceDependencies
    let domainLayer: TemplateDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: TemplateDataLayerDependenciesInterface, domainInterfaceLayer: TemplateDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = TemplateDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
