function imaqmotion(obj)
%IMAQMOTION Create an image acquisition motion detector.
% 
%    IMAQMOTION(OBJ) creates a live image acquisition motion detection
%    UI by acquiring data from video input object OBJ and displaying any
%    motion in the image stream.
%
%    Note, OBJ is re-configured to continuously acquire data in order to 
%    set it up for detecting motion.
%
%    Example:
%       % Construct a video input object and a motion display.
%       obj = videoinput('winvideo', 1);
%       imaqmotion(obj)
%
%    See also VIDEOINPUT.

%    CP 4-13-04
%    Copyright 2004 The MathWorks, Inc. 

% Unique name for the UI.
appTitle = 'Image Acquisition Motion Detector';

try
    % Make sure we've stopped so we can set up the acquisition.
    stop(obj);
    
    % Configure the video input object to continuously acquire data.
    triggerconfig(obj, 'manual');
    set(obj, 'Tag', appTitle, 'FramesAcquiredFcnCount', 1, ...
        'TimerFcn', @localFrameCallback, 'TimerPeriod', 0.1);
    
    % Check to see if this object already has an associated figure.
    % Otherwise create a new one.
    ud = get(obj, 'UserData');
    if ~isempty(ud) && isstruct(ud) && isfield(ud, 'figureHandles') ...
            && ishandle(ud.figureHandles.hFigure)
        appdata.figureHandles = ud.figureHandles;
        figure(appdata.figureHandles.hFigure)
    else
        appdata.figureHandles = localCreateFigure(obj, appTitle);
    end

    % Store the application data the video input object needs.
    appdata.background = [];
    appdata.deuImatges = zeros(480,640,3,10);
    appdata.deuImatges = uint8(appdata.deuImatges);
    appdata.counter = 0;
    appdata.analizada = 0;
    %obj.UserData = [appdata deuImatges counter];
    obj.UserData = appdata;

    % Start the acquisition.
    start(obj);
    pause(3);

    % Avoid peekdata warnings in case it takes too long to return a frame.
    warning off imaq:peekdata:tooManyFramesRequested
catch
    % Error gracefully.
    error('MATLAB:imaqmotion:error', ...
        sprintf('IMAQMOTION is unable to run properly.\n%s', lasterr))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localFrameCallback(vid, event)
% Executed by the videoinput object callback 
% to update the image display.

% If the object has been deleted on us, 
% or we're no longer running, do nothing.
if ~isvalid(vid) || ~isrunning(vid)
    return;
end

% Access our application data.
appdata = get(vid, 'UserData');
background = appdata.background;

% Peek into the video stream. Since we are only interested
% in processing the current frame, not every single image
% frame provided by the device, we can flush any frames in
% the buffer.
frame = peekdata(vid, 1);
if isempty(frame),
    return;
end
flushdata(vid);

% First time through, a background image will be needed.
if isempty(background),
    background = getsnapshot(vid);
end

%Take 10 images from the 2nd second to the fifth every 0.3 secs
appdata.counter = appdata.counter +1;
if (mod(appdata.counter,3) == 1 && appdata.counter <= 49 && appdata.counter >= 22) 
    appdata.deuImatges(:,:,:,uint8(appdata.counter/3 -6)) = uint8(frame(:,:,:));
    if (appdata.counter == 49) 
        appdata.counter
        appdata.analizada = analisis(appdata.deuImatges); 
    end
    localUpdateFig(vid, appdata.figureHandles, frame, background);
elseif (appdata.counter > 50)
    %appdata.analizada = prueba;
    set(appdata.figureHandles.hImage, 'CData', appdata.analizada);
else
    
   localUpdateFig(vid, appdata.figureHandles, frame, background); 
end



% Update the figure and our application data.
%localUpdateFig(vid, appdata.figureHandles, frame, background);
appdata.background = frame;
set(vid, 'UserData', appdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localUpdateFig(vid, figData, frame, background)
% Update the figure display with the latest data.

% If the figure has been destroyed on us, stop the acquisition.
if ~ishandle(figData.hFigure),
    stop(vid);
    return;
end

% Plot the results.
I = imabsdiff(frame, background);
set(figData.hImage, 'CData', I);

% Update the patch to the new level value.
graylevel = graythresh(I);
level = max(0, floor(100*graylevel));
xpatch = [0 level level 0];
set(figData.hPatch, 'XData', xpatch)
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteFig(fig, event)

% Reset peekdata warnings.
warning on imaq:peekdata:tooManyFramesRequested

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figData = localCreateFigure(vid, figTitle)
% Creates and initializes the figure.

% Create the figure and axes to plot into.
fig = figure('NumberTitle', 'off', 'MenuBar', 'none', ...
    'Name', figTitle, 'DeleteFcn', @localDeleteFig);

% Create a spot for the image object display.
nbands = get(vid, 'NumberOfBands');
res = get(vid, 'ROIPosition');
himage = imagesc(rand(res(4), res(3), nbands));

% Clean up the axes.
ax = get(himage, 'Parent');
set(ax, 'XTick', [], 'XTickLabel', [], 'YTick', [], 'YTickLabel', []);

% Create the motion detection bar before hiding the figure.
[hPatch, hLine] = localCreateBar(ax);
set(fig, 'HandleVisibility', 'off');

% Store the figure data.
figData.hFigure = fig;
figData.hImage = himage;
figData.hPatch = hPatch;
figData.hLine = hLine;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hPatch, hLine] = localCreateBar(imAxes)
% Creates and initializes the bar display.

% Configure the bar axes.
barAxes = axes('XLim',[0 100], 'YLim',[0 1], 'Box','on', ...
    'Units','Points', 'XTickMode','manual', 'YTickMode','manual', ...
    'XTick',[], 'YTick',[], 'XTickLabelMode', 'manual', ...
    'XTickLabel', [], 'YTickLabelMode', 'manual', 'YTickLabel', []);

% Align the bar axes with the image axes.
oldImUnits = get(imAxes, 'Units');
set(imAxes, 'Units', 'points')
imPos = get(imAxes, 'Position');
set(imAxes, 'Units', oldImUnits)

oldRootUnits = get(0,'Units');
set(0, 'Units', 'points');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', oldRootUnits);

pointsPerPixel = 72/get(0, 'ScreenPixelsPerInch');
width = 360 * pointsPerPixel;
height = 75 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
axPos = [1 .3 .9 .2] .* [imPos(1), pos(4), pos(3:4)];
set(barAxes, 'Position', axPos)

% Create the default patch/line used to mark the level.
xpatch = [0 0 0 0];
ypatch = [0 0 1 1];
hPatch = patch(xpatch, ypatch, 'r', 'EdgeColor', 'r', 'EraseMode', 'none');

xline = [100 0 0 100 100];
yline = [0 0 1 1 0];
hLine = line(xline, yline, 'EraseMode', 'none');
set(hLine, 'Color', get(gca, 'XColor'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prueba] = analisis(imatges)
    entro = 1

        background = imatges(:,:,:,1);
        j = uint8(7)
        suma = imatges(:,:,:,1);
        for i=2:10
             suma = (suma + imatges(:,:,:,j))/2;
             resta = imatges(:,:,:,j) -background;
             background = imatges(:,:,:,j) - resta ;
             j = uint8(mod((j +3),10));
            if (j == 0) j = 3; end
        end
        
        r = im2bw(resta, 0.05);
        r2 = Erode(r);
        s = size(imatges(:,:,:,1));
        area_filtre = double(int32((s(1,1) * s(1,2))*0.000005));
        se = strel('diamond',area_filtre);
        r3 = Close(r2, se);
        r4 = (imfill(r3,'holes'));
        r5 = Close(r4, se);
        perfil = imatges(:,:,:,9);
        prueba(:,:,1) = perfil(:,:,1) .* uint8(r5);
        prueba(:,:,2) = perfil(:,:,2) .* uint8(r5);
        prueba(:,:,3) = perfil(:,:,3) .* uint8(r5);
        figure; imshow(prueba);