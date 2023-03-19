class ClassUrlProvider:
    def __init__(self):
        self.urlDict: dict = {}
        self.godot_version = "3.5"
        self.register(
            "ApiApi",
            "InputMapApi",
            "InputMapApi/ActionConfigSyncAgent",
            "InputMapApi/InputEventEmitterNode",
            "ModConfigApi",
            "ModConfigApi/ConfigBuilder",
            "ModSignalingApi",
            "PreferencesWindowApi"

        )
        self.registerNative(
            "AABB",
            "AcceptDialog",
            "AESContext",
            "AnimatedSprite",
            "AnimatedSprite3D",
            "AnimatedTexture",
            "Animation",
            "AnimationNode",
            "AnimationNodeAdd2",
            "AnimationNodeAdd3",
            "AnimationNodeAnimation",
            "AnimationNodeBlend2",
            "AnimationNodeBlend3",
            "AnimationNodeBlendSpace1D",
            "AnimationNodeBlendSpace2D",
            "AnimationNodeBlendTree",
            "AnimationNodeOneShot",
            "AnimationNodeOutput",
            "AnimationNodeStateMachine",
            "AnimationNodeStateMachinePlayback",
            "AnimationNodeStateMachineTransition",
            "AnimationNodeTimeScale",
            "AnimationNodeTimeSeek",
            "AnimationNodeTransition",
            "AnimationPlayer",
            "AnimationRootNode",
            "AnimationTrackEditPlugin",
            "AnimationTree",
            "AnimationTreePlayer",
            "Area",
            "Area2D",
            "Array",
            "ArrayMesh",
            "ARVRAnchor",
            "ARVRCamera",
            "ARVRController",
            "ARVRInterface",
            "ARVRInterfaceGDNative",
            "ARVROrigin",
            "ARVRPositionalTracker",
            "ARVRServer",
            "AspectRatioContainer",
            "AStar",
            "AStar2D",
            "AtlasTexture",
            "AudioBusLayout",
            "AudioEffect",
            "AudioEffectAmplify",
            "AudioEffectBandLimitFilter",
            "AudioEffectBandPassFilter",
            "AudioEffectCapture",
            "AudioEffectChorus",
            "AudioEffectCompressor",
            "AudioEffectDelay",
            "AudioEffectDistortion",
            "AudioEffectEQ",
            "AudioEffectEQ10",
            "AudioEffectEQ21",
            "AudioEffectEQ6",
            "AudioEffectFilter",
            "AudioEffectHighPassFilter",
            "AudioEffectHighShelfFilter",
            "AudioEffectInstance",
            "AudioEffectLimiter",
            "AudioEffectLowPassFilter",
            "AudioEffectLowShelfFilter",
            "AudioEffectNotchFilter",
            "AudioEffectPanner",
            "AudioEffectPhaser",
            "AudioEffectPitchShift",
            "AudioEffectRecord",
            "AudioEffectReverb",
            "AudioEffectSpectrumAnalyzer",
            "AudioEffectSpectrumAnalyzerInstance",
            "AudioEffectStereoEnhance",
            "AudioServer",
            "AudioStream",
            "AudioStreamGenerator",
            "AudioStreamGeneratorPlayback",
            "AudioStreamMicrophone",
            "AudioStreamMP3",
            "AudioStreamOGGVorbis",
            "AudioStreamPlayback",
            "AudioStreamPlaybackResampled",
            "AudioStreamPlayer",
            "AudioStreamPlayer2D",
            "AudioStreamPlayer3D",
            "AudioStreamRandomPitch",
            "AudioStreamSample",
            "BackBufferCopy",
            "BakedLightmap",
            "BakedLightmapData",
            "BaseButton",
            "Basis",
            "BitMap",
            "BitmapFont",
            "Bone2D",
            "BoneAttachment",
            "bool",
            "BoxContainer",
            "BoxShape",
            "Button",
            "ButtonGroup",
            "CallbackTweener",
            "Camera",
            "Camera2D",
            "CameraFeed",
            "CameraServer",
            "CameraTexture",
            "CanvasItem",
            "CanvasItemMaterial",
            "CanvasLayer",
            "CanvasModulate",
            "CapsuleMesh",
            "CapsuleShape",
            "CapsuleShape2D",
            "CenterContainer",
            "CharFXTransform",
            "CheckBox",
            "CheckButton",
            "CircleShape2D",
            "ClassDB",
            "ClippedCamera",
            "CollisionObject",
            "CollisionObject2D",
            "CollisionPolygon",
            "CollisionPolygon2D",
            "CollisionShape",
            "CollisionShape2D",
            "Color",
            "ColorPicker",
            "ColorPickerButton",
            "ColorRect",
            "ConcavePolygonShape",
            "ConcavePolygonShape2D",
            "ConeTwistJoint",
            "ConfigFile",
            "ConfirmationDialog",
            "Container",
            "Control",
            "ConvexPolygonShape",
            "ConvexPolygonShape2D",
            "CPUParticles",
            "CPUParticles2D",
            "Crypto",
            "CryptoKey",
            "CSGBox",
            "CSGCombiner",
            "CSGCylinder",
            "CSGMesh",
            "CSGPolygon",
            "CSGPrimitive",
            "CSGShape",
            "CSGSphere",
            "CSGTorus",
            "CSharpScript",
            "CubeMap",
            "CubeMesh",
            "CullInstance",
            "Curve",
            "Curve2D",
            "Curve3D",
            "CurveTexture",
            "CylinderMesh",
            "CylinderShape",
            "DampedSpringJoint2D",
            "Dictionary",
            "DirectionalLight",
            "Directory",
            "DTLSServer",
            "DynamicFont",
            "DynamicFontData",
            "EditorExportPlugin",
            "EditorFeatureProfile",
            "EditorFileDialog",
            "EditorFileSystem",
            "EditorFileSystemDirectory",
            "EditorImportPlugin",
            "EditorInspector",
            "EditorInspectorPlugin",
            "EditorInterface",
            "EditorPlugin",
            "EditorProperty",
            "EditorResourceConversionPlugin",
            "EditorResourcePicker",
            "EditorResourcePreview",
            "EditorResourcePreviewGenerator",
            "EditorSceneImporter",
            "EditorSceneImporterFBX",
            "EditorSceneImporterGLTF",
            "EditorScenePostImport",
            "EditorScript",
            "EditorScriptPicker",
            "EditorSelection",
            "EditorSettings",
            "EditorSpatialGizmo",
            "EditorSpatialGizmoPlugin",
            "EditorSpinSlider",
            "EditorVCSInterface",
            "EncodedObjectAsID",
            "Engine",
            "Environment",
            "Expression",
            "ExternalTexture",
            "File",
            "FileDialog",
            "FileSystemDock",
            "float",
            "FlowContainer",
            "Font",
            "FuncRef",
            "GDNative",
            "GDNativeLibrary",
            "GDScript",
            "GDScriptFunctionState",
            "Generic6DOFJoint",
            "Geometry",
            "GeometryInstance",
            "GIProbe",
            "GIProbeData",
            "GLTFAccessor",
            "GLTFAnimation",
            "GLTFBufferView",
            "GLTFCamera",
            "GLTFDocument",
            "GLTFLight",
            "GLTFMesh",
            "GLTFNode",
            "GLTFSkeleton",
            "GLTFSkin",
            "GLTFSpecGloss",
            "GLTFState",
            "GLTFTexture",
            "GodotSharp",
            "Gradient",
            "GradientTexture",
            "GradientTexture2D",
            "GraphEdit",
            "GraphNode",
            "GridContainer",
            "GridMap",
            "GrooveJoint2D",
            "HashingContext",
            "HBoxContainer",
            "HeightMapShape",
            "HFlowContainer",
            "HingeJoint",
            "HMACContext",
            "HScrollBar",
            "HSeparator",
            "HSlider",
            "HSplitContainer",
            "HTTPClient",
            "HTTPRequest",
            "Image",
            "ImageTexture",
            "ImmediateGeometry",
            "Input",
            "InputEvent",
            "InputEventAction",
            "InputEventGesture",
            "InputEventJoypadButton",
            "InputEventJoypadMotion",
            "InputEventKey",
            "InputEventMagnifyGesture",
            "InputEventMIDI",
            "InputEventMouse",
            "InputEventMouseButton",
            "InputEventMouseMotion",
            "InputEventPanGesture",
            "InputEventScreenDrag",
            "InputEventScreenTouch",
            "InputEventWithModifiers",
            "InputMap",
            "InstancePlaceholder",
            "int",
            "InterpolatedCamera",
            "IntervalTweener",
            "IP",
            "ItemList",
            "JavaClass",
            "JavaClassWrapper",
            "JavaScript",
            "JavaScriptObject",
            "JNISingleton",
            "Joint",
            "Joint2D",
            "JSON",
            "JSONParseResult",
            "JSONRPC",
            "KinematicBody",
            "KinematicBody2D",
            "KinematicCollision",
            "KinematicCollision2D",
            "Label",
            "Label3D",
            "LargeTexture",
            "Light",
            "Light2D",
            "LightOccluder2D",
            "Line2D",
            "LineEdit",
            "LineShape2D",
            "LinkButton",
            "Listener",
            "Listener2D",
            "MainLoop",
            "MarginContainer",
            "Marshalls",
            "Material",
            "MenuButton",
            "Mesh",
            "MeshDataTool",
            "MeshInstance",
            "MeshInstance2D",
            "MeshLibrary",
            "MeshTexture",
            "MethodTweener",
            "MobileVRInterface",
            "MultiMesh",
            "MultiMeshInstance",
            "MultiMeshInstance2D",
            "MultiplayerAPI",
            "MultiplayerPeerGDNative",
            "Mutex",
            "NativeScript",
            "Navigation",
            "Navigation2D",
            "Navigation2DServer",
            "NavigationAgent",
            "NavigationAgent2D",
            "NavigationMesh",
            "NavigationMeshGenerator",
            "NavigationMeshInstance",
            "NavigationObstacle",
            "NavigationObstacle2D",
            "NavigationPolygon",
            "NavigationPolygonInstance",
            "NavigationServer",
            "NetworkedMultiplayerCustom",
            "NetworkedMultiplayerENet",
            "NetworkedMultiplayerPeer",
            "NinePatchRect",
            "Node",
            "Node2D",
            "NodePath",
            "NoiseTexture",
            "Object",
            "Occluder",
            "OccluderPolygon2D",
            "OccluderShape",
            "OccluderShapePolygon",
            "OccluderShapeSphere",
            "OmniLight",
            "OpenSimplexNoise",
            "OptionButton",
            "OS",
            "PackedDataContainer",
            "PackedDataContainerRef",
            "PackedScene",
            "PackedSceneGLTF",
            "PacketPeer",
            "PacketPeerDTLS",
            "PacketPeerGDNative",
            "PacketPeerStream",
            "PacketPeerUDP",
            "Panel",
            "PanelContainer",
            "PanoramaSky",
            "ParallaxBackground",
            "ParallaxLayer",
            "Particles",
            "Particles2D",
            "ParticlesMaterial",
            "Path",
            "Path2D",
            "PathFollow",
            "PathFollow2D",
            "PCKPacker",
            "Performance",
            "PHashTranslation",
            "PhysicalBone",
            "Physics2DDirectBodyState",
            "Physics2DDirectSpaceState",
            "Physics2DServer",
            "Physics2DShapeQueryParameters",
            "Physics2DTestMotionResult",
            "PhysicsBody",
            "PhysicsBody2D",
            "PhysicsDirectBodyState",
            "PhysicsDirectSpaceState",
            "PhysicsMaterial",
            "PhysicsServer",
            "PhysicsShapeQueryParameters",
            "PhysicsTestMotionResult",
            "PinJoint",
            "PinJoint2D",
            "Plane",
            "PlaneMesh",
            "PlaneShape",
            "PluginScript",
            "PointMesh",
            "Polygon2D",
            "PolygonPathFinder",
            "PoolByteArray",
            "PoolColorArray",
            "PoolIntArray",
            "PoolRealArray",
            "PoolStringArray",
            "PoolVector2Array",
            "PoolVector3Array",
            "Popup",
            "PopupDialog",
            "PopupMenu",
            "PopupPanel",
            "Portal",
            "Position2D",
            "Position3D",
            "PrimitiveMesh",
            "PrismMesh",
            "ProceduralSky",
            "ProgressBar",
            "ProjectSettings",
            "PropertyTweener",
            "ProximityGroup",
            "ProxyTexture",
            "QuadMesh",
            "Quat",
            "RandomNumberGenerator",
            "Range",
            "RayCast",
            "RayCast2D",
            "RayShape",
            "RayShape2D",
            "Rect2",
            "RectangleShape2D",
            "Reference",
            "ReferenceRect",
            "ReflectionProbe",
            "RegEx",
            "RegExMatch",
            "RemoteTransform",
            "RemoteTransform2D",
            "Resource",
            "ResourceFormatLoader",
            "ResourceFormatSaver",
            "ResourceImporter",
            "ResourceInteractiveLoader",
            "ResourceLoader",
            "ResourcePreloader",
            "ResourceSaver",
            "RichTextEffect",
            "RichTextLabel",
            "RID",
            "RigidBody",
            "RigidBody2D",
            "Room",
            "RoomGroup",
            "RoomManager",
            "RootMotionView",
            "SceneState",
            "SceneTree",
            "SceneTreeTimer",
            "SceneTreeTween",
            "Script",
            "ScriptCreateDialog",
            "ScriptEditor",
            "ScrollBar",
            "ScrollContainer",
            "SegmentShape2D",
            "Semaphore",
            "Separator",
            "Shader",
            "ShaderMaterial",
            "Shape",
            "Shape2D",
            "ShortCut",
            "Skeleton",
            "Skeleton2D",
            "SkeletonIK",
            "Skin",
            "SkinReference",
            "Sky",
            "Slider",
            "SliderJoint",
            "SoftBody",
            "Spatial",
            "SpatialGizmo",
            "SpatialMaterial",
            "SpatialVelocityTracker",
            "SphereMesh",
            "SphereShape",
            "SpinBox",
            "SplitContainer",
            "SpotLight",
            "SpringArm",
            "Sprite",
            "Sprite3D",
            "SpriteBase3D",
            "SpriteFrames",
            "StaticBody",
            "StaticBody2D",
            "StreamPeer",
            "StreamPeerBuffer",
            "StreamPeerGDNative",
            "StreamPeerSSL",
            "StreamPeerTCP",
            "StreamTexture",
            "String",
            "StyleBox",
            "StyleBoxEmpty",
            "StyleBoxFlat",
            "StyleBoxLine",
            "StyleBoxTexture",
            "SurfaceTool",
            "TabContainer",
            "Tabs",
            "TCP_Server",
            "TextEdit",
            "TextFile",
            "TextMesh",
            "Texture",
            "Texture3D",
            "TextureArray",
            "TextureButton",
            "TextureLayered",
            "TextureProgress",
            "TextureRect",
            "Theme",
            "Thread",
            "TileMap",
            "TileSet",
            "Time",
            "Timer",
            "ToolButton",
            "TouchScreenButton",
            "Transform",
            "Transform2D",
            "Translation",
            "TranslationServer",
            "Tree",
            "TreeItem",
            "TriangleMesh",
            "Tween",
            "Tweener",
            "UDPServer",
            "UndoRedo",
            "UPNP",
            "UPNPDevice",
            "Variant",
            "VBoxContainer",
            "Vector2",
            "Vector3",
            "VehicleBody",
            "VehicleWheel",
            "VFlowContainer",
            "VideoPlayer",
            "VideoStream",
            "VideoStreamGDNative",
            "VideoStreamTheora",
            "VideoStreamWebm",
            "Viewport",
            "ViewportContainer",
            "ViewportTexture",
            "VisibilityEnabler",
            "VisibilityEnabler2D",
            "VisibilityNotifier",
            "VisibilityNotifier2D",
            "VisualInstance",
            "VisualScript",
            "VisualScriptBasicTypeConstant",
            "VisualScriptBuiltinFunc",
            "VisualScriptClassConstant",
            "VisualScriptComment",
            "VisualScriptComposeArray",
            "VisualScriptCondition",
            "VisualScriptConstant",
            "VisualScriptConstructor",
            "VisualScriptCustomNode",
            "VisualScriptDeconstruct",
            "VisualScriptEditor",
            "VisualScriptEmitSignal",
            "VisualScriptEngineSingleton",
            "VisualScriptExpression",
            "VisualScriptFunction",
            "VisualScriptFunctionCall",
            "VisualScriptFunctionState",
            "VisualScriptGlobalConstant",
            "VisualScriptIndexGet",
            "VisualScriptIndexSet",
            "VisualScriptInputAction",
            "VisualScriptIterator",
            "VisualScriptLists",
            "VisualScriptLocalVar",
            "VisualScriptLocalVarSet",
            "VisualScriptMathConstant",
            "VisualScriptNode",
            "VisualScriptOperator",
            "VisualScriptPreload",
            "VisualScriptPropertyGet",
            "VisualScriptPropertySet",
            "VisualScriptResourcePath",
            "VisualScriptReturn",
            "VisualScriptSceneNode",
            "VisualScriptSceneTree",
            "VisualScriptSelect",
            "VisualScriptSelf",
            "VisualScriptSequence",
            "VisualScriptSubCall",
            "VisualScriptSwitch",
            "VisualScriptTypeCast",
            "VisualScriptVariableGet",
            "VisualScriptVariableSet",
            "VisualScriptWhile",
            "VisualScriptYield",
            "VisualScriptYieldSignal",
            "VisualServer",
            "VisualShader",
            "VisualShaderNode",
            "VisualShaderNodeBooleanConstant",
            "VisualShaderNodeBooleanUniform",
            "VisualShaderNodeColorConstant",
            "VisualShaderNodeColorFunc",
            "VisualShaderNodeColorOp",
            "VisualShaderNodeColorUniform",
            "VisualShaderNodeCompare",
            "VisualShaderNodeCubeMap",
            "VisualShaderNodeCubeMapUniform",
            "VisualShaderNodeCustom",
            "VisualShaderNodeDeterminant",
            "VisualShaderNodeDotProduct",
            "VisualShaderNodeExpression",
            "VisualShaderNodeFaceForward",
            "VisualShaderNodeFresnel",
            "VisualShaderNodeGlobalExpression",
            "VisualShaderNodeGroupBase",
            "VisualShaderNodeIf",
            "VisualShaderNodeInput",
            "VisualShaderNodeIs",
            "VisualShaderNodeOuterProduct",
            "VisualShaderNodeOutput",
            "VisualShaderNodeScalarClamp",
            "VisualShaderNodeScalarConstant",
            "VisualShaderNodeScalarDerivativeFunc",
            "VisualShaderNodeScalarFunc",
            "VisualShaderNodeScalarInterp",
            "VisualShaderNodeScalarOp",
            "VisualShaderNodeScalarSmoothStep",
            "VisualShaderNodeScalarSwitch",
            "VisualShaderNodeScalarUniform",
            "VisualShaderNodeSwitch",
            "VisualShaderNodeTexture",
            "VisualShaderNodeTextureUniform",
            "VisualShaderNodeTextureUniformTriplanar",
            "VisualShaderNodeTransformCompose",
            "VisualShaderNodeTransformConstant",
            "VisualShaderNodeTransformDecompose",
            "VisualShaderNodeTransformFunc",
            "VisualShaderNodeTransformMult",
            "VisualShaderNodeTransformUniform",
            "VisualShaderNodeTransformVecMult",
            "VisualShaderNodeUniform",
            "VisualShaderNodeUniformRef",
            "VisualShaderNodeVec3Constant",
            "VisualShaderNodeVec3Uniform",
            "VisualShaderNodeVectorClamp",
            "VisualShaderNodeVectorCompose",
            "VisualShaderNodeVectorDecompose",
            "VisualShaderNodeVectorDerivativeFunc",
            "VisualShaderNodeVectorDistance",
            "VisualShaderNodeVectorFunc",
            "VisualShaderNodeVectorInterp",
            "VisualShaderNodeVectorLen",
            "VisualShaderNodeVectorOp",
            "VisualShaderNodeVectorRefract",
            "VisualShaderNodeVectorScalarMix",
            "VisualShaderNodeVectorScalarSmoothStep",
            "VisualShaderNodeVectorScalarStep",
            "VisualShaderNodeVectorSmoothStep",
            "VScrollBar",
            "VSeparator",
            "VSlider",
            "VSplitContainer",
            "WeakRef",
            "WebRTCDataChannel",
            "WebRTCDataChannelGDNative",
            "WebRTCMultiplayer",
            "WebRTCPeerConnection",
            "WebRTCPeerConnectionGDNative",
            "WebSocketClient",
            "WebSocketMultiplayerPeer",
            "WebSocketPeer",
            "WebSocketServer",
            "WebXRInterface",
            "WindowDialog",
            "World",
            "World2D",
            "WorldEnvironment",
            "X509Certificate",
            "XMLParser",
            "YSort"
        )

    def get_href(self, clazz_name: str):
        return self.urlDict[clazz_name]

    def registerNative(self, *clazzes):
        for clazz_name in clazzes:
            self.urlDict[clazz_name] = "https://docs.godotengine.org/en/" + self.godot_version + "/classes/class_" + clazz_name.lower() + ".html"
    
    def register(self, *clazzes):
        for clazz_path in clazzes:
            self.urlDict[clazz_path.split("/")[-1]] = clazz_path