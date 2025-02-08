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
import simd

class ARSceneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
    var arView: ARSCNView
    @ObservedObject var appRouter: AppRouter
    
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    let sequenceHandler = VNSequenceRequestHandler()
    let handPoseRequest = VNDetectHumanHandPoseRequest()
    var previousHandY: CGFloat?
    
    let soundPlayer = SoundPlayer()
    var currentChord: SoundPlayer.Chord? = nil
    var canPlay = true
    
    let guitarNode = SCNScene(named: "guitar.scn")!.rootNode.childNodes[0]
   
    let indexSphere = TargetSphereNode(finger: .index)
    let middleSphere = TargetSphereNode(finger: .middle)
    let ringSphere = TargetSphereNode(finger: .ring)

    let debugNode: SCNNode = {
        let debugSphere = SCNSphere(radius: 0.02)
        let debugMaterial = SCNMaterial()
        debugMaterial.diffuse.contents = UIColor.systemPink
        debugSphere.materials = [debugMaterial]

        let debugNode = SCNNode(geometry: debugSphere)
        return debugNode
    }()
    
    init(size: CGSize, appRouter: AppRouter) {
        self.arView = ARSCNView(frame: CGRect(origin: .zero, size: size))
        self.appRouter = appRouter
        self.screenWidth = size.width
        self.screenHeight = size.height
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
        
        handPoseRequest.maximumHandCount = 2 // Detecta apenas uma mão

        // Permite usar iluminação adaptativa
        arView.session.run(configuration)

        arView.scene.rootNode.addChildNode(debugNode) // Adiciona na cena

        arView.scene.rootNode.addChildNode(guitarNode)
        setCurrentChord(.A)
        guitarNode.addChildNode(indexSphere)
        guitarNode.addChildNode(middleSphere)
        guitarNode.addChildNode(ringSphere)

        applyShader(to: guitarNode)
        guitarNode.position = SCNVector3(0, 0, 1)
        // Aplica a rotação no eixo Y do violão, para que ele olhe para a direção da câmera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        guitarNode.constraints = [billboardConstraint]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setCurrentChord(_ chord: SoundPlayer.Chord){
        currentChord = chord
        
        guard let chordScheme = guitarNode.childNode(withName: chord.rawValue, recursively: true) else {
            print("Acorde sem esquema definido na cena")
            return
        }
        
        let indexPosition = chordScheme.childNode(withName: "index", recursively: true)!
        let middlePosition = chordScheme.childNode(withName: "middle", recursively: true)!
        let ringPosition = chordScheme.childNode(withName: "ring", recursively: true)!
        
        indexSphere.position = SCNVector3(
            x: -indexPosition.worldPosition.x,
            y: indexPosition.worldPosition.y,
            z: indexPosition.worldPosition.z
        )
        middleSphere.position = SCNVector3(
            x: -middlePosition.worldPosition.x,
            y: middlePosition.worldPosition.y,
            z: middlePosition.worldPosition.z
        )
        ringSphere.position = SCNVector3(
            x: -ringPosition.worldPosition.x,
            y: ringPosition.worldPosition.y,
            z: ringPosition.worldPosition.z
        )
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
        guitarNode.position = finalPosition
    }
    
    func processHandPose(pixelBuffer: CVPixelBuffer, _ frame: ARFrame) {
        do {
            // Processa o quadro capturado com o Vision
            try sequenceHandler.perform([handPoseRequest], on: pixelBuffer)
            
            // Recupera a observação das mãos detectadas
            let observations = handPoseRequest.results
            
            if let observations {
                for observation in observations {
                    handleHandPoseResults(observation, frame)
                }
            } else {
                print("Nenhuma mão detectada")
                return
            }
            
        } catch {
            print("Erro ao processar o quadro: \(error.localizedDescription)")
        }
    }

    func handleHandPoseResults(_ observation: VNHumanHandPoseObservation,_ frame: ARFrame) {
        if observation.chirality == .left {
            detectRightHand(observation: observation)
        } else if observation.chirality == .right{
            detectLeftHand(observation: observation, frame: frame)
        }
    }

    func detectRightHand(observation: VNHumanHandPoseObservation){
        do {
            let wristPoint = try observation.recognizedPoint(.wrist)
            if wristPoint.confidence > 0.5 { // Confiança mínima
                
                // Converta o ponto normalizado do Vision para coordenadas 2D
                let wristY = wristPoint.y // Apenas o valor Y para detectar movimentos verticais
                print(wristY)
                if let previousY = previousHandY {
                    // Calcule a diferença de Y entre frames
                    let movementDelta = wristY - previousY
                    
                    if movementDelta < -0.1 { // Threshold para "cima para baixo"
                        print("Hand moved DOWN")
                        if let chord = currentChord {
                            if (indexSphere.isTouched && middleSphere.isTouched && ringSphere.isTouched){
                                if canPlay {
                                    soundPlayer.playChord(chord)
                                    canPlay = false  // Bloqueia a execução

                                    // Define um cooldown de 0.5 segundos antes de permitir outra execução
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.canPlay = true
                                    }
                                }
                            } else {
                                print("Dedos fora do arranjo")
                            }
                        } else {
                            print("Sem acorde no momento")
                        }
                    } else if movementDelta > 0.05 { // Threshold para "baixo para cima"
                        print("Hand moved UP")
                    }
                }
                previousHandY = wristY
            }
        }
        catch {
            print("Erro ao processar os pontos da mão direita (batida): \(error)")
        }
    }
    
    func detectLeftHand(observation: VNHumanHandPoseObservation, frame: ARFrame){
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            // Supondo que `recognizedPoints` seja um dicionário do tipo [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]

            if let indexTip = recognizedPoints[.indexTip],
               let indexDip = recognizedPoints[.indexDIP],
               let indexPip = recognizedPoints[.indexPIP],
               let indexMcp = recognizedPoints[.indexMCP],
               
               let middleTip = recognizedPoints[.middleTip],
               let middleDip = recognizedPoints[.middleDIP],
               let middlePip = recognizedPoints[.middlePIP],
               let middleMcp = recognizedPoints[.middleMCP],

               let ringTip = recognizedPoints[.ringTip],
               let ringDip = recognizedPoints[.ringDIP],
               let ringPip = recognizedPoints[.ringPIP],
               let ringMcp = recognizedPoints[.ringMCP] {
                
                let indexTipPosition = calculatePositionForShader(fingerPos: indexTip)
                let indexDipPosition = calculatePositionForShader(fingerPos: indexDip)
                let indexPipPosition = calculatePositionForShader(fingerPos: indexPip)
                let middleTipPosition = calculatePositionForShader(fingerPos: middleTip)
                let middleDipPosition = calculatePositionForShader(fingerPos: middleDip)
                let middlePipPosition = calculatePositionForShader(fingerPos: middlePip)
                let ringTipPosition = calculatePositionForShader(fingerPos: ringTip)
                let ringDipPosition = calculatePositionForShader(fingerPos: ringDip)
                let ringPipPosition = calculatePositionForShader(fingerPos: ringPip)

                if let material = guitarNode.childNodes[0].geometry?.firstMaterial {
                    material.setValue(NSValue(cgPoint: indexTipPosition), forKey: "indexTip")
                    material.setValue(NSValue(cgPoint: indexDipPosition), forKey: "indexDip")
                    material.setValue(NSValue(cgPoint: indexPipPosition), forKey: "indexPip")

                    material.setValue(NSValue(cgPoint: middleTipPosition), forKey: "middleTip")
                    material.setValue(NSValue(cgPoint: middleDipPosition), forKey: "middleDip")
                    material.setValue(NSValue(cgPoint: middlePipPosition), forKey: "middlePip")

                    material.setValue(NSValue(cgPoint: ringTipPosition), forKey: "ringTip")
                    material.setValue(NSValue(cgPoint: ringDipPosition), forKey: "ringDip")
                    material.setValue(NSValue(cgPoint: ringPipPosition), forKey: "ringPip")
                }
                
                processFingerPosition(finger: .index, fingerLocation: indexTip.location, frame: frame)
                processFingerPosition(finger: .middle, fingerLocation: middleTip.location, frame: frame)
                processFingerPosition(finger: .ring, fingerLocation: ringTip.location, frame: frame)

            }

        } catch {
            print("Erro ao processar os pontos da mão esquerda (dedos das casas): \(error)")
        }
    }
    
    func calculatePositionForShader(fingerPos: VNRecognizedPoint) -> CGPoint{
//        let xFactor = 2*screenWidth/1000
//        let xCorrection = xFactor/2
//        let yFactor = 2*screenHeight/1000
//        let yCorrection = yFactor/2
//        return CGPoint(x: xFactor * fingerPos.location.x - xCorrection, y: yFactor * fingerPos.location.y - yCorrection)
//        Gambiarra que funciona:
        return CGPoint(x: 1.55 * fingerPos.location.x - 0.775, y: 1.2 * fingerPos.location.y - 0.6)
    }
    
    func processFingerPosition(finger: Finger, fingerLocation: CGPoint, frame: ARFrame){
        let pixelBufferWidth = frame.camera.imageResolution.width
        let pixelBufferHeight = frame.camera.imageResolution.height
        
        // Converter a posição do ponto para coordenadas do PixelBuffer
        var fingerTipPixelBufferPosition = CGPoint(
            x: fingerLocation.x * pixelBufferWidth,
            y: (1 - fingerLocation.y) * pixelBufferHeight // Ajuste do eixo Y
        )
        
        // Detectar orientação da imagem do buffer (a câmera captura em landscape por padrão)
        let cameraIntrinsicMatrix = frame.camera.intrinsics
        let cameraAspectRatio = cameraIntrinsicMatrix[1, 1] / cameraIntrinsicMatrix[0, 0]
        
        var fingerTipUnscaledScreenPosition: CGPoint
       
        if cameraAspectRatio < 1 {
            // Se a razão entre os coeficientes da matriz intrínseca for < 1, a imagem do pixelBuffer está em LANDSCAPE
            fingerTipUnscaledScreenPosition = CGPoint(
                x: fingerTipPixelBufferPosition.y * (CGFloat(screenWidth) / pixelBufferHeight),
                y: fingerTipPixelBufferPosition.x * (CGFloat(screenHeight) / pixelBufferWidth)
            )
        } else {
            // Se a razão for >= 1, o pixelBuffer já está em PORTRAIT
            fingerTipUnscaledScreenPosition = CGPoint(
                x: fingerTipPixelBufferPosition.x * (CGFloat(screenWidth) / pixelBufferWidth),
                y: fingerTipPixelBufferPosition.y * (CGFloat(screenHeight) / pixelBufferHeight)
            )
        }
        
        let screenRatio = screenWidth/screenHeight
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
                
        // A correção para o eixo Y pode ser quebrada em partes mais simples.
        let yCorrection = (halfScreenHeight * scaleFactorY) - halfScreenHeight
                        
        // A correção para o eixo Y pode ser quebrada em partes mais simples.
        let xCorrection = (halfScreenWidth * scaleFactorX) - halfScreenWidth
        
        // Agora, podemos construir a posição 3D ajustada separadamente.
        let fingerTipScreenPosition = CGPoint(
            x: fingerTipUnscaledScreenPosition.x * scaleFactorX - Double(xCorrection),
            y: fingerTipUnscaledScreenPosition.y * scaleFactorY - Double(yCorrection)
        )
        
        var fingerTarget: TargetSphereNode = indexSphere
        switch finger {
            case .index:
                break
            case .middle:
                fingerTarget = middleSphere
            case .ring:
                fingerTarget = ringSphere
        }
        
        let fingerTargetWorldTransform = fingerTarget.presentation.worldTransform
        let fingerTargetWorldPos = SCNVector3(
            fingerTargetWorldTransform.m41,
            fingerTargetWorldTransform.m42,
            fingerTargetWorldTransform.m43
        )
        
        // projeta a esfera na tela para saber seu zNear, para unproject no mesmo ponto depois
        let projectedPoint = arView.projectPoint(fingerTargetWorldPos)
        
        //ipad: 1080 x 810 - X 1.33x e Y 1.0x
        //iphone: 852 x 393 - X 1.0x e Y 1.6x ; resolution: 1440 x 1080
        //ratio width 2.16
        //ratio resolution 1.333
        //r/r = 1.6 -> scale
                
        let unprojectedFinger = arView.unprojectPoint(SCNVector3(
            fingerTipScreenPosition.x,
            fingerTipScreenPosition.y,
            CGFloat(projectedPoint.z)
        ))
        
        let distance = hypot(
            fingerTargetWorldPos.x - unprojectedFinger.x,
            fingerTargetWorldPos.y - unprojectedFinger.y
        )
        
        debugNode.position = unprojectedFinger
        
        if distance < 0.03 {
            fingerTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            fingerTarget.geometry?.firstMaterial?.emission.contents = UIColor.green
            fingerTarget.isTouched = true
        } else {
            fingerTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            fingerTarget.geometry?.firstMaterial?.emission.contents = UIColor.red
            fingerTarget.isTouched = false
        }
    }
    
    func applyShader(to node: SCNNode) {
        guard let material = node.childNodes[0].geometry?.firstMaterial else { return }
            
        material.shaderModifiers = [.fragment: shader]
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "indexTip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "indexDip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "indexPip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "middleTip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "middleDip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "middlePip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "ringTip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "ringDip")
        material.setValue(NSValue(cgPoint: CGPointZero), forKey: "ringPip")
    }
    


let shader = """
    #pragma arguments
    float2 indexTip;   // Posição do dedo indicador
    float2 indexDip;
    float2 indexPip;
    float2 middleTip;  // Posição do dedo médio
    float2 middleDip;
    float2 middlePip;
    float2 ringTip;    // Posição do dedo anelar
    float2 ringDip;
    float2 ringPip;

    
    #pragma body
    
    float2 indexMid = (indexTip + indexDip) * 0.5;
    float2 indexDownMid = (indexDip + indexPip) * 0.5;
    float2 middleMid = (middleTip + middleDip) * 0.5;
    float2 middleDownMid = (middleDip + middlePip) * 0.5;
    float2 ringMid = (ringTip + ringDip) * 0.5;
    float2 ringDownMid = (ringDip + ringPip) * 0.5;

    
    // Apenas os componentes x e y da posição ajustada
    float2 fragPos = _surface.position.xy/_surface.position.z;
    fragPos = -fragPos;
    
    

    // Distância entre o fragmento e cada dedo
    float distToIndexTip = distance(fragPos, indexTip);
    float distToIndexDip = distance(fragPos, indexDip);
    float distToIndexPip = distance(fragPos, indexPip);
    float distToMiddleTip = distance(fragPos, middleTip);
    float distToMiddleDip = distance(fragPos, middleDip);
    float distToMiddlePip = distance(fragPos, middlePip);
    float distToRingTip = distance(fragPos, ringTip);
    float distToRingDip = distance(fragPos, ringDip);
    float distToRingPip = distance(fragPos, ringPip);
    float distToIndexMid = distance(fragPos, indexMid);
    float distToMiddleMid = distance(fragPos, middleMid);
    float distToRingMid = distance(fragPos, ringMid);
    float distToIndexDownMid = distance(fragPos, indexDownMid);
    float distToMiddleDownMid = distance(fragPos, middleDownMid);
    float distToRingDownMid = distance(fragPos, ringDownMid);
    float maxD = 0.03;
    
    // Se o fragmento estiver muito próximo de qualquer dedo, torná-lo transparente
    if (distToIndexTip < maxD || distToIndexDip < maxD || distToIndexPip < maxD || distToIndexMid < maxD || distToIndexDownMid < maxD || distToMiddleTip < maxD || distToMiddleDip < maxD || distToMiddlePip < maxD || distToMiddleMid < maxD || distToMiddleDownMid < maxD || distToRingTip < maxD || distToRingDip < maxD || distToRingPip < maxD || distToRingMid < maxD || distToRingDownMid < maxD) {
        _output.color.a = 0.0;  // Torna o fragmento transparente
    } else {
        _output.color.a = 1.0;  // Mantém o fragmento visível
    }
    
    """
}
enum Finger {
    case index
    case middle
    case ring
}
