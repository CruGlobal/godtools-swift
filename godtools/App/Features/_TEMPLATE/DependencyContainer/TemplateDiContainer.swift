import Foundation

class TemplateDiContainer {
        
    let dataLayer: TemplateDataLayerDependencies
    let domainInterfaceLayer: TemplateDomainInterfaceDependencies
    let domainLayer: TemplateDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: TemplateDataLayerDependencies, domainInterfaceLayer: TemplateDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = TemplateDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
