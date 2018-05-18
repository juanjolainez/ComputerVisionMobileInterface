vid = videoinput('winvideo', '1', 'YUY2_160x120');
 set(vid,'ReturnedColorSpace','rgb');
 set(vid,'TriggerRepeat',Inf);
 vid.FrameGrabInterval = 5;
 start(vid);
%------

figure;
while(vid.FramesAcquired<=1000) % Stop after 1000 frames 
     data = getdata(vid,2); 
%     diff_im = imabsdiff(data(:,:,:,1),data(:,:,:,2)); %background subtraction
% diff = rgb2gray(diff_im);
% diff_bw = im2bw(diff,0.2);
% bw2 = imfill(diff_bw,'holes');
% s = regionprops(diff_im, 'centroid');
% cd = s.Centroid;
% centroids = cat(1, s.Centroid);
imshow(data(:,:,:,2));
% hold(imgca,'on');
% plot(imgca,centroids(:,1),centroids(:,2),'g*');
% 
% hold on;
% rectangle('Position',[cd(:,1) cd(:,2) 20 20],'LineWidth',2,'EdgeColor','b');
% hold(imgca,'off');

end

stop(vid)
