import Foundation

class TemplateDomainLayerDependencies {
    
    private let domainInterfaceLayer: TemplateDomainInterfaceDependencies
    
    init(domainInterfaceLayer: TemplateDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
}
