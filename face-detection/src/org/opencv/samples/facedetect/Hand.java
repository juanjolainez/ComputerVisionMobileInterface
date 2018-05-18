package org.opencv.samples.facedetect;

import org.opencv.core.Mat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfRect;
import org.opencv.core.Point;

public class Hand
{
	private int gesture;
	private Point center = new Point();
	
	
	public int getGesture() {
		return gesture;
	}
	
	public void setGesture(int newGesture) {
		this.gesture = newGesture;
	}
	
	public Point getCenter() {
		return this.center;
	}
	
	public void setCenter(int x, int y) {
		center.x = x;
		center.y = y;
	}
    


}
