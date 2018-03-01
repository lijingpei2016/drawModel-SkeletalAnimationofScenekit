//
//  ViewController.m
//  试试骨骼
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

//- (void)dealloc {
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
    
}


#pragma mark ============================== 私有方法 ==============================

- (void)initData {
    
}

- (void)initUI {
    
    self.scnView = [[SCNView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scnView.scene = [SCNScene new];
    self.scnView.allowsCameraControl = YES;
    self.scnView.autoenablesDefaultLighting = YES;
    self.scnView.playing = YES;
    
    self.view = (SCNView *)self.scnView;
    
    self.scnView.backgroundColor = [UIColor blueColor];
    
    //添加相机
    SCNNode * cameraNode = [SCNNode new];
    
    cameraNode.camera = [SCNCamera new];
    
    cameraNode.position = SCNVector3Make(0, 0, 5);
    
    [self.scnView.scene.rootNode addChildNode:cameraNode];
    
    
    SCNNode * node = [self createCustomRigBlock];
    
    node.position = SCNVector3Make(0, 0, -1);
    
    [self.scnView.scene.rootNode addChildNode:node];

}

-(SCNNode *)createCustomRigBlock {
    
    // baseGeometry
    SCNVector3 positions[] = {
        SCNVector3Make(0, 0, 0),
        SCNVector3Make(0, 0, 1),
        SCNVector3Make(1, 0, 1),
        SCNVector3Make(1, 0, 0),
        SCNVector3Make(0, 1, 0),
        SCNVector3Make(0, 1, 1),
        SCNVector3Make(1, 1, 1),
        SCNVector3Make(1, 1, 0),
        SCNVector3Make(0, 2, 0),
        SCNVector3Make(0, 2, 1),
        SCNVector3Make(1, 2, 1),
        SCNVector3Make(1, 2, 0)
    };
    
    SCNGeometrySource * baseGeometrySource = [SCNGeometrySource geometrySourceWithVertices:positions count:12];
    
    typedef struct {
        uint16_t a, b, c;
    } Triangles;
    
    Triangles tVectors[20] = {
        0,1,2,
        0,2,3,
        0,1,5,
        0,4,5,
        4,5,9,
        4,8,9,
        1,2,6,
        1,5,6,
        5,6,10,
        5,9,10,
        2,3,7,
        2,6,7,
        6,7,11,
        6,10,11,
        3,0,4,
        3,4,7,
        7,4,8,
        7,8,11,
        8,9,10,
        8,10,11,
    };
    
    NSData *triangleData = [NSData dataWithBytes:tVectors length:sizeof(tVectors)];
    
    SCNGeometryElement * baseGeometryElement = [SCNGeometryElement geometryElementWithData:triangleData primitiveType:SCNGeometryPrimitiveTypeTriangles primitiveCount:20 bytesPerIndex:sizeof(uint16_t)];
    
    SCNGeometry * baseGeometry = [SCNGeometry geometryWithSources:[NSArray arrayWithObject:baseGeometrySource] elements:[NSArray arrayWithObject:baseGeometryElement]];
    
    baseGeometry.firstMaterial.emission.contents = [UIColor redColor];
    baseGeometry.firstMaterial.doubleSided  = YES;
    baseGeometry.firstMaterial.transparency = 0.6;
    
    SCNNode * mNode = [SCNNode nodeWithGeometry:baseGeometry];
    
    mNode.position = SCNVector3Make(15, 0, 9);
    
    int vectorCount = (int)[(SCNGeometrySource *)[mNode.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex].firstObject vectorCount];
    
    //bones ... the bones of the rig
    NSMutableArray * bonesArray = [NSMutableArray new];
    
    for (int i = 0; i < 3; i++) {
        
        SCNNode * boneNode = [SCNNode new];
        
        boneNode.name = [NSString stringWithFormat:@"bone_%i",i];
        
        if (bonesArray.count > 0) {
            [bonesArray.lastObject addChildNode:boneNode];
        }

        boneNode.position = SCNVector3Make(0, 0.75, 0);
        
        //add a sphere to each bone, to visually check its position etc.
        SCNSphere *boneSphereGeom = [SCNSphere sphereWithRadius:0.1];
        boneSphereGeom.firstMaterial.emission.contents = [UIColor redColor];
        boneNode.geometry = boneSphereGeom;
        
        [bonesArray addObject:boneNode];
        
    }
    
    [mNode addChildNode:bonesArray[0]];
    
    
    //boneInverseBindTransforms  ... this defines the geometries transformation in the default pose!
    //决定骨骼的位置
    NSMutableArray * bibtArray = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        SCNMatrix4 initialPositionMatrix = SCNMatrix4MakeTranslation(0.5, (i*0.5)+0.25, 0.5);
        SCNMatrix4 inverseFinalMatrix = SCNMatrix4Invert(initialPositionMatrix);
        NSValue * bibtValue = [NSValue valueWithSCNMatrix4:inverseFinalMatrix];
        [bibtArray addObject:bibtValue];
    }
    
    //boneWeights ... the weights, at which each vertex is influenced by certain bones (which bones is defined by "boneIndices")
    typedef struct {
        float a, b, c;
    } WeightVectors;
    
    WeightVectors vectors[vectorCount];
    
    for (int i = 0; i < vectorCount; i++) {
        // set the same boneWeights for every vertex
        vectors[i].a = 1;
        vectors[i].b = 0;
        vectors[i].c = 0;
    }
    
    NSData *weightData = [NSData dataWithBytes:vectors length:sizeof(vectors)];
    SCNGeometrySource * boneWeightsGeometrySource = [SCNGeometrySource geometrySourceWithData:weightData
                                                                                     semantic:SCNGeometrySourceSemanticBoneWeights
                                                                                  vectorCount:vectorCount
                                                                              floatComponents:YES
                                                                          componentsPerVector:3
                                                                            bytesPerComponent:sizeof(float)
                                                                                   dataOffset:offsetof(WeightVectors, a)
                                                                                   dataStride:sizeof(WeightVectors)];
    
    //boneIndices
    typedef struct {
        short k, l, m;    // boneWeight
    } IndexVectors;
    
    IndexVectors iVectors[vectorCount];
    for (int i = 0; i < vectorCount; i++) {
        if (i > 7) {
            iVectors[i].k = 1;
            iVectors[i].l = 0;
            iVectors[i].m = 0;
        } else {
            iVectors[i].k = 0;
            iVectors[i].l = 0;
            iVectors[i].m = 0;
        }
    }
    
    NSData *indexData = [NSData dataWithBytes:iVectors length:sizeof(iVectors)];
    SCNGeometrySource * boneIndicesGeometrySource = [SCNGeometrySource geometrySourceWithData:indexData
                                                                                     semantic:SCNGeometrySourceSemanticBoneIndices
                                                                                  vectorCount:vectorCount
                                                                              floatComponents:YES
                                                                          componentsPerVector:3
                                                                            bytesPerComponent:sizeof(short)
                                                                                   dataOffset:offsetof(IndexVectors, k)
                                                                                  dataStride:sizeof(IndexVectors)];
    
    SCNSkinner * mNodeSkinner = [SCNSkinner skinnerWithBaseGeometry:baseGeometry
                                                                    bones:bonesArray
                                                boneInverseBindTransforms:bibtArray
                                                              boneWeights:boneWeightsGeometrySource
                                                              boneIndices:boneIndicesGeometrySource];
    
    mNode.skinner = mNodeSkinner;
    [[bonesArray objectAtIndex:1] runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:0 z:2 duration:2]]];
    
    return mNode;
}


#pragma mark ============================== 代理方法 ==============================

#pragma mark ============================== 事件处理 ==============================


#pragma mark ============================== 访问器方法 ==============================


@end
