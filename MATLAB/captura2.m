clc,clear all,close all;
imaqreset                           % sirve para resetear la compu y volver a instalar las camaras
                                     % que fueron instalados cuando matlab ya estaba en uso
imaqhwinfo;
adaptador=imaqhwinfo('winvideo')    % informa los tipos de camara que estan instalados
camara=imaqhwinfo('winvideo',1);     % asigna a camara los valores de la camara seleccionada
formats=camara.SupportedFormats;     % muestra los formatos de la camara
Video=videoinput('winvideo',1,'YUY2_352x288'); % toma el video de la camara seleccionada con el formato especificado 'YUY2_352x288'
src = getselectedsource(Video);      % asigna src los parametros del video
     % Los valores que voy a poner a continución son modificaciones a las propiedades de la cámara
get(src);
set(src, 'Saturation',45);          % controla la saturacion de la foto 45,160
set(Video, 'ReturnedColorSpace', 'RGB');

preview(Video);                      % muestra el video preview tomado
start (Video);
pause(1);                            
% pausa el programa (tiempo en segundos)para luego hacer lo que sigue
% he observado que con este tiempo de espera para empezar a tomar las
% fotos la calidad de la imagen es muy buena
%for p=1:2;
   J=getsnapshot(Video);                   % funcion para tomar la foto
   pause(0.5);                             % es el tiempo de espera entre una foto y otra
   imshow(J);
   %K=rgb2gray(J);                          % convierte la imagen a escala de grises
   %umbral=graythresh(K);
   %umbral=0.45;                            %umbral para diferenciar entre el negro y blanco
   %bw=im2bw(K,umbral);                     %convierte la imagen a binario
   %figure(2),subplot(1,2,p),imshow(bw),title(p); %muestra las imagenes en binario
   %imwrite (bw,strcat(num2str(p),'.jpg'));  % nombra las fotos en formato jpg
%end 
stop(Video); %detiene el video
delete(Video); %elemina el video