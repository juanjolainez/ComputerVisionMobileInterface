   clear;
   imaqreset                           
   canalVideo=videoinput('winvideo');%  // esto crea el canal de video a la camara web
   % preview(canalVideo); % // abrimos una ventana de preview para ver a donde apuntamos con la camara
    start(canalVideo);% // inicializamos el canal de Video
    %while (true) 
    pause(3);
    
    imgAdq=getsnapshot(canalVideo);% // tomamos una instantanea con la camara que se guarda en imgAdq
    imshow(imgAdq); %//  se muestra la imagen
    
%     imgAdq2= getdata(canalVideo,10);
%     figure;
%     imshow(imgAdq);
    
%end
closepreview(canalVideo);% // cerramos la ventana de preview
    delete(canalVideo);