//
//  ViewController.m
//  正方体
//
//  Created by LJP on 5/2/18.
//  Copyright © 2018年 poco. All rights reserved.
//

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "ViewController.h"
#import <SceneKit/SceneKit.h>

@interface ViewController ()

@property (nonatomic, strong) SCNView * scnView;

@end

@implementation ViewController

#pragma mark ============================== 生命周期 ==============================

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
}


#pragma mark ============================== 私有方法 ==============================

- (void)initUI {
    
    self.scnView = [[SCNView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scnView.scene = [SCNScene new];
    self.scnView.allowsCameraControl = YES;
    self.scnView.autoenablesDefaultLighting = YES;
    self.scnView.playing = YES;
    
    self.view = (SCNView *)self.scnView;
    
    self.scnView.backgroundColor = [UIColor blackColor];
    
    SCNNode * cameraNode = [SCNNode new];
    
    cameraNode.camera = [SCNCamera new];
    
    cameraNode.position = SCNVector3Make(0, 0, 5);
    
    [self.scnView.scene.rootNode addChildNode:cameraNode];
    
    self.scnView.backgroundColor = [UIColor blueColor];
    
    [self addNode1];
//    [self addNode2];
}


- (void)addNode1 {
    
    typedef struct {
        float x, y, z;    // position
        float nx, ny, nz; // normal
        float s, t;       // texture coordinates
    } MyVertex;
    
    MyVertex vertices[] = {
        // Z轴0.5处的平面
        -0.5,   0.5,  0.5,   0,  0,  1,  0, 0,
        -0.5,  -0.5,  0.5,  0,  0,  1,   0, 1,
        0.5,   -0.5,  0.5,   0,  0,  1,  1, 1,
        0.5,   -0.5,  0.5,   0,  0,  1,  1, 1,
        0.5,    0.5,  0.5,    0,  0,  1, 1, 0,
        -0.5,   0.5,  0.5,  0,  0,  1,   0, 0,
        
        // X轴-0.5处的平面
        -0.5,  0.5,   -0.5, -1,  0,  0, 0, 0,
        -0.5,  -0.5,  -0.5, -1,  0,  0, 0, 1,
        -0.5,  -0.5,    0.5, -1,  0,  0, 1, 1,
        -0.5,  -0.5,   0.5, -1,  0,  0, 1, 1,
        -0.5,  0.5,    0.5, -1,  0,  0, 1, 0,
        -0.5,  0.5,    -0.5, -1,  0,  0, 0, 0,
        
        // Z轴-0.5处的平面
        0.5,   -0.5,  -0.5,  0,  0,  -1, 0, 1,
        -0.5,  -0.5,  -0.5,  0,  0,  -1, 1, 1,
        -0.5,   0.5,  -0.5,   0,  0,  -1, 1, 0,
        -0.5,   0.5,  -0.5,  0,  0,  -1, 1, 0,
        0.5,    0.5,  -0.5,    0,  0,  -1, 0, 0,
        0.5,   -0.5,  -0.5,   0,  0,  -1, 0, 1,
        
        // X轴0.5处的平面
        0.5,  -0.5,    0.5, 1,  0,  0, 0, 1,
        0.5,  -0.5,  -0.5, 1,  0,  0, 1, 1,
        0.5,  0.5,   -0.5, 1,  0,  0, 1, 0,
        0.5,  0.5,    -0.5, 1,  0,  0, 1, 0,
        0.5,  0.5,    0.5, 1,  0,  0, 0, 0,
        0.5,  -0.5,   0.5, 1,  0,  0, 0, 1,
        
        // Y轴0.5处的平面
        0.5, 0.5,  -0.5, 0,  1,  0, 1, 0,
        -0.5, 0.5, -0.5, 0,  1,  0, 0, 0,
        -0.5,  0.5,  0.5, 0,  1,  0, 0, 1,
        -0.5, 0.5,  0.5, 0,  1,  0, 0, 1,
        0.5, 0.5,   0.5, 0,  1,  0, 1, 1,
        0.5,  0.5,  -0.5, 0,  1,  0, 1, 0,
        
        // Y轴-0.5处的平面
        -0.5, -0.5,   0.5, 0,  -1,  0, 0, 0,
        -0.5, -0.5, -0.5, 0,  -1,  0, 0, 1,
        0.5, -0.5,  -0.5, 0,  -1,  0, 1, 1,
        0.5, -0.5,  -0.5, 0,  -1,  0, 1, 1,
        0.5, -0.5,   0.5, 0,  -1,  0, 1, 0,
        -0.5, -0.5,  0.5, 0,  -1,  0, 0, 0,
    };
   
    
    NSData *data = [NSData dataWithBytes:vertices length:sizeof(vertices)];
    
    SCNGeometrySource *vertexSource, *normalSource, *tcoordSource;
    
    vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                    semantic:SCNGeometrySourceSemanticVertex
                                                 vectorCount:6
                                             floatComponents:YES
                                         componentsPerVector:3 // x, y, z
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:offsetof(MyVertex, x)
                                                  dataStride:sizeof(MyVertex)];
    
    normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                    semantic:SCNGeometrySourceSemanticNormal
                                                 vectorCount:6
                                             floatComponents:YES
                                         componentsPerVector:3 // nx, ny, nz
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:offsetof(MyVertex, nx)
                                                  dataStride:sizeof(MyVertex)];
    
    tcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                    semantic:SCNGeometrySourceSemanticTexcoord
                                                 vectorCount:6
                                             floatComponents:YES
                                         componentsPerVector:2 // s, t
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:offsetof(MyVertex, s)
                                                  dataStride:sizeof(MyVertex)];
    
    
    int indices[] = {
        0,1,2,3,4,5,
        6,7,8,9,10,11,
        12,13,14,15,16,17,
        18,19,20,21,22,23,
        24,25,26,27,28,29,
        30,31,32,33,34,35
    };
    
    
    NSMutableArray * elements = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<36; i+=6) {
        
        int indiceChild[] = {indices[i],indices[i+1],indices[i+2], indices[i+3],indices[i+4],indices[i+5]};
        
        NSData * indexData = [NSData dataWithBytes:indiceChild length:sizeof(indiceChild)];
        
        SCNGeometryElement * element = [SCNGeometryElement geometryElementWithData:indexData
                                                                     primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                    primitiveCount:2
                                                                     bytesPerIndex:sizeof(int)];
        [elements addObject:element];
        
    }
    
    
    
    SCNGeometry * geometry = [SCNGeometry geometryWithSources:@[vertexSource,normalSource,tcoordSource]
                                                     elements:elements];
    
    
    UIImage * image  = [UIImage imageNamed:@"xy.jpg"];
    SCNMaterial * material = [[SCNMaterial alloc]init];
    material.diffuse.contents = image;
    
    geometry.materials = @[material];
    
    SCNNode * node = [SCNNode nodeWithGeometry:geometry];
    
    node.position = SCNVector3Make(0, 0, -1);
    
    
//    //加粒子系统
//    SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"ran.scnp" inDirectory:nil];
//    [node addParticleSystem:particleSystem];
    
    [self.scnView.scene.rootNode addChildNode:node];
    
}


- (void)addNode2 {
    
    SCNVector3 positions[] = {
        SCNVector3Make(-1,1,0),
        SCNVector3Make(-1,-1,0),
        SCNVector3Make(1,-1,0),
        SCNVector3Make(1,1,0),
        
        SCNVector3Make(1,1,-2),
        SCNVector3Make(1,-1,-2),
        SCNVector3Make(-1,-1,-2),
        SCNVector3Make(-1,1,-2)
    };
    
    
    int indices[] = {
        0, 1, 2,
        2, 3, 0,
        
        2, 3, 4,
        4, 5, 2,
        
        4, 5, 6,
        6, 7, 4,
        
        6, 7, 0,
        0, 1, 6,
        
        7,0,3,
        3,4,7,
 
        6,1,2,
        2,5,6,
        
    };
    
    
    CGPoint textures[]  = {
        CGPointMake(0, 0),
        CGPointMake(1, 0),
        CGPointMake(1, 1),
        CGPointMake(0, 1),
        
        CGPointMake(0, 0),
        CGPointMake(1, 0),
        CGPointMake(1, 1),
        CGPointMake(0, 1)
    };

    
    SCNGeometrySource * vertexSource  = [SCNGeometrySource geometrySourceWithVertices:positions count:8];
    
    SCNGeometrySource * textureSource = [SCNGeometrySource geometrySourceWithTextureCoordinates:textures count:24];

  
    NSMutableArray * elements = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<36; i+=6) {
        
        int indiceChild[] = {indices[i],indices[i+1],indices[i+2], indices[i+3],indices[i+4],indices[i+5]};
        
        NSData * indexData = [NSData dataWithBytes:indiceChild length:sizeof(indiceChild)];
        
        SCNGeometryElement * element = [SCNGeometryElement geometryElementWithData:indexData
                                                                     primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                    primitiveCount:2
                                                                     bytesPerIndex:sizeof(int)];
        [elements addObject:element];
        
    }
    
    
    SCNGeometry * geometry = [SCNGeometry geometryWithSources:@[vertexSource,textureSource]
                                                     elements:elements];
    
    
    UIImage * image  = [UIImage imageNamed:@"xy.jpg"];
    SCNMaterial * material = [[SCNMaterial alloc]init];
    material.diffuse.contents = image;

    
    geometry.firstMaterial = material;
    geometry.firstMaterial.doubleSided = YES;

    
    SCNNode * node = [SCNNode nodeWithGeometry:geometry];
    
    node.position = SCNVector3Make(0, 0, -1);
    
    [self.scnView.scene.rootNode addChildNode:node];
    
    
}



@end
