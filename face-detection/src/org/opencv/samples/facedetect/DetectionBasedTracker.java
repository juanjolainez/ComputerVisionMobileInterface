package org.opencv.samples.facedetect;

import org.opencv.core.Mat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfRect;

import android.graphics.Point;

public class DetectionBasedTracker
{
	private Mat[] bufImgs = new Mat[7];
	private Hand izquierda = new Hand();
	private Hand derecha = new Hand();
	
	public Hand getLeftHand() {
		return izquierda;
	}
	
	public Hand getRightHand() {
		return derecha;
	}
	
   // public DetectionBasedTracker(String cascadeName, int minFaceSize) {
   //     mNativeObj = nativeCreateObject(cascadeName, minFaceSize);
   // }
    
    public void initializeFramework() {
        nativeInitializeFramework();
    }

    public void start() {
        nativeStart(mNativeObj);
    }

    public void stop() {
        nativeStop(mNativeObj);
    }

    public void setMinFaceSize(int size) {
        nativeSetFaceSize(mNativeObj, size);
    }

    public void detect(Mat imageGray, MatOfRect faces) {
        nativeDetect(mNativeObj, imageGray.getNativeObjAddr(), faces.getNativeObjAddr());
    }

    public void release() {
        nativeDestroyObject(mNativeObj);
        mNativeObj = 0;
    }
    
    public Mat getBackground(Mat[] matVector) {
		this.bufImgs = matVector;
		Mat resultado = new MatOfInt();
	
		nativeGetBackground(this, resultado.getNativeObjAddr());
		System.out.println("Hemos salido de nativeGetBackground");
		System.out.println("La matriz resultante tiene " + resultado.height() + " filas y " + resultado.width() + " columnas y " + resultado.size());
		return resultado;
	}
    
  

	public Mat process(Mat rgb, int offsetX, int offsetY, double ratioX, double ratioY) {
		Mat resultado = rgb.clone();
        nativeProcessFrame(izquierda, derecha, rgb.getNativeObjAddr(), resultado.getNativeObjAddr());
        org.opencv.core.Point izqCamera = izquierda.getCenter();
        izquierda.setCenter((int)(izqCamera.x*ratioX - offsetX), (int)(izqCamera.y*ratioY - offsetY));
        org.opencv.core.Point derCamera = derecha.getCenter();
        derecha.setCenter((int)(derCamera.x*ratioX - offsetX), (int)(derCamera.y*ratioY - offsetY));
        return resultado;
    }
    
	public Mat waitingTime(Mat rgb) {
		nativeWait(rgb.getNativeObjAddr());
		return rgb;
	}
	
	public Mat checkingImages(Mat rgb) {
		nativeWaitAndCheck(rgb.getNativeObjAddr());
		return rgb;
	}

    private long mNativeObj = 0;

    private static native long nativeCreateObject(String cascadeName, int minFaceSize);
    private static native void nativeDestroyObject(long thiz);
    private static native void nativeStart(long thiz);
    private static native void nativeStop(long thiz);
    private static native void nativeSetFaceSize(long thiz, int size);
    private static native void nativeDetect(long thiz, long inputImage, long faces);
    private static native void nativeGetBackground(Object o, long resultado);
    private static native void nativeInitializeFramework();
    private static native void nativeProcessFrame(Object izquierda, Object derecha, long inputImage, long outputImage);
    private static native void nativeWait(long inputImage);
    private static native void nativeWaitAndCheck(long inputImage);

	
    


	

}
