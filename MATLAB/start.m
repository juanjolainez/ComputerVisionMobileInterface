function [] = start()


% Define frame rate
NumberFrameDisplayPerSecond=10;

% Open figure
hFigure=figure(1);

% Set-up webcam video input

vid = videoinput('winvideo', 1);

% Set parameters for video
% Acquire only one frame each time
set(vid,'FramesPerTrigger',1);
% Go on forever until stopped
set(vid,'TriggerRepeat',Inf);
% Get a grayscale image
set(vid, 'ReturnedColorspace', 'rgb');
triggerconfig(vid, 'Manual');
% set up timer object

counter = 0;
TimerData=timer('TimerFcn', {@FrameRateDisplay,vid, timer},'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop','UserData', counter);
set(timer, 'UserData', counter);

% Start video and timer object
start(vid);
start(TimerData);

% We go on until the figure is closed
uiwait(hFigure);

% Clean up everything
stop(TimerData);
delete(TimerData);
stop(vid);
delete(vid);
% clear persistent variables
clear functions;

% This function is called by the timer to display one frame of the figure
end

function FrameRateDisplay(~, ~,vid, counter)
    trigger(vid);
    
    counter 
    bb = zeros(1,2);
    bc = zeros(1,2);
    
    resta = 0; 
    background = 0;
    IM=getdata(vid,1,'uint8');
    imshow(IM);
      drawnow;
    if (counter <= 10) 
    
         if (counter == 1) 
             
             background = IM;
         else
            resta = IM -background;
            background = IM - resta ;
         end
         ++counter;
    else if (counter ==11)
        r = im2bw(resta, 0.025);
        r2 = Erode(r);
        s = size(data);
        area_filtre = double(int32((s(1,1) * s(1,2))*0.000005));
        se = strel('diamond',area_filtre);
        r3 = Close(r2, se);
        r4 = (imfill(r3,'holes'));
        r5 = Close(r4, se);
        perfil = data;
        prueba(:,:,1) = perfil(:,:,1) .* uint8(r5);
        prueba(:,:,2) = perfil(:,:,2) .* uint8(r5);
        prueba(:,:,3) = perfil(:,:,3) .* uint8(r5);
%         figure; imshow(prueba);
 
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
        %  figure('Name', 'Perfil'); imshow(perfil);
        % 
        %  
 
 
        result2 = SkinSegmentation(prueba);
%         figure('Name','SkinSeg');imshow(result2);
 
 
        %Juntar rallas
        % result3 = closeRallas(result2);
        % figure('Name', 'Rallas suprimidas');imshow(result3);
 
        % [eroded, filtro] = Erode(result2);
        closed = Close(result2, se);
 
        prueba(:,:,1) = perfil(:,:,1) .* uint8(closed);
        prueba(:,:,2) = perfil(:,:,2) .* uint8(closed);
        prueba(:,:,3) = perfil(:,:,3) .* uint8(closed);
%         figure('Name', 'PerfilFiltrePell'); imshow(prueba)
 
        %sacar contornos a prueba
        % contornPerfil = Contorn(prueba);
        % figure('Name', 'Contorn del perfil'); imshow(contornPerfil);    
 
 
        %
 

	  
 
        %Filtro de las 3 mayores áreas.
 
        [L] = bwlabel(closed, 4);
        Lista = regionprops(L,'Area','BoundingBox','Centroid');
        [ordenado,index] = sort([Lista.Area], 'descend');
        s = size(ordenado);
        it = min(3,s(1,2));
        %hold on
        for object = 1:it
%              if (Lista(index(object)).Area > ((320*240)* 0.001 ))
%                 bb = Lista(index(object)).BoundingBox;
%                 rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
%              end
    
        end
        end
        ++counter;
    end
    if (counter >= 11)   
%         rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
%                 plot(bc(1),bc(2), '-m+')
%                 a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
%                 set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        
        
    end
 
 
 
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


   
end

