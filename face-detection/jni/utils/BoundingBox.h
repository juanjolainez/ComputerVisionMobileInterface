#ifndef BOUNDINGBOX_H
#define BOUNDINGBOX_H

class BoundingBox {
	int xmin;
	int ymin;
	int xmax;
	int ymax;

	public:
		BoundingBox getBB();
		void setBB(int xmin, int ymin, int xmax, int ymax);
		int getXMin();
		int getXMax();
		int getYMin();
		int getYMax();
		int getHeight();
		int getWidth();


};

#endif
