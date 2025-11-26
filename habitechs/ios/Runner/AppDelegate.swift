import Flutter
import UIKit
import GoogleMaps  // ✅ AGREGAR ESTA LÍNEA

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // ✅ AGREGAR ESTA LÍNEA - Reemplaza "TU_API_KEY_AQUI" con tu API Key real
    GMSServices.provideAPIKey("AIzaSyD5irDhJ8_fjhZmmWkc9bhh6OMNwdGGCb4")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}