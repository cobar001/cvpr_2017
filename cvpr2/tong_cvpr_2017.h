#ifndef TONG_CVPR_2017_H_
#define TONG_CVPR_2017_H_

#include <vector>
#include <string>

class Tong_CVPR_2017 {
    
public:
    Tong_CVPR_2017();
    
    Tong_CVPR_2017(const std::string &path);
    
    ~Tong_CVPR_2017();
    
    bool constructMap(unsigned char* img1,
                      unsigned char* img2,
                      double time1,
                      double time2,
                      std::vector<double> g1,
                      std::vector<double> g2,
                      int imgHeight,
                      int imgWidth);
    
    // returns pose values in the format:
    // [R11,R12,R13,R21,R22,R23,R31,R32,R33,TX,TY,TZ]
    std::vector<double> computePose(unsigned char* frame,
                                    int imgHeight,
                                    int imgWidth);
    
    std::vector<double> computePoseFromQR(unsigned char* frame,
                                          int imgHeight,
                                          int imgWidth);
    
    bool isEngineInitialized();
    
    int getLandmarkCount();
    
    std::vector<double> getPlaneCenterPoint();
    
    double getPlaneHeightDist();
    
    bool _isMapConstructed;
    
    std::string _pathToDocs = "";
};

#endif //TONG_CVPR_2017_H_
