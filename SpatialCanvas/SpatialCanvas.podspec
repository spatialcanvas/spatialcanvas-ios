Pod::Spec.new do |s|
    s.name              = "SpatialCanvas"
    s.version           = "0.5.3"
    s.summary           = "AR Persistance"
    s.homepage          = "https://github.com/spatialcanvas/spatialcanvas-ios"
    s.author            = { "Victor Mateevitsi" => "victor@spatialcanvas.com" }
    s.license           = { :type => "Commercial", :file => "LICENSE" }
    s.platform          = :ios
    s.source            = { :http => "https://github.com/spatialcanvas/spatialcanvas-ios/releases/download/#{s.version}/SpatialCanvas.zip" }
    s.ios.deployment_target = "11.3"
    s.ios.vendored_frameworks = "SpatialCanvas.framework"
end
