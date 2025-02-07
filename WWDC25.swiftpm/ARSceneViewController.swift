//
//  SceneViewController.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//
import UIKit
import ARKit
import Vision
import SwiftUI
import RealityKit
import simd


class ARSceneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
    var arView: ARSCNView
    @ObservedObject var appRouter: AppRouter

    let node = SCNScene(named: "guitar.scn")!.rootNode.childNodes[0]
    let indexSphere2 = SCNScene(named: "guitar.scn")!.rootNode.childNode(withName: "index", recursively: true)
    let indexSphere: SCNNode = {
        let sphere = SCNSphere(radius: 0.008)
        let node = SCNNode(geometry: sphere)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        node.geometry?.materials = [material]
        return node
    }()
    
    let debugNode: SCNNode = {

        let debugSphere = SCNSphere(radius: 0.03)
        let debugMaterial = SCNMaterial()
        debugMaterial.diffuse.contents = UIColor.systemPink
        debugSphere.materials = [debugMaterial]

        let debugNode = SCNNode(geometry: debugSphere)
        return debugNode
    }()
    
   


    
    let sequenceHandler = VNSequenceRequestHandler()
    let handPoseRequest = VNDetectHumanHandPoseRequest()
    var previousHandY: CGFloat?
    
    let soundPlayer = SoundPlayer()
    var currentChord: SoundPlayer.Chord? = nil
    
    
    init(size: CGSize, appRouter: AppRouter) {
        self.arView = ARSCNView(frame: CGRect(origin: .zero, size: size))
        self.appRouter = appRouter
        super.init(nibName: nil, bundle: nil)
        
        self.view = self.arView
        
        // Configurações básicas do ARSCNView
        arView.scene = SCNScene()
        arView.delegate = self
        arView.session.delegate = self
        arView.allowsCameraControl = false
        arView.showsStatistics = false
        arView.debugOptions = []
        arView.backgroundColor = UIColor.black
        
        // Configurar a sessão de AR (camera de selfie)
        let configuration = ARFaceTrackingConfiguration()
        configuration.isWorldTrackingEnabled = true
        configuration.isLightEstimationEnabled = true
        
        handPoseRequest.maximumHandCount = 2 // Detecta apenas uma mão

        // Permite usar iluminação adaptativa
        arView.session.run(configuration)

        applyShader(to: node)
        node.position = SCNVector3(0, 0, 1)
        // Aplica a rotação no eixo Y do violão, para que ele olhe para a direção da câmera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        node.constraints = [billboardConstraint]
        
        arView.scene.rootNode.addChildNode(debugNode) // Adiciona na cena

        arView.scene.rootNode.addChildNode(node)
        node.addChildNode(indexSphere)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        processHandPose(pixelBuffer: pixelBuffer, frame)
        positionGuitar(frame: frame)
    }
    
    // Método para posicionar o violão com base na face (câmera frontal)
    func positionGuitar(frame: ARFrame) {
        
        // Definir os valores de deslocamento
        let distanceToCamera: Float = 0.5
        let leftOffset: Float = 0
        let downOffset: Float = 0.5
        
        // Obtém a âncora da face rastreada pela câmera frontal
        guard let faceAnchor = arView.session.currentFrame?.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else { return }
        
        let cameraTransform = frame.camera.transform
        
        // Calcula a posição da face (usando a transformação do anchor da face)
        let facePosition = SCNVector3(faceAnchor.transform.columns.3.x,
                                      faceAnchor.transform.columns.3.y,
                                      faceAnchor.transform.columns.3.z)
        
        // Determina a direção da câmera (a orientação da câmera)
        let cameraDirection = SCNVector3(cameraTransform.columns.2.x,
                                         cameraTransform.columns.2.y,
                                         cameraTransform.columns.2.z)
        
        // Calcula o deslocamento de proximidade da câmera
        let oneMeterCloser = SCNVector3(
            facePosition.x - cameraDirection.x * distanceToCamera,
            facePosition.y - cameraDirection.y * distanceToCamera,
            facePosition.z - cameraDirection.z * distanceToCamera
        )
        
        // Adiciona o deslocamento para a esquerda
        let halfMeterLeft = SCNVector3(
            oneMeterCloser.x - leftOffset,  // Desloca à esquerda
            oneMeterCloser.y,               // Não altera a posição Y aqui
            oneMeterCloser.z                // Não altera a posição Z aqui
        )
        
        // Adiciona o deslocamento para baixo
        let finalPosition = SCNVector3(
            halfMeterLeft.x,          // Posição ajustada para a esquerda
            halfMeterLeft.y - downOffset,   // Desloca para baixo
            halfMeterLeft.z           // Não altera a posição Z aqui
        )
        
        // Coloca o node na nova posição ajustada
        node.position = finalPosition
        indexSphere.position = SCNVector3(x: 0.56, y: -0.24, z: -0.07)
    }
    
    func processHandPose(pixelBuffer: CVPixelBuffer, _ frame: ARFrame) {
        do {
            // Processa o quadro capturado com o Vision
            try sequenceHandler.perform([handPoseRequest], on: pixelBuffer)
            // Recupera a observação da primeira mão detectada
            let observations = handPoseRequest.results
            
            if let observations {
                for observation in observations {
                    handleHandPoseResults(observation, frame,pixelBuffer)
                }
            } else {
                print("Nenhuma mão detectada")
                return
            }
            
        } catch {
            print("Erro ao processar o quadro: \(error.localizedDescription)")
        }
    }

    // Função para processar os resultados da observação
    func handleHandPoseResults(_ observation: VNHumanHandPoseObservation,_ frame: ARFrame,_ pixelBuffer: CVPixelBuffer) {
        // Obtenha o ponto do "wrist" (pulso)
        do {
            if observation.chirality == .left {
                
                let wristPoint = try observation.recognizedPoint(.wrist)
                if wristPoint.confidence < 0.5 { // Confiança mínima
                    
                    // Converta o ponto normalizado do Vision para coordenadas 2D
                    let wristY = wristPoint.y // Apenas o valor Y para detectar movimentos verticais
                    
                    if let previousY = previousHandY {
                        // Calcule a diferença de Y entre frames
                        let movementDelta = wristY - previousY
                        
                        if movementDelta < -0.05 { // Threshold para "cima para baixo"
                            print("Hand moved DOWN")
                            if let chord = currentChord {
                                soundPlayer.playChord(chord)
                            } else {
                                print("Sem Acorde na mão")
                            }
                        } else if movementDelta > 0.05 { // Threshold para "baixo para cima"
                            print("Hand moved UP")
                        }
                    }
                    previousHandY = wristY
                    
                }
            } else if observation.chirality == .right{
                let recognizedPoints = try observation.recognizedPoints(.all)
                
                // Supondo que `recognizedPoints` seja um dicionário do tipo [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]

                if let indexTip = recognizedPoints[.indexTip],
                   let indexDIP = recognizedPoints[.indexDIP],
                   let indexPIP = recognizedPoints[.indexPIP],
                   let indexMCP = recognizedPoints[.indexMCP],
                   
                   let middleTip = recognizedPoints[.middleTip],
                   let middleDIP = recognizedPoints[.middleDIP],
                   let middlePIP = recognizedPoints[.middlePIP],
                   let middleMCP = recognizedPoints[.middleMCP],

                   let ringTip = recognizedPoints[.ringTip],
                   let ringDIP = recognizedPoints[.ringDIP],
                   let ringPIP = recognizedPoints[.ringPIP],
                   let ringMCP = recognizedPoints[.ringMCP] {
                    
                    let indexTipPosition = SCNVector3(1.55 * Float(indexTip.location.x) - 0.775, 1.2 * Float(indexTip.location.y) - 0.6, 0)
                    let middleTipPosition = SCNVector3(1.55 * Float(middleTip.location.x) - 0.775, 1.2 * Float(middleTip.location.y) - 0.6, 0)
                    let ringTipPosition = SCNVector3(1.55 * Float(ringTip.location.x) - 0.775, 1.2 * Float(ringTip.location.y) - 0.6, 0)
                    
                    let screenWidth = Float(view.bounds.width)
                    let screenHeight = Float(view.bounds.height)

                    let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
                    let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

                    // Converter a posição do ponto para coordenadas do PixelBuffer
                    var indexTipPixelBufferPosition = CGPoint(
                        x: indexTip.location.x * pixelBufferWidth,
                        y: (1 - indexTip.location.y) * pixelBufferHeight // Ajuste do eixo Y
                    )

                    // Detectar orientação da imagem do buffer (a câmera captura em landscape por padrão)
                    let cameraIntrinsicMatrix = frame.camera.intrinsics
                    let cameraAspectRatio = cameraIntrinsicMatrix[1, 1] / cameraIntrinsicMatrix[0, 0]


                    var indexTipUnscaledScreenPosition: CGPoint

                    if cameraAspectRatio < 1 {
                        // Se a razão entre os coeficientes da matriz intrínseca for < 1, a imagem do pixelBuffer está em LANDSCAPE
                        indexTipUnscaledScreenPosition = CGPoint(
                            x: indexTipPixelBufferPosition.y * (CGFloat(screenWidth) / pixelBufferHeight),
                            y: indexTipPixelBufferPosition.x * (CGFloat(screenHeight) / pixelBufferWidth)
                        )
                    } else {
                        // Se a razão for >= 1, o pixelBuffer já está em PORTRAIT
                        indexTipUnscaledScreenPosition = CGPoint(
                            x: indexTipPixelBufferPosition.x * (CGFloat(screenWidth) / pixelBufferWidth),
                            y: indexTipPixelBufferPosition.y * (CGFloat(screenHeight) / pixelBufferHeight)
                        )
                    }
                    
                    let screenRatio: CGFloat = CGFloat(screenWidth/screenHeight)
                    let bufferRatio = pixelBufferWidth/pixelBufferHeight


                    //ipad: 1080 x 810 - X 1.33x e Y 1.0x
                    //iphone: 852 x 393 - X 1.0x e Y 1.6x ; resolution: 1440 x 1080
                    var scaleFactorY = 1.0
                    let halfScreenHeight = screenHeight/2
                    var scaleFactorX = 1.0
                    let halfScreenWidth = screenWidth/2
                    
                    if(screenRatio > bufferRatio){
                        scaleFactorY = screenRatio/bufferRatio
                    } else {
                        scaleFactorX = bufferRatio/screenRatio
                    }
                    
                    // Distancia baseada no mundo
                    
                    // A correção para o eixo Y pode ser quebrada em partes mais simples.
                    let adjustedY = indexTipUnscaledScreenPosition.y * scaleFactorY
                    let yCorrection = (halfScreenHeight * Float(scaleFactorY)) - halfScreenHeight
                    

                    // Distancia baseada no mundo
                    
                    // A correção para o eixo Y pode ser quebrada em partes mais simples.
                    let adjustedX = indexTipUnscaledScreenPosition.x * scaleFactorX
                    let xCorrection = (halfScreenWidth * Float(scaleFactorX)) - halfScreenWidth
                    
                    // Agora, podemos construir a posição 3D ajustada separadamente.
                    let indexTipScreenPosition = CGPoint(
                        x: adjustedX - Double(xCorrection),
                        y: adjustedY - Double(yCorrection)
                    )
                   
                    
                    if let material = node.childNodes[0].geometry?.firstMaterial {
                        material.setValue(NSValue(scnVector3: SCNVector3(x: Float(indexTipPosition.x), y: Float(indexTipPosition.y), z: 0)), forKey: "indexTip")
                        material.setValue(NSValue(scnVector3: SCNVector3(x: Float(middleTipPosition.x), y: Float(middleTipPosition.y), z: 0)), forKey: "middleTip")
                        material.setValue(NSValue(scnVector3: SCNVector3(x: Float(ringTipPosition.x), y: Float(ringTipPosition.y), z: 0)), forKey: "ringTip")
//                        material.setValue(NSValue(scnMatrix4: SCNMatrix4(inverseRotation)), forKey: "rotationMatrix")
                    }
                
                    let worldTransform = indexSphere.presentation.worldTransform
                    let sphereWorldPos = SCNVector3(
                        worldTransform.m41,
                        worldTransform.m42,
                        worldTransform.m43
                    )
                    
                    // projeta a esfera na tela para saber seu zNear, para unproject no mesmo ponto depois
                    let projectedPoint = arView.projectPoint(sphereWorldPos)
                    
                    //ipad: 1080 x 810 - X 1.33x e Y 1.0x
                    //iphone: 852 x 393 - X 1.0x e Y 1.6x ; resolution: 1440 x 1080
                        //ratio width 2.16
                        //ratio resolution 1.333
                        //r/r = 1.6 -> scale
                    
                    // Distancia baseada no mundo
                    
                    let unprojectedFinger = arView.unprojectPoint(SCNVector3(
                        indexTipScreenPosition.x,
                        indexTipScreenPosition.y,
                        CGFloat(projectedPoint.z)
                    ))
                    
                    let distance = hypot(
                        sphereWorldPos.x - unprojectedFinger.x,
                        sphereWorldPos.y - unprojectedFinger.y
                    )
                    
                    debugNode.position = unprojectedFinger
                
                    if distance < 0.03 {
                        print("Perto")
                        indexSphere.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                        indexSphere.geometry?.firstMaterial?.emission.contents = UIColor.green
                    } else {
                        indexSphere.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                        indexSphere.geometry?.firstMaterial?.emission.contents = UIColor.red
                    }

                }

            }
            
        }
        catch {
            print("Erro ao processar os pontos da mão: \(error)")
        }
    }

    func applyShader(to node: SCNNode) {
        guard let material = node.childNodes[0].geometry?.firstMaterial else { return }
            
        material.shaderModifiers = [.fragment: shader]
        material.setValue(NSValue(scnVector3: SCNVector3Zero), forKey: "indexTip")
        material.setValue(NSValue(scnVector3: SCNVector3Zero), forKey: "middleTip")
        material.setValue(NSValue(scnVector3: SCNVector3Zero), forKey: "ringTip")
//        material.setValue(NSValue(scnMatrix4: SCNMatrix4()), forKey: "rotationMatrix")

    }
    
    let shader = """
    #pragma arguments
    float3 indexTip;   // Posição 3D do dedo indicador
    float3 middleTip;  // Posição 3D do dedo médio
    float3 ringTip;    // Posição 3D do dedo anelar
    
    #pragma body
    
    // Apenas os componentes x e y da posição ajustada
    float2 fragPos = _surface.position.xy/_surface.position.z;
    fragPos = -fragPos;
    
    // Pegando apenas os componentes 2D (x e y) dos dedos
    float2 indexTip2D = indexTip.xy;  // Posição 2D do dedo indicador
    float2 middleTip2D = middleTip.xy;  // Posição 2D do dedo médio
    float2 ringTip2D = ringTip.xy;  // Posição 2D do dedo anelar

    // Distância entre o fragmento e cada dedo
    float distToIndex = distance(fragPos, indexTip2D);
    float distToMiddle = distance(fragPos, middleTip2D);
    float distToRing = distance(fragPos, ringTip2D);
    
    // Se o fragmento estiver muito próximo de qualquer dedo, torná-lo transparente
    if (distToIndex < 0.03 || distToMiddle < 0.03 || distToRing < 0.03) {
        _output.color.a = 0.0;  // Torna o fragmento transparente
    } else {
        _output.color.a = 1.0;  // Mantém o fragmento visível
    }
    
    if (_surface.position.y/_surface.position.z >= -0.1 && _surface.position.y/_surface.position.z  <= -0.09){
        _output.color.rgb = float3(1,0,0);
    }
    if (_surface.position.x/_surface.position.z  <= 0.1 && _surface.position.x/_surface.position.z  >= 0.09){
        _output.color.rgb = float3(0,1,0);
    }
    """
}
