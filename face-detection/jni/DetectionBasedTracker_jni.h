#include <jni.h>
#include <opencv2/core/core.hpp>
#include "cvBlob/cvblob.h"
#include "utils/BoundingBox.h"
#include <vector>

using namespace std;

/* Header for class org_opencv_samples_fd_DetectionBasedTracker */

#ifndef _Included_org_opencv_samples_fd_DetectionBasedTracker
#define _Included_org_opencv_samples_fd_DetectionBasedTracker
#ifdef __cplusplus
extern "C" {
#endif

double sinus[360];
double cosinus[360];
const double PI = 3.1415926;
cv::Mat fondo;
BoundingBox derecha;
BoundingBox izquierda;
vector<int> anteriorIzquierda(2,0);
vector<int> anteriorDerecha(2,0);
cv::Point* centroIzquierda = new cv::Point(-1,-1);
cv::Point* centroDerecha = new cv::Point(-1,-1);





/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    nativeCreateObject
 * Signature: (Ljava/lang/String;F)J
 */
JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeInitializeFramework
  (JNIEnv *, jclass);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    nativeGetBackground
 * Signature: (JJJ)V
 */
JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeGetBackground(JNIEnv *, jclass, jobject, jlong);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    getDifBackground
 * Signature: (JJJ)V
 */
JNIEXPORT void JNICALL getDifBackground(cv::Mat* vectorMatrices, cv::Mat* image);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:   nativeWait
 * Signature: (JJJ)V
 */
JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeWait(JNIEnv *, jclass, jlong);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:   nativeWait
 * Signature: (JJJ)V
 */
JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeWaitAndCheck(JNIEnv *, jclass, jlong);



/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    nativeProcessFrame
 * Signature: (JJJ)V
 */
JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeProcessFrame(JNIEnv *, jclass, jobject, jobject, jlong, jlong);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    intensityFilter
 * Signature: (JJJ)V
 */

void intensityFilter(cv::Mat* rgba, cv::Mat* bn,  int thresh);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    customDilate
 * Signature: (JJJ)V
 */

void customDilate(cv::Mat* bn);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    analizeBlob
 * Signature: (JJJ)V
 */

void analizeBlob(cvb::CvBlob* blob);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    customErode
 * Signature: (JJJ)V
 */
void customErode(cv::Mat* bn);



/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    customErode
 * Signature: (JJJ)V
 */
bool insideBlock(int i, int j, cv::Rect rect);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    separaBackground
 * Signature: (JJJ)V
 */
void separaBackground(cv::Mat* background, cv::Mat* labels, cv::Mat* skinFiltered);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    customFillHoles
 * Signature: (JJJ)V
 */

void customFillHoles(cv::Mat* bn);

/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    maximo
 * Signature: (JJJ)V
 */

int maximo( int a,  int b);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    minimo
 * Signature: (JJJ)V
 */
int minimo( int a,  int b);


/*
 * Class:     org_opencv_samples_fd_DetectionBasedTracker
 * Method:    nativeDetect
 * Signature: (JJJ)V
 */
void  nativeSkinFilter (cv::Mat* rgb, cv::Mat* bn);

#ifdef __cplusplus
}
#endif
#endif
