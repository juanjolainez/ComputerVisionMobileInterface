%Captura de video con camara web
disp('Captura de Video');
disp('1: Capturar');
disp('2: salir');
opcion = input('Ingrese Opción: ');

switch opcion
    case 1
proye_new = 'shot3.avi'; %nombre del video
aviobj = avifile(proye_new); %creando archivos de video .avi
aviobj.Quality = 100;
aviobj.Colormap = gray (256);
camara_web = videoinput('winvideo',1,'YUY2_640x480')%dispositivo y resolucion
camara_web.LoggingMode = 'disk&memory';
camara_web.DiskLogger = aviobj;
camara_web.TriggerRepeat = 300      %tamaño de frame
preview(camara_web)
start(camara_web)                   %inicio de captura de video
[data time] = getdata(camara_web,400);  
elapsed_time = time(400) - time(1);
camara_web.DiskLoggerFrameCount;
aviobj = close (camara_web.DiskLogger);
closepreview(camara_web)            %cerrar la caputra
delete(camara_web);
clear camara_web;
    case 2
           close all;
otherwise, disp('Operación No Valida');
end
