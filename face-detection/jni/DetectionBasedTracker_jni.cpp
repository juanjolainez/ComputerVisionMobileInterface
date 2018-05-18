#include <DetectionBasedTracker_jni.h>
#include <opencv2/core/core.hpp>
#include <opencv2/contrib/detection_based_tracker.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <cvBlob/cvblob.h>
#include <utils/BoundingBox.h>
#include <algorithm>

#include<iostream>

#include <string>
#include <vector>
#include <typeinfo>

#include <android/log.h>

#define LOG_TAG "FaceDetection/DetectionBasedTracker"
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define INTENSITY_THRESHOLD 35
#define BACKGROUND_SUBSTRACTION_THRESHOLD 60
#define MIN_SKIN 1.1
#define MAX_SKIN 3

#define THRESHOLD_OPEN 75
#define OPEN 0
#define CLOSE 1



using namespace std;
using namespace cv;
using namespace cvb;

inline void vector_Rect_to_Mat(vector<Rect>& v_rect, Mat& mat)
{
    mat = Mat(v_rect, true);
}


JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeInitializeFramework (JNIEnv * jenv, jclass) {

	double trans = PI/180;
	for(int i = 0; i < 360; ++i) {
		cosinus[i] = cos(double(i*trans));
		sinus[i] = sin(double(i*trans));
	}
	derecha = BoundingBox();
	izquierda = BoundingBox();

}



JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeGetBackground(JNIEnv * env, jclass clase,  jobject thisobject, jlong result){
    // Find the required classes


	LOGD("Dentro");
	if(thisobject == NULL) {
		LOGD("Es nulo");
	}
    jclass thisclass = env->GetObjectClass(thisobject);
    jclass matclass = env->FindClass("org/opencv/core/Mat");


    LOGD("thisClass is type: %s", typeid(thisclass).name());
    LOGD("Env pasado");
    // Get methods and fields


    jmethodID getPtrMethod = env->GetMethodID(matclass, "getNativeObjAddr", "()J");
    jfieldID bufimgsfieldid = env->GetFieldID(thisclass, "bufImgs", "[Lorg/opencv/core/Mat;");

    LOGD("Methods pasados");
    LOGD("BufimsfieldID: %i", bufimgsfieldid);
    LOGD("getPtrMethod: %i", getPtrMethod);
    LOGD("typeid: %s", typeid(getPtrMethod).name());
    // Let's start: Get the fields
    jobjectArray bufimgsArray = (jobjectArray)env->GetObjectField(thisobject, bufimgsfieldid);
    // Convert the array
    Mat* nativeBufImgs = new Mat[10];

    for (int i = 0; i < 10; i++) {
        nativeBufImgs[i] = *(Mat*)env->CallLongMethod(env->GetObjectArrayElement(bufimgsArray, i), getPtrMethod);
    }
    // We're done! Call the method and return!
    Mat *rgba  = (Mat*)result;

    getDifBackground(nativeBufImgs, rgba);

    Mat girada;
    flip((*rgba), (*rgba), 1);
    result = jlong(rgba);
}

CvBlobs getHandsByRelativePosition(CvBlobs& blobs) {
	CvLabel label=0;
	unsigned int maxArea=0;
	unsigned int otherAreas= 0;
	bool first = true;
	CvBlobs provisional;

	for(int i = 0; i < 3 && i < blobs.size(); ++i) {
		if (first) { //get the max Area
			first = false;
			for (CvBlobs::const_iterator it=blobs.begin();it!=blobs.end();++it)
			{
			  CvBlob *blob=(*it).second;

			  if (blob->area > maxArea)
			  {
				label=blob->label;
				maxArea=blob->area;
			  }
			}
			provisional[0]  = blobs[label];
		}
		else {
			for (CvBlobs::const_iterator it=blobs.begin();it!=blobs.end();++it)
			{
			  CvBlob *blob=(*it).second;

			  if (blob->area > otherAreas and blob->area < maxArea)
			  {
				label=blob->label;
				otherAreas=blob->area;
			  }
			}
			maxArea = otherAreas;
			provisional[i] = blobs[label];
		}
	}

	CvBlobs definitivo;
	int tamano = provisional.size();
	if(tamano == 1) {
		definitivo[0] = provisional[0];
	}
	else if (tamano == 2) {
		definitivo[0] = provisional[0];
		definitivo[1] = provisional[1];
	}
	else {
		int maxX = maximo(provisional[0]->minx, maximo(provisional[1]->minx, provisional[2]->minx));
		int minX = minimo(provisional[0]->minx, minimo(provisional[1]->minx, provisional[2]->minx));
		if(provisional[0]->minx != maxX && provisional[0]->minx != minX ) {
			definitivo[0] = provisional[1];
			definitivo[1] = provisional[2];
		}
		else if(provisional[1]->minx != maxX && provisional[1]->minx != minX ) {
			definitivo[0] = provisional[0];
			definitivo[1] = provisional[2];
		}
		else {
			definitivo[0] = provisional[0];
			definitivo[1] = provisional[1];
		}
	}

	return definitivo;

}

JNIEXPORT void JNICALL getDifBackground(Mat* vectorMatrices, Mat* image) {

	for(int i = 0; i < 10; i++) {
		vectorMatrices[i].convertTo(vectorMatrices[i],CV_16UC4);
	}

	Mat background = vectorMatrices[0];
	Mat mitjana = Mat::zeros(background.rows, background.cols, CV_16UC4);
	Mat resta = Mat::zeros(background.rows, background.cols, CV_16UC4);
	Mat matfiltro = Mat::zeros(background.rows, background.cols, CV_8UC1);

	int j = 7;
	for(int i = 0; i < 10; i++) {
		mitjana = mitjana + vectorMatrices[j];
		resta = vectorMatrices[j] - resta;
		background = vectorMatrices[j] - resta;
		j= (j+3)%10;
	}
	mitjana = mitjana /10;
	mitjana.convertTo(mitjana, CV_8UC4);
	resta.convertTo(resta, CV_8UC4);
	IplImage *imagen = cvCreateImage(cvSize(resta.cols, resta.rows), IPL_DEPTH_8U, 1);
	intensityFilter(&resta, &matfiltro, INTENSITY_THRESHOLD);


	customErode(&matfiltro);


	customDilate(&matfiltro);
	customFillHoles(&matfiltro);
	CvBlobs blobs;
	IplImage *labelImg=cvCreateImage(cvSize(matfiltro.cols, matfiltro.rows), IPL_DEPTH_LABEL, 1);
	IplImage segmentated = matfiltro;

	int result = cvLabel(&segmentated, labelImg, blobs);

	IplImage *img = cvCreateImage(cvSize(matfiltro.cols, matfiltro.rows), IPL_DEPTH_8U, 3);


	int dims = img->height*img->width;
	cvFilterByArea(blobs,dims*0.001,dims*0.80);
	cvRenderBlobs(labelImg, blobs, img, img );
	Mat matImg = img;
	Mat skinFiltered = Mat::zeros(background.rows, background.cols, CV_16UC4);
	separaBackground(&mitjana, &matImg, &skinFiltered);
	fondo = mitjana.clone();


	CvBlobs manos = getHandsByRelativePosition(blobs);
	double proporcio = 1200;

	for(int i = 0; i < manos.size(); ++i) {
		CvBlob *b = manos[i];

		int xmin, xmax, ymin, ymax = 0;
		xmin = maximo(0, b->minx - dims/proporcio);
		ymin = maximo(0, b->miny - dims/proporcio);
		xmax = minimo(img->width -1, b->maxx + dims/proporcio);
		ymax = minimo(img->height -1, b->maxy + dims/proporcio);
		if(i == 1) derecha.setBB(xmin, ymin, xmax, ymax);
		else izquierda.setBB(xmin, ymin, xmax, ymax);


	}


	(*image) = (mitjana);

	LOGD("El numero de pixel labelled es %i ", result);

	LOGD("Imagen mide %i x %i con %i dimensiones", image->rows, image->cols, image->dims);
}

void separaBackground(Mat* background, Mat* labels, Mat* skin) {
	int channels = (*background).channels();

	int nRows = (*background).rows;
	int nCols = (*background).cols;

	int i,j,n;
	uchar* p;
	uchar* original;
	double ratio = 0;

	for( i = 0; i < nRows; ++i) {
		p = (*labels).ptr<uchar>(i);
		original = (*background).ptr<uchar>(i);
		n = 0;
		for ( j = 0; j < nCols*channels; j +=4) {
			if(p[n] > 0 || p[n+1] > 0 || p[n+2] > 0) {


				ratio = double(double(original[j]) / double(original[j+1]));
				if(ratio > MIN_SKIN and ratio < MAX_SKIN) {

					original[j] = 0;
					original[j+1] = 0;
					original[j+2] = 0;
				}

			}
			n += 3;
		}
	}
}

void segmentation(Mat* imgRestada, Mat* destino, Mat* normal, int threshold) {
	int channels = (*imgRestada).channels();

	int nRows = (*imgRestada).rows;
	int nCols = (*imgRestada).cols;

	int i,j,n;
	uchar* p;
	uchar* final;
	uchar* color;
	double ratio = 0;

	for( i = 0; i < nRows; ++i) {
		p = (*imgRestada).ptr<uchar>(i);
		final = (*destino).ptr<uchar>(i);
		color = (*normal).ptr<uchar>(i);
		n = 0;
		for ( j = 0; j < nCols*channels; j +=channels) {
			if(p[j] + p[j+1] + p[j+2] > threshold) {
				if(color[j+1] > 0) {

					ratio = ((color[j]) / double(color[j+1]));
					if(ratio > MIN_SKIN and ratio < MAX_SKIN) {
						final[n] = 255;
					}
				}

			}
			++n;
		}
	}
}


int maximo( int a,  int b) {
	return (a<b)?b:a;
}

int minimo( int a,  int b) {
	return (a>b)?b:a;
}

void analizeBlob(CvBlob* blob) {
	double m11 = blob->u11;
	double m20 = blob->u20;
	double m02 = blob->u02;
	double resta = m20 - m02;
	double angulo;
	if(resta == 0) {
		if(m11 == 0) angulo = 0;
		else if(m11 > 0) angulo = 45;
		else if(m11 < 0) angulo = -45;
	}
	else if(m11 == 0) {
		if(resta > 0) angulo = 0;
		else angulo = -90;
	}
	else {
		if(resta > 0) angulo = cvAngle(blob)*(180/PI) +90;
		else angulo = cvAngle(blob)*(180/PI) -90;
	}

}

void intensityFilter(Mat* rgba, Mat* bn, int thresh) {
	double maximo;
	int channels = (*rgba).channels();

	int nRows = (*rgba).rows;
	int nCols = (*rgba).cols;

	int i,j;
	uchar* p;
	uchar* original;

	for( i = 0; i < nRows; ++i)
	{
		p = (*bn).ptr<uchar>(i);
		original = (*rgba).ptr<uchar>(i);
		for ( j = 0; j < nCols*channels; j +=4)
		{

			if(original[j] + original[j+1] + original[j+2] > thresh) {
				//p[n] = 0x01;    //B
				(*p) = 0x01;


			}
			else {
				//p[n] = 0x00;    //B
				(*p) = 0x00;
			}

			//++n;
			++p;
		}


	}



}

void customDilate(Mat* bn) {
	Mat dilated = bn->clone();

	int erosion_size = (bn->rows * bn->cols) / 20000;
	cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
		                      cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
		                      cv::Point(erosion_size, erosion_size) );

	cv::dilate((*bn), (*bn), element);
}

void customErode(Mat* bn) {
	Mat dilated = bn->clone();

	int erosion_size = (bn->rows * bn->cols) / 150000;
	cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
		                      cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
		                      cv::Point(erosion_size, erosion_size) );

	cv::erode((*bn), (*bn), element);
}

void customFillHoles(Mat* bn) {
	cv::Mat holes= 1 - (*bn).clone();
	cv::floodFill(holes,cv::Point2i(0,0),cv::Scalar(1));
	(*bn) = 1-holes;
}


void  nativeSkinFilter (Mat* rgb, Mat* bn) {

	int channels = (*rgb).channels();

	int nRows = (*rgb).rows;
	int nCols = (*rgb).cols;

	int i,j;
	uchar* p;
	uchar* original;
	for( i = 0; i < nRows; ++i)
	{
		p = (*bn).ptr<uchar>(i);
		original = (*rgb).ptr<uchar>(i);
		for ( j = 0; j < nCols*channels; j +=3)
		{
			if(original[j+1] > 0) {
				double ratio = original[j] /original[j+1];
				if(ratio > MIN_SKIN and ratio < MAX_SKIN) {
					p[j] = 255;    //B
					p[j+1] = 255;  //G
					p[j+2] = 255;  //R
				}
				else {
					p[j] = 0;    //B
					p[j+1] = 0;  //G
					p[j+2] = 0;  //R
				}
			}
			else {
				p[j] = 0;    //B
				p[j+1] = 0;  //G
				p[j+2] = 0;  //R
			}
		}
	}
}

void girarMano(CvBlob* blob, CvLabel objeto, Mat* input,  Mat* matImg, String& posicion, Point& centroid, int& angle, Point& arriba, Point& izquierda, Point& derecha) {
	int max = maximo(input->rows, input->cols);

	double m11 = blob->u11;
	double m20 = blob->u20;
	double m02 = blob->u02;
	double resta = m20 - m02;
	int angulo;

	angulo = cvAngle(blob)*(180/PI);

	if (angulo < 0) angulo = (180-angulo)% 360;
	else {
		angulo = (-angulo) % 360;
		if (angulo < 0) {
			while(angulo < 0) angulo += 360;
		}
	}

	bool dentro = 0;
	CvContourChainCode contour;

	CvContourPolygon *poligon =  cvConvertChainCodesToPolygon(&(*blob).contour);

	vector<vector<int> > histograma(max+max+max+max, vector<int>(2, -1));


	vector<Point> perfilGirado;

	int miny, xMinY, minx;
	bool giro = false;
	double ratio = ((double)(blob->maxx - blob->minx)) / (blob->maxy - blob->miny);

	if (!((angulo > 245 && angulo < 295) || (ratio < 1.3 && ratio > 0.75 && (blob->area >= (0.65*(blob->maxy-blob->miny)*(blob->maxx - blob->minx)))))) {

		angulo = (angulo - 270 + 360)%360;
		giro = true;
		cv::Mat M(2, 3, CV_32FC1);
		cv::Point2f center((float)blob->centroid.x, blob->centroid.y);
		M = cv::getRotationMatrix2D(center, angulo*PI/180, 1.0);
		miny = ((*poligon)[0].x-blob->centroid.x)*sinus[angulo] + ((*poligon)[0].y-blob->centroid.y)*cosinus[angulo]+blob->centroid.y +max;
		xMinY = minx = ((*poligon)[1].x-blob->centroid.x)*cosinus[angulo] - ((*poligon)[1].y-blob->centroid.y)*sinus[angulo]+ blob->centroid.x+max;
		int x, y;
		for(int i = 1; i < poligon->size(); i++) {
			CvPoint p = (*poligon)[i];


			x = (p.x-blob->centroid.x)*cosinus[angulo] - (p.y-blob->centroid.y)*sinus[angulo];
			y = (p.x-blob->centroid.x)*sinus[angulo] + (p.y-blob->centroid.y)*cosinus[angulo];

			x += blob->centroid.x +max;
			y += blob->centroid.y + max;

			Point nuevo(x,y);
			perfilGirado.push_back(nuevo);
			if(y > histograma.size() || y < 0) LOGD("Acabo de pringar con y = %i", y);
			if (histograma[y][0] == -1) {
				histograma[y][0] = x;
				histograma[y][1] = x;
			}
			else {
				if(x < histograma[y][0]) histograma[y][0] = x;
				else if(x > histograma[y][1]) histograma[y][1] = x;
			}
			if(y < miny) {
				xMinY = x;
				miny = y;
			}

		}
	}
	else { //Practicamente vertical y no hace falta girar
		miny = (*poligon)[1].y;
		xMinY = minx = (*poligon)[1].x;
		for(int i = 1; i < poligon->size(); i++) {
			CvPoint p = (*poligon)[i];
			perfilGirado.push_back(p);
			if(p.y > histograma.size()) LOGD("Acabo de pringar con p.y = %i", p.y);
			if (histograma[p.y][0] == -1) {
				histograma[p.y][0] = p.x;
				histograma[p.y][1] = p.x;
			}
			else {
				if(p.x < histograma[p.y][0]) histograma[p.y][0] = p.x;
				else if(p.x > histograma[p.y][1]) histograma[p.y][1] = p.x;
			}
			if(p.y < miny) {
				xMinY = p.x;
				miny = p.y;
			}
		}
	}

	int ancho;
	double maxAncho = histograma[miny][1] - histograma[miny][0];
	int coordenadaAncho = miny;
	for(int i = miny; i < histograma.size(); ++i) {
		if(histograma[i][0] != -1) {
				if(histograma[i][0] < minx) minx = histograma[i][0];
				ancho = histograma[i][1] - histograma[i][0];

				if(ancho > maxAncho || histograma[coordenadaAncho][0] == -1) {
					maxAncho = ancho;
					coordenadaAncho = i;

				}
		}
	}


	double alpha, beta;
    if(giro) {
    	angulo = -angulo+ 360;

    	double x = maxAncho/2;
    	double y = coordenadaAncho;

    	y = y - blob->centroid.y - max;


    	alpha = atan2(xMinY -  histograma[coordenadaAncho][0], coordenadaAncho)* (180/PI);
    	beta = atan2(histograma[coordenadaAncho][1] - xMinY, coordenadaAncho)*(180/PI);

    	arriba.x = (xMinY-blob->centroid.x - max) *cosinus[angulo] - (miny-blob->centroid.y-max)*sinus[angulo];
    	arriba.y = (xMinY-blob->centroid.x - max) *sinus[angulo] + (miny-blob->centroid.y-max)*cosinus[angulo];

    	izquierda.x = (histograma[coordenadaAncho][0]-blob->centroid.x -max)*cosinus[angulo] - y*sinus[angulo];
		izquierda.y = (histograma[coordenadaAncho][0]-blob->centroid.x -max)*sinus[angulo] + y*cosinus[angulo];
		centroid.x = ((histograma[coordenadaAncho][0]-blob->centroid.x -max) + maxAncho/2)*cosinus[angulo] - y*sinus[angulo];
		centroid.y = ((histograma[coordenadaAncho][0]-blob->centroid.x -max) + maxAncho/2)*sinus[angulo] + y*cosinus[angulo];
		derecha.x = (((histograma[coordenadaAncho][0]-blob->centroid.x -max) + maxAncho))*cosinus[angulo] - y*sinus[angulo];
		derecha.y = (((histograma[coordenadaAncho][0]-blob->centroid.x -max) + maxAncho))*sinus[angulo] + y*cosinus[angulo];




		centroid.x += blob->centroid.x;
		centroid.y += blob->centroid.y;
		arriba.x += blob->centroid.x;
		arriba.y += blob->centroid.y;
		izquierda.x += blob->centroid.x;
		izquierda.y += blob->centroid.y;
		derecha.x += blob->centroid.x;
		derecha.y += blob->centroid.y;
    }
    else {
    	centroid.x = (histograma[coordenadaAncho][1] + histograma[coordenadaAncho][0]) / 2 ;
    	centroid.y =  coordenadaAncho - miny;
    	arriba.x = xMinY;
		arriba.y = miny;
		izquierda.x = histograma[coordenadaAncho][0];
		izquierda.y = coordenadaAncho - miny;
		derecha.x = histograma[coordenadaAncho][1];
		derecha.y = coordenadaAncho - miny;
		alpha = atan2(arriba.x - izquierda.x, izquierda.y - arriba.y)* (180/PI);
		beta = atan2(derecha.x - arriba.x, derecha.y - arriba.y)*(180/PI);
    }


    double alto = coordenadaAncho - miny;


	int anguloMano = abs(alpha) + abs(beta);

	angle = anguloMano;
	if(anguloMano <= THRESHOLD_OPEN) {
		posicion = "abierta";
	}
	else {
		posicion = "cerrada";
	}



}

void  backSubstraction (Mat* input, Mat* background, Mat* resultado, int thresh) {

	int channels = (*input).channels();

	int nRows = (*input).rows;
	int nCols = (*input).cols;

	int i,j;
	uchar* original;
	uchar* back;
	uchar* res;
	int n;

	for( i = 0; i < nRows; ++i)
	{
		original = (*input).ptr<uchar>(i);
		back = (*background).ptr<uchar>(i);
		res = (*resultado).ptr<uchar>(i);
		n = 0;
		for ( j = 0; j < nCols*channels; j +=channels)
		{
				int suma = 0;
				suma += abs(original[j] - back[j]);
				suma += abs(original[j+1] - back[j+1]);
				suma += abs(original[j+2] - back[j+2]);

				if (suma < thresh) {
					res[n] = 0;

				}
				else {

					if(original[j+1] > 0) {
						double ratio = original[j] /original[j+1];
						if(ratio < MIN_SKIN*0.85 or ratio > MAX_SKIN*1.3 or original[j+2] > original[j]*0.9) {
							res[n] = 0;


						}
					}

				}
			//}
				++n;
		}
	}
}

void blobAnalysis(Mat* input, BoundingBox& bounding, Mat& output, String& posicion, Point& centroid, int& angulo, Point& arriba, Point& izquierda, Point& derecha) {
	Rect roi = Rect(bounding.getXMin(), bounding.getYMin(), bounding.getHeight(), bounding.getWidth());
	Mat roiImg((*input), roi);
	Mat roiFondo(fondo, roi);
	Mat filtrada = Mat::ones(roiFondo.rows, roiFondo.cols, CV_8UC1)*255;
	backSubstraction (&roiImg, &roiFondo, &filtrada, BACKGROUND_SUBSTRACTION_THRESHOLD);

	IplImage *labelImg=cvCreateImage(cvSize(roiFondo.cols, roiFondo.rows), IPL_DEPTH_LABEL, 1);
	IplImage segmentated = filtrada;


	CvBlobs blobs;
	int result = cvLabel(&segmentated, labelImg, blobs);

	IplImage *img = cvCreateImage(cvSize((output).cols, (output).rows), IPL_DEPTH_8U, 3);

	int dims = img->height*img->width;


	if (blobs.size() > 0) {

		CvLabel largest = cvLargestBlob(blobs);

		CvBlobs manos;
		manos[largest] = blobs[largest];

		Mat matImg = img;

		Mat labelled = labelImg;


		CvBlob *blob = blobs[largest];

		int max = maximo(fondo.rows, fondo.cols);
		girarMano(blobs[largest], largest, &labelled, &matImg, posicion, centroid, angulo, arriba, izquierda, derecha);
		centroid.x = centroid.x + bounding.getXMin();
		centroid.y = centroid.y + bounding.getYMin();
		arriba.x = arriba.x + bounding.getXMin();
		arriba.y = arriba.y + bounding.getYMin();
		izquierda.x = izquierda.x + bounding.getXMin();
		izquierda.y = izquierda.y + bounding.getYMin();
		derecha.x = derecha.x + bounding.getXMin();
		derecha.y = derecha.y + bounding.getYMin();

		int xMinSeg = maximo(0, (bounding.getXMin() + blob->minx)*0.8);
		int xMaxSeg = minimo(matImg.cols-1, bounding.getXMin() + blob->maxx +  matImg.cols*0.08);
		int yMinSeg = maximo(0, (bounding.getYMin()+blob->miny)*0.8);
		int yMaxSeg = minimo(matImg.rows-1, bounding.getYMin()+ blob->maxy + matImg.rows*0.08);
		bounding.setBB(xMinSeg, yMinSeg, xMaxSeg, yMaxSeg);
		(output) = (*input);
	}
	else {
		LOGD("No se ha detectado ningœn objeto");
	}
	cvReleaseImage(&img);
	cvReleaseImage(&labelImg);
	LOGD("El angulo en blobAnalysis es %i", angulo);




}


void drawTriangle(Mat* output, Point& izquierda, Point& derecha, Point& arriba) {
	line((*output), izquierda, derecha, cvScalar(255,0,0), 3);
	line((*output), izquierda, arriba, cvScalar(255,0,0), 3);
	line((*output), derecha, arriba, cvScalar(255,0,0), 3);
}



JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeProcessFrame(JNIEnv * env, jclass clase,jobject izq, jobject der, jlong inputImage, jlong outputImage) {
	Mat *input = (Mat*) inputImage;
	Mat *output = (Mat*) outputImage;


	String posicion1, posicion2;
	Point centroid1, centroid2;
	int angulo1, angulo2 = 0;
	Point arriba1, izquierda1, derecha1, arriba2, izquierda2, derecha2;
	blobAnalysis(input, izquierda, (*output), posicion1, centroid1, angulo1, arriba1, izquierda1, derecha1);
	blobAnalysis(input, derecha, (*output), posicion2, centroid2, angulo2, arriba2, izquierda2, derecha2);


	IplImage img = (*input);

	cvRectangle(&img, cvPoint(derecha.getXMin(), derecha.getYMin()), cvPoint(derecha.getXMax(), derecha.getYMax()),CV_RGB(0,255,0),5,8);
	cvRectangle(&img, cvPoint(izquierda.getXMin(), izquierda.getYMin()), cvPoint(izquierda.getXMax(), izquierda.getYMax()),CV_RGB(0,255,0),5,8);

	jclass handClass = env->FindClass("org/opencv/samples/facedetect/Hand");
	jmethodID setGesture = env->GetMethodID(handClass, "setGesture", "(I)V");


	CvScalar color;
	CvScalar colorIzquierda;
	CvScalar colorDerecha;
	if(posicion1 == "abierta") {
		int gesto = 0; //abierta por defecto
		for (int i = 0; i < anteriorIzquierda.size(); ++i) {
			if(anteriorIzquierda[i] == 1) { //Mano cerrada
				gesto = 1;
				anteriorIzquierda[i] = 0;
			}
		}
		if(gesto == 0)  env->CallVoidMethod(izq, setGesture, 0);
		colorIzquierda = CV_RGB(0,255,0);

	}
	else {
		int gesto = 1; //cerrada por defecto
		for (int i = 0; i < anteriorIzquierda.size(); ++i) {
			if(anteriorIzquierda[i] == 0) { //Mano cerrada
				gesto = 0;
				anteriorIzquierda[i] = 1;
			}
		}
		if(gesto == 1)  env->CallVoidMethod(izq, setGesture, 1);
		colorIzquierda = CV_RGB(0,255,255);
	}

	cvRectangle(&img, cvPoint(izquierda.getXMin(), izquierda.getYMin()), cvPoint(izquierda.getXMax(), izquierda.getYMax()),color,5,8);



	if(posicion2 == "abierta") {

		int gesto = 0; //abierta por defecto
		for (int i = 0; i < anteriorDerecha.size(); ++i) {
			if(anteriorDerecha[i] == 1) { //Mano cerrada
				gesto = 1;
				anteriorDerecha[i] = 0;
			}
		}
		if(gesto == 0)  env->CallVoidMethod(der, setGesture, 0);
		colorDerecha = CV_RGB(0,255,0);
	}
	else {
		int gesto = 1; //cerrada por defecto
		for (int i = 0; i < anteriorDerecha.size(); ++i) {
			if(anteriorDerecha[i] == 0) { //Mano cerrada
				gesto = 0;
				anteriorDerecha[i] = 1;
			}
		}
		if(gesto == 1)  env->CallVoidMethod(der, setGesture, 1);
		colorDerecha = CV_RGB(0,255,255);
	}

	//(*output) = &img;
	(*output) = (&img);
	putText((*output), "X",  centroid1,FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(255,255,255), 1, CV_AA);
	putText((*output), "X",  centroid2,FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(255,255,255), 1, CV_AA);


	double alpha = 0.6;

	if(centroIzquierda->x == -1) {
		centroIzquierda->x = centroid1.x;
		centroIzquierda->y = centroid1.y;
		centroDerecha->x = centroid2.x;
		centroDerecha->y = centroid2.y;
	}
	else {
		centroIzquierda->x = centroIzquierda->x*alpha  + centroid1.x*(1-alpha);
		centroIzquierda->y = centroIzquierda->y*alpha  + centroid1.y*(1-alpha);
		centroDerecha->x = centroDerecha->x*alpha  + centroid2.x*(1-alpha);
		centroDerecha->y = centroDerecha->y*alpha  + centroid2.y*(1-alpha);
	}


	drawTriangle((output), izquierda1, derecha1, arriba1);
	drawTriangle((output),izquierda2, derecha2, arriba2);

	circle((*output), centroid1, 30, colorIzquierda, -1);
	circle((*output), centroid2, 30, colorDerecha, -1);

	flip((*output), (*output), 1);


	jmethodID setCenter = env->GetMethodID(handClass, "setCenter", "(II)V");
	env->CallVoidMethod(izq, setCenter, output->cols - centroIzquierda->x, centroIzquierda->y);
	env->CallVoidMethod(der, setCenter, output->cols - centroDerecha->x, centroDerecha->y);
}





bool insideBlock(int i, int j, Rect rect) {
	if(i < rect.x) return false;
	if(i > rect.x + rect.width) return false;
	if(j < rect.y) return false;
	if(j > rect.y + rect.height) return false;
	return true;
}

JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeWait(JNIEnv * env, jclass, jlong mat) {
	Mat *imagen = (Mat*) mat;
	flip((*imagen), (*imagen), 1);
	cv::putText(*(imagen), "Take the standard position",  cvPoint(50,240),FONT_HERSHEY_COMPLEX_SMALL, 2, cvScalar(0,255,0), 3, CV_AA);
}

JNIEXPORT void JNICALL Java_org_opencv_samples_facedetect_DetectionBasedTracker_nativeWaitAndCheck(JNIEnv * env, jclass, jlong mat) {
	Mat *imagen = (Mat*) mat;
	flip((*imagen), (*imagen), 1);
	cv::putText(*(imagen), "Checking images...",  cvPoint(50,240),FONT_HERSHEY_COMPLEX_SMALL, 2, cvScalar(0,255,0), 3, CV_AA);
}
