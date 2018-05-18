#include <utils/BoundingBox.h>


BoundingBox BoundingBox::getBB() {
	return (*this);
}



int BoundingBox::getXMin() {
	return xmin;
}

int BoundingBox::getXMax() {
	return xmax;
}
int BoundingBox::getYMin() {
	return ymin;
}
int BoundingBox::getYMax() {
	return ymax;
}

void BoundingBox::setBB(int xmin, int ymin, int xmax, int ymax) {
	this->xmax = xmax;
	this->xmin = xmin;
	this->ymax = ymax;
	this->ymin = ymin;
}

int BoundingBox::getHeight() {
	return (this->xmax - this->xmin);
}

int BoundingBox::getWidth() {
	return (this->ymax - this->ymin);
}
