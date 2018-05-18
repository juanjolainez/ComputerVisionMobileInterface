package org.opencv.samples.facedetect;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.CameraBridgeViewBase.CvCameraViewFrame;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfRect;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.android.CameraBridgeViewBase;
import org.opencv.android.CameraBridgeViewBase.CvCameraViewListener2;
import org.opencv.objdetect.CascadeClassifier;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

public class FdActivity extends Activity implements CvCameraViewListener2 {

    private static final String    TAG                 = "OCVSample::Activity";
    



    private DetectionBasedTracker  mNativeDetector;

  
    
    private Mat 				   rgb;
    private Mat[] 				   matVector = new Mat[10];
    private int 				   frameCounter 	   = 0;
    private int 				   DETECTION_RADIUS = 30;
    private int 				   offsetX;
    private int 				   offsetY;
    private double 				   ratioX;
    private double 				   ratioY;
    private HandClickRunnable      handClickHandler;
    
    
    
    private CameraBridgeViewBase   mOpenCvCameraView;
    
    
    class HandClickRunnable implements Runnable
    {
    	private Hand hand;
    	private int radius;
    
    	public HandClickRunnable(Hand h, int r) {
    		setHand(h);
    		setRadius(r);
    	}
    	
    	public void setData(Hand h, int r) {
    		setHand(h);
    	    setRadius(r);
    	}

    	public void run() {
    		checkPressedHand(getHand(), getRadius());
    	}

		public Hand getHand() {
			return hand;
		}

		public void setHand(Hand hand) {
			this.hand = hand;
		}

		public int getRadius() {
			return radius;
		}

		public void setRadius(int radius) {
			this.radius = radius;
		}
    }

    private BaseLoaderCallback  mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS:
                {
                    Log.i(TAG, "OpenCV loaded successfully");

                    // Load native library after(!) OpenCV initialization
                    System.loadLibrary("detection_based_tracker");

                    mNativeDetector = new DetectionBasedTracker();
                    mNativeDetector.initializeFramework();


                    mOpenCvCameraView.enableView();
                } break;
                default:
                {
                    super.onManagerConnected(status);
                } break;
            }
        }
    };

    public FdActivity() {
       
    }

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "called onCreate");
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
        
        //Iniciar previsualizaci—n de la c‡mara

        setContentView(R.layout.face_detect_surface_view);
        
        mOpenCvCameraView = (CameraBridgeViewBase) findViewById(R.id.fd_activity_surface_view);
        mOpenCvCameraView.enableFpsMeter();
        mOpenCvCameraView.setCvCameraViewListener(this);
        
        
        //Inicializar botones y el layout
        
        View relativeLayoutControls = (View) findViewById(R.id.controls_layout);
        relativeLayoutControls.bringToFront();
        inicializarBotones();
       
    }
    
    private void inicializarBoton(int ruta) {
    	final Button b = (Button) findViewById(ruta);
        b.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.e("Juanjo", "Boton presionado");
				b.setVisibility(View.INVISIBLE);
			}	
        });
        b.bringToFront();
       
    }
    
    private void getCoordenadasBoton(int ruta) {
    	 Button b = (Button) findViewById(ruta);
    	 int[] location = new int[2];
         b.getLocationOnScreen(location);
         mOpenCvCameraView.getLocationInWindow(location);
    }
    
    private void getCoordenadas() {
    	getCoordenadasBoton(R.id.home_btn_announcements);
    	getCoordenadasBoton(R.id.home_btn_map);
    	getCoordenadasBoton(R.id.home_btn_schedule);
    	getCoordenadasBoton(R.id.home_btn_starred);
    	getCoordenadasBoton(R.id.home_btn_vendors);
    	getCoordenadasBoton(R.id.home_btn_sessions);
    }
    
    private void inicializarBotones() {
    	inicializarBoton(R.id.home_btn_announcements);
    	inicializarBoton(R.id.home_btn_map);
    	inicializarBoton(R.id.home_btn_schedule);
    	inicializarBoton(R.id.home_btn_starred);
    	inicializarBoton(R.id.home_btn_vendors);
    	inicializarBoton(R.id.home_btn_sessions);
	}

    @Override
    public void onPause()
    {
        super.onPause();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.disableView();
    }

    @Override
    public void onResume()
    {
        super.onResume();
        OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_2_4_3, this, mLoaderCallback);
    }
    
    @Override
    public void onRestart()
    {
        super.onRestart();
        frameCounter = 0;
    }

    public void onDestroy() {
        super.onDestroy();
    }

    public void onCameraViewStarted(int width, int height) {
        rgb = new Mat();
    }

    public void onCameraViewStopped() {
    	rgb.release();
    }
    
    private void checkPressedButton(Hand hand, int radius, int ruta) {
    	Button b = (Button) findViewById(ruta);
    	int[] location = new int[2];
        b.getLocationOnScreen(location);
        System.out.println("La mano tiene coordenadas (" + hand.getCenter().x + ","+ hand.getCenter().y);
        System.out.println("El boton tiene bounding (" + location[0] + ","+ location[0]	);
        if(hand.getCenter().x >= location[0] - radius && hand.getCenter().x <= location[0] + radius + b.getWidth() &&
           hand.getCenter().y >= location[1] - radius && hand.getCenter().y <= location[1] + radius + b.getHeight()) {
        	b.callOnClick();
        }
	}
    
    private void checkPressedHand(Hand hand, int radius) {
    	System.out.println("La mano esta " + hand.getGesture());
    	if(hand.getGesture() == 1) { //means closed
    		System.out.println("ENTRO EN EL IF DE APRETADA!!");
    		checkPressedButton(hand, radius, R.id.home_btn_announcements);
    		checkPressedButton(hand, radius, R.id.home_btn_map);
    		checkPressedButton(hand, radius, R.id.home_btn_schedule);
    		checkPressedButton(hand, radius, R.id.home_btn_starred);
    		checkPressedButton(hand, radius, R.id.home_btn_vendors);
    		checkPressedButton(hand, radius, R.id.home_btn_sessions);
    	}
    	
    }
    
   

	private void checkPressed(Hand left, Hand right, int radius) {
		System.out.println("He entrado en checkpressed");
		
    	checkPressedHand(left, radius);
    	checkPressedHand(right, radius);
    }

    public Mat onCameraFrame(CvCameraViewFrame inputFrame) {
    	
    	int nFramesEspera = 50;
        rgb = inputFrame.rgba();
        
        if(frameCounter == 0) {
        	///////Calcular variables per a la transformaci— pixelsImatge -> pixelsPantalla
        	View cameraView = (View) findViewById(R.id.fd_activity_surface_view);
            int[] location = new int[2];
            cameraView.getLocationInWindow(location);
            System.out.println("El camera view da " + cameraView.getHeight() + "," + cameraView.getWidth());
            DisplayMetrics displayMetrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            
            offsetY = displayMetrics.heightPixels - cameraView.getMeasuredHeight();
            offsetX = displayMetrics.widthPixels - cameraView.getMeasuredWidth();
            ratioX = (double)displayMetrics.heightPixels/rgb.height();
            ratioY = (double)displayMetrics.widthPixels/rgb.width();
        }
 
        frameCounter++;
        if (frameCounter < nFramesEspera) {
        	Mat imagen = mNativeDetector.waitingTime(rgb);
        	return imagen;
        }
        else if(frameCounter <= nFramesEspera + 30) {
        	if((frameCounter%3) == 0) {
        		matVector[((frameCounter-nFramesEspera)/3)] = rgb.clone();
        	}
        	mNativeDetector.checkingImages(rgb);
        	return rgb;
        	
        }
        else if(frameCounter == nFramesEspera + 30 +1){
        	Mat fondo = mNativeDetector.getBackground(matVector);
        	return fondo;
        }
        else {
        	Mat imagen = mNativeDetector.process(rgb, offsetX, offsetY, ratioX, ratioY);
        	Hand leftHand = mNativeDetector.getLeftHand();
        	Hand rightHand = mNativeDetector.getRightHand();
        	
        	
        	runOnUiThread(new HandClickRunnable(leftHand, DETECTION_RADIUS) {  
                @Override
                public void run() {
                	checkPressedHand(getHand(), getRadius());
                }
            });
        	runOnUiThread(new HandClickRunnable(rightHand, DETECTION_RADIUS) {  
                @Override
                public void run() {
                	
                	checkPressedHand(getHand(), getRadius());
                }
            });
        	return imagen;
        }
    }
    

   

   
}
