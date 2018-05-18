close all;clear all;clc;

sizeX = 640;
sizeY = 480;
% primero se captura un stream de video usando videoinput, con argumento
%de winvideo, numero de dispositivo y formato de la camara, si no sabes usa la
%funcion imaqtool para averiguarlo es YUY o RGB
tamany = ['YUY2_' int2str(sizeX) 'x' int2str(sizeY) ''];
vid=videoinput('winvideo',1,tamany);
% vid=videoinput('winvideo',1,'YUY2_640x480');
%640x480 160x120
% Se configura las opciones de adquision de video
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb');
vid.FrameGrabInterval = 5;
%framegrabinterval significa que tomara cada 5 frame del stream de video adquirida
%con start(vid) se activa la adquisicion, pero todavia se toma la primera foto
start(vid);
pause(1);
% creamos un bucle que puede ser while always o while true en este caso
%y como mi compu es una netbook trucha(trucha=cagada=lenta=barata)
%hago que despues de 100 frames adquiridos se salga del bucle para evitar colgadas
%while(vid.FramesAcquired<=100)

% se toma una snapshot del stream y se la almacena en data para trabajar mas
%facil
%IMAGE RECOGNITION
data = getsnapshot(vid);
figure('Name','Original');
imshow(data);
blackwhite = rgb2gray(data);
edges = edge(blackwhite, 'sobel');
figure('Name', 'Contornos'); imshow(edges);
data2 = getsnapshot(vid);
blackwhite = rgb2gray(data);
edges2 = edge(blackwhite, 'sobel');
pause(0.2);
dif = data - data2;
dif = rgb2gray(dif);
datasub = im2bw(dif, 0.05);

%datasub = edges - edges2;
figure('Name', 'Diferencia'); imshow(datasub);

data3 = getsnapshot(vid);

%tomar numImatges fotos

numImatges = 10;

font = cell(1, numImatges);


for i=1:numImatges
    data = getsnapshot(vid);
    font{i} = data;
end

background = font{1};
j = uint8(2);
suma = font{1};
for i=2:numImatges
    suma = (suma + font{i})/2;
     resta = font{j} -background;
     background = font{j} - resta ;
     j = uint8(mod((j +3),10));
    if (j == 0) j = 3; end
    imshow(suma);
end


figure('Name', 'Resta'); imshow(resta);
 
r = im2bw(resta, 0.0225);
r2 = Erode(r);
s = size(data);
area_filtre = double(int32((s(1,1) * s(1,2))*0.00001));
se = strel('diamond',area_filtre);
r3 = Close(r2, se);
%%Completar bordes (luego se suprimiran)
r3(1,:) = 1; r3(:,1) = 1; r3(s(1,1),:) = 1; r3(:,s(1,2)) = 1; r3(1,1) = 0; r3(1,2) = 0;
r4 = (imfill(r3,'holes'));
r3(1,:) = 0; r3(:,1) = 0; r3(s(1,1),:) = 0; r3(:,s(1,2)) = 0;

%%Quitar los bordes que hemos puesto
r5 = Close(r4, se);
perfil = data;
prueba(:,:,1) = perfil(:,:,1) .* uint8(r5);
prueba(:,:,2) = perfil(:,:,2) .* uint8(r5);
prueba(:,:,3) = perfil(:,:,3) .* uint8(r5);
figure('name','Before Skin Segmentation'); imshow(prueba);


result2 = SkinSegmentation(prueba);

%Tapar les parets
result2(1,:) = 1; result2(:,1) = 1; result2(s(1,1),:) = 1;
result2(:,s(1,2)) = 1; result2(1,1) = 0; result2(1,2) = 0;
result2 = (imfill(result2,'holes'));
%Destapar les parets
result2(1,:) = 0; result2(:,1) = 0;
result2(s(1,1),:) = 0; result2(:,s(1,2)) = 0;

figure('Name','SkinSeg');imshow(result2);


closed = Close(result2, se);

prueba(:,:,1) = perfil(:,:,1) .* uint8(closed);
prueba(:,:,2) = perfil(:,:,2) .* uint8(closed);
prueba(:,:,3) = perfil(:,:,3) .* uint8(closed);
figure('Name', 'PerfilFiltrePell'); imshow(prueba)

%sacar contornos a prueba
% contornPerfil = Contorn(prueba);
% figure('Name', 'Contorn del perfil'); imshow(contornPerfil);    


%


%Filtro de las 3 mayores áreas.

[L,numInicial] = bwlabel(closed, 4);
Lista = regionprops(L,'Area','BoundingBox','Centroid', 'PixelList');
Areas = [Lista.Area];
[ordenado,index] = sort([Lista.Area], 'descend');
s = size(ordenado);
it = min(3,s(1,2));
hold on
for object = 1:it
     if (Lista(index(object)).Area > ((320*240)* 0.001 ))
        bb = Lista(index(object)).BoundingBox;
        bc = Lista(index(object)).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
     end
end

bb1 = uint64(Lista(index(1)).BoundingBox);
bb2 = uint64(Lista(index(2)).BoundingBox);
bb3 = uint64(Lista(index(3)).BoundingBox);

minim = min([bb1(1,1) bb2(1,1) bb3(1,1)]);
maxim = max([bb1(1,1) bb2(1,1) bb3(1,1)]);



total = zeros(size(closed));
% % Al final de este bucle, en total están las 2 manos y en mano1, mano2
% % están las manos en su bounding box, dispuestas a que la muñeca sea 
% % reconocida.
if (bb1(1,1) ~= minim && bb1(1,1) ~= maxim)
    %bb1 esta en el medio, así que no se copia
    total(bb2(1,2):bb2(1,2)+bb2(1,4)-1, bb2(1,1):bb2(1,1) +bb2(1,3)-1) = 1;
    total(bb3(1,2):bb3(1,2)+bb3(1,4)-1, bb3(1,1):bb3(1,1) +bb3(1,3)-1) = 1; 
    total = total .* closed;
    mano1 = total(bb2(1,2):bb2(1,2)+bb2(1,4)-1, bb2(1,1):bb2(1,1) +bb2(1,3)-1);
    mano2 = total(bb3(1,2):bb3(1,2)+bb3(1,4)-1, bb3(1,1):bb3(1,1) +bb3(1,3)-1);
elseif (bb2(1,1) ~= minim && bb2(1,1)~= maxim)
    %bb2 esta en el medio, así que no se copia
    total(bb1(1,2):bb1(1,2)+bb1(1,4)-1, bb1(1,1):bb1(1,1) +bb1(1,3)-1) = 1;
    total(bb3(1,2):bb3(1,2)+bb3(1,4)-1, bb3(1,1):bb3(1,1) +bb3(1,3)-1) = 1;  
    total = total .* closed;
    mano1 = total(bb1(1,2):bb1(1,2)+bb1(1,4)-1, bb1(1,1):bb1(1,1) +bb1(1,3)-1);
    mano2 = total(bb3(1,2):bb3(1,2)+bb3(1,4)-1, bb3(1,1):bb3(1,1) +bb3(1,3)-1);
else
    %bb3 esta en el medio, así que no se copia
    total(bb1(1,2):bb1(1,2)+bb1(1,4)-1, bb1(1,1):bb1(1,1) +bb1(1,3)-1) = 1;
    total(bb2(1,2):bb2(1,2)+bb2(1,4)-1, bb2(1,1):bb2(1,1) +bb2(1,3)-1) = 1;
    total = total .* closed;
    mano1 = total(bb1(1,2):bb1(1,2)+bb1(1,4)-1, bb1(1,1):bb1(1,1) +bb1(1,3)-1);
    mano2 = total(bb2(1,2):bb2(1,2)+bb2(1,4)-1, bb2(1,1):bb2(1,1) +bb2(1,3)-1);
end

figure;imshow(total);

wrist1 = WristDetector(mano1);
wrist2 = WristDetector(mano2);
 

hold off
%end
% aqui terminan los 2 bucles

% detenemos la captura
stop(vid);


%FLUSHDATA remueve la imagen del motor de adquisicion y la almacena en el buffer
flushdata(vid);
