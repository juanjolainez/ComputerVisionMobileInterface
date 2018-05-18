
% Define frame rate
global counter;
counter = 0;

% Open figure
hFigure=figure(1);

% Set-up webcam video input

sizeX = 640;
sizeY = 480;
% primero se captura un stream de video usando videoinput, con argumento
%de winvideo, numero de dispositivo y formato de la camara, si no sabes usa la
%funcion imaqtool para averiguarlo es YUY o RGB
tamany = ['YUY2_' int2str(sizeX) 'x' int2str(sizeY) ''];
vid=videoinput('winvideo',1,tamany);


% Set parameters for video
% Acquire only one frame each time
set(vid,'FramesPerTrigger',1);
% Go on forever until stopped
set(vid,'TriggerRepeat',Inf);
% Get a grayscale image
set(vid, 'ReturnedColorspace', 'rgb');
triggerconfig(vid, 'Manual');
% set up timer object
dataPassing = ApplicationData;
dataPassing.counter = 0;
NumberFrameDisplayPerSecond=30;
TimerData=timer('TimerFcn', {@analysis,vid, dataPassing},'Period',1/3,'ExecutionMode','fixedRate','BusyMode','drop');


% Start video and timer object
start(vid);
pause(3);
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
