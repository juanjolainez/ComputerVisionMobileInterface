function [prueba] = analysis(imatges)
   
    
%     if (mod(dataPassing.counter, 3) == 0 && dataPassing.counter <= 50) 
%      if (dataPassing.counter <= 15) 
%         trigger(vid);    
% %         bb = zeros(1,2);
% %         bc = zeros(1,2);  
% %         counter = dataPassing.counter;
%         dataPassing.counter
%         IM=getdata(vid,1,'uint8');
%         pause(0.1);
%         dataPassing.imatges{uint8(((dataPassing.counter)/3)+1)} = IM; 
%         dataPassing.counter = dataPassing.counter +1  
%         imshow(IM);
%         drawnow;
%     elseif (dataPassing.counter ==16)
%         IM=getdata(vid,1,'uint8');
        background = imatges(1);
        j = uint8(7)
        suma = imatges(1);
        for i=2:10
            suma = (suma + imatges(j))/2;
             resta = imatges(j) -background;
             background = imatges(j) - resta ;
             j = uint8(mod((j +4),15));
             bucle = 1
            if (j == 0) j = 3; end
        end
        
        r = im2bw(resta, 0.05);
        r2 = Erode(r);
        s = size(imatges(1));
        area_filtre = double(int32((s(1,1) * s(1,2))*0.000005));
        se = strel('diamond',area_filtre);
        r3 = Close(r2, se);
        r4 = (imfill(r3,'holes'));
        r5 = Close(r4, se);
        perfil = imatges(10);
        prueba(:,:,1) = perfil(:,:,1) .* uint8(r5);
        prueba(:,:,2) = perfil(:,:,2) .* uint8(r5);
        prueba(:,:,3) = perfil(:,:,3) .* uint8(r5);
         figure; imshow(prueba);
 
        %Extraccio perfil
 
        %  numPerfil = DefinirPerfil(resta);
 
         % reconstrucció de imatge en color
         %perfil = zeros (sizeY, sizeX,3);
        %  im = font{numImatges};
        %  
        %  %
        % %  perfil = ReconstruccioPerfil(im, numPerfil);
        %  
        %  
        %  
       %   figure('Name', 'Perfil'); imshow(perfil);
        % 
        %  
 
 
        result2 = SkinSegmentation(prueba);
       %  figure('Name','SkinSeg');imshow(result2);
 
 
        %Juntar rallas
        % result3 = closeRallas(result2);
        % figure('Name', 'Rallas suprimidas');imshow(result3);
 
        % [eroded, filtro] = Erode(result2);
        closed = Close(result2, se);
 
        prueba(:,:,1) = perfil(:,:,1) .* uint8(closed);
        prueba(:,:,2) = perfil(:,:,2) .* uint8(closed);
        prueba(:,:,3) = perfil(:,:,3) .* uint8(closed);
        figure('Name', 'PerfilFiltrePell'); imshow(prueba);
 
        %sacar contornos a prueba
        % contornPerfil = Contorn(prueba);
        % figure('Name', 'Contorn del perfil'); imshow(contornPerfil);    
 
 
        %
 

	  
 
        %Filtro de las 3 mayores áreas.
 
        [L] = bwlabel(closed, 4);
        Lista = regionprops(L,'Area','BoundingBox','Centroid');
        [ordenado] = sort([Lista.Area], 'descend');
        s = size(ordenado);
        it = min(3,s(1,2));
        %hold on
        for object = 1:it
             if (Lista(index(object)).Area > ((320*240)* 0.001 ))
                bb = Lista(index(object)).BoundingBox;
                rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
             end
    
        end
%         dataPassing.counter = dataPassing.counter +1  
%         imshow(IM);
%         drawnow;
%     elseif (dataPassing.counter > 16)
%         IM=getdata(vid,1,'uint8');
%         olaquease = 2
%         imshow(IM);
%         drawnow;
%     end
    
%             IM=getdata(vid,1,'uint8');
% 
%     dataPassing.counter = dataPassing.counter +1  
%         imshow(IM);
%         drawnow;
    
%     dataPassing.counter = dataPassing.counter +1  
%     if (counter >= 11)   
% %         rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
% %                 plot(bc(1),bc(2), '-m+')
% %                 a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
% %                 set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
% %         imshow(IM);
% %         drawnow;
%         
%     end
 
 
 
   % hold off
 
        
     
    
    
 
 
% persistent IM;
% persistent handlesRaw;
% persistent handlesPlot;
% trigger(vid);
% IM=getdata(vid,1,'uint8');
% 
% if isempty(handlesRaw)
%   % if first execution, we create the figure objects
%     subplot(2,1,1);
%     handlesRaw=imagesc(IM);
%    title('CurrentImage');
%  
%     % Plot first value
%   Values=mean(IM(:));
%   subplot(2,1,2);
%   handlesPlot=plot(Values);
%   title('Average of Frame');
%     xlabel('Frame number');
%   ylabel('Average value (au)');
% else
%   % We only update what is needed
%   set(handlesRaw,'CData',IM);
%   Value=mean(IM(:));
%   OldValues=get(handlesPlot,'YData');
%   set(handlesPlot,'YData',[OldValues Value]);

salgo = 1


end
