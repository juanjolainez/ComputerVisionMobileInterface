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
set(vid, 'ReturnedColorspace', 'rgb');
set(vid,'TriggerRepeat',Inf);
vid.FrameGrabInterval = 5;
imaqmotion(vid);
%framegrabinterval significa que tomara cada 5 frame del stream de video adquirida
%con start(vid) se activa la adquisicion, pero todavia se toma la primera foto
%start(vid);
pause(1);
cont = 1;

tinicio=0;
object = 1;

tcicle = 0.2;
% while(true) 
%     
%     if(toc < 0.2) pause(0.2 - tcicle); end
%     tic
%     trigger(vid);
%     wait(vid,10);
%     data = getdata(vid);
%     data = data(:,:,:,2);
%     if (cont <= 10)
%         
%         font{cont} = data;
%         cont = cont + 1
%     end
%     if (cont == 10)  %Analisis
%         background = font{1};
%         j = uint8(2);
%         suma = font{1};
%         for i=2:numImatges
%             suma = (suma + font{i})/2;
%             resta = imabsdiff (font{j}, background);
%             background = imabsdiff(font{j}, resta) ;
%             j = uint8(mod((j +3),10));
%             if (j == 0) j = 3; end
%             imshow(suma);
%         end
%         r = im2bw(resta, 0.025);
%         r2 = Erode(r);
%         s = size(data);
%         area_filtre = double(int32((s(1,1) * s(1,2))*0.000005));
%         se = strel('diamond',area_filtre);
%         r3 = Close(r2, se);
%         r4 = (imfill(r3,'holes'));
%         r5 = Close(r4, se);
%         perfil = data;
%         prueba(:,:,1) = perfil(:,:,1) .* uint8(r5);
%         prueba(:,:,2) = perfil(:,:,2) .* uint8(r5);
%         prueba(:,:,3) = perfil(:,:,3) .* uint8(r5);
%         figure; imshow(prueba);
% 
%         %Extraccio perfil
% 
%         %  numPerfil = DefinirPerfil(resta);
% 
%          % reconstrucció de imatge en color
%          %perfil = zeros (sizeY, sizeX,3);
%         %  im = font{numImatges};
%         %  
%         %  %
%         % %  perfil = ReconstruccioPerfil(im, numPerfil);
%         %  
%         %  
%         %  
%         %  figure('Name', 'Perfil'); imshow(perfil);
%         % 
%         %  
% 
% 
%         result2 = SkinSegmentation(prueba);
%         figure('Name','SkinSeg');imshow(result2);
% 
% 
%         %Juntar rallas
%         % result3 = closeRallas(result2);
%         % figure('Name', 'Rallas suprimidas');imshow(result3);
% 
%         % [eroded, filtro] = Erode(result2);
%         closed = Close(result2, se);
% 
%         prueba(:,:,1) = perfil(:,:,1) .* uint8(closed);
%         prueba(:,:,2) = perfil(:,:,2) .* uint8(closed);
%         prueba(:,:,3) = perfil(:,:,3) .* uint8(closed);
%         figure('Name', 'PerfilFiltrePell'); imshow(prueba)
% 
%         %sacar contornos a prueba
%         % contornPerfil = Contorn(prueba);
%         % figure('Name', 'Contorn del perfil'); imshow(contornPerfil);    
% 
% 
%         %
% 
% 
%         %Filtro de las 3 mayores áreas.
% 
%         [L,numInicial] = bwlabel(closed, 4);
%         Lista = regionprops(L,'Area','BoundingBox','Centroid');
%         Areas = [Lista.Area];
%         [ordenado,index] = sort([Lista.Area], 'descend');
%         s = size(ordenado);
%         it = min(3,s(1,2));
%         hold on
%         for object = 1:it
%              if (Lista(index(object)).Area > ((320*240)* 0.001 ))
%                 bb = Lista(index(object)).BoundingBox;
%                 bc = Lista(index(object)).Centroid;
%                 rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
%                 plot(bc(1),bc(2), '-m+')
%                 a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
%                 set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
%              end
%         end
%         hold off
%     elseif (cont > 10) 
%         for object = 1:it
%              if (Lista(index(object)).Area > ((320*240)* 0.001 ))
%                 bb = Lista(index(object)).BoundingBox;
%                 bc = Lista(index(object)).Centroid;
%                 rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
%                 plot(bc(1),bc(2), '-m+')
%                 a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
%                 set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
%              end
%         end
%     end
%     imshow(data);
%     tcicle = toc
%         

% end




%FLUSHDATA remueve la imagen del motor de adquisicion y la almacena en el buffer
