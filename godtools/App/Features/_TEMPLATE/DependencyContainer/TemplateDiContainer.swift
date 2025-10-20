import Foundation

class TemplateDiContainer {
        
    private let dataLayer: TemplateDataLayerDependencies
    private let domainInterfaceLayer: TemplateDomainInterfaceDependencies
    
    let domainLayer: TemplateDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        let dataLayer = TemplateDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = TemplateDomainInterfaceDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
        domainLayer = TemplateDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
