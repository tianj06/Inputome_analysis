function varargout = SetTimeWindowGui(varargin)
% SETTIMEWINDOWGUI MATLAB code for SetTimeWindowGui.fig
%      SETTIMEWINDOWGUI, by itself, creates a new SETTIMEWINDOWGUI or raises the existing
%      singleton*.
%
%      H = SETTIMEWINDOWGUI returns the handle to a new SETTIMEWINDOWGUI or the handle to
%      the existing singleton*.
%
%      SETTIMEWINDOWGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTIMEWINDOWGUI.M with the given input arguments.
%
%      SETTIMEWINDOWGUI('Property','Value',...) creates a new SETTIMEWINDOWGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetTimeWindowGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetTimeWindowGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetTimeWindowGui

% Last Modified by GUIDE v2.5 16-Aug-2014 11:22:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SetTimeWindowGui_OpeningFcn, ...
                   'gui_OutputFcn',  @SetTimeWindowGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before SetTimeWindowGui is made visible.
function SetTimeWindowGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetTimeWindowGui (see VARARGIN)

% Choose default command line output for SetTimeWindowGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SetTimeWindowGui.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes SetTimeWindowGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SetTimeWindowGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in choosePSTH.
function choosePSTH_Callback(hObject, eventdata, handles)
% hObject    handle to choosePSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns choosePSTH contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choosePSTH
axes(handles.psthAxes);
cla;

popup_sel_index = get(handles.choosePSTH, 'Value');
switch popup_sel_index
    case 1
        plotPSTHGUI(handles.data, 1)
    case 2
        plotPSTHGUI(handles.data, 0)
end

% --- Executes during object creation, after setting all properties.
function choosePSTH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choosePSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot US+', 'plot US-'});


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_data(handles)

% --- Executes on selection change in chooseFeature.
function chooseFeature_Callback(hObject, eventdata, handles)
% hObject    handle to chooseFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseFeature
axes(handles.featureAxes);
cla;
CueColor= [  0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % red
% 1 'Baseline', 2 'Cue', 3 'Delay', 4 'Reward', 5 'Airpuff'
popup_sel_index = get(handles.chooseFeature, 'Value');
events = handles.data.events;
st = handles.data.responses.spike;

switch popup_sel_index
    case 1  % plot mean firing rate
        bin = 5000; % 5s bin to calculate firing rate
        trigger = st(1):bin-1:st(end);
        bl = sum(triggered_average_rate(trigger,st,0,bin-1),2)*1000/bin;
        bl = smooth(bl);
        plot(trigger,bl)
        xlim([st(1) st(end)])
    case 2 % plot 90% cue firing rate 
        trigger = events.odorOn(events.odorID==3);
        x = find(events.odorID==3);
        [~, r] = plotPSTH(st,trigger,1000,1000,'plotflag','none');
        cueResponse= sum(r{1}(:,1001:1500),2) -sum(r{1}(:,501:1000),2) ;
        plot(x,cueResponse,'b','LineWidth',2)
    case 3 % plot 90% delay response
        trigger = events.odorOn(events.odorID==3);
        x = find(events.odorID==3);
        [~, r] = plotPSTH(st,trigger,1000,2000,'plotflag','none');
        delayResposne = sum(r{1}(:,2001:end),2) - sum(r{1}(:,1:1000),2); 
        plot(x,delayResposne ,'b','LineWidth',2);
    case 4 % plot 50% reward response
        trigger = events.rewardOn(events.trialType==3);
        x = find(events.trialType==3);
        [~, r] = plotPSTH(st,trigger,3000,1000,'plotflag','none');
        rewardResponse = sum(r{1}(:,3001:end),2) - sum(r{1}(:,1:1000),2); 
        plot(x,rewardResponse,'b','LineWidth',2)
    case 5 % plot 90% airpuff repsonse
        trigger = events.airpuffOn(events.trialType==7);
        x = find(events.trialType==7);
        [~, r] = plotPSTH(st,trigger,3000,1000,'plotflag','none');
        airpuffResponse = sum(r{1}(:,3001:end),2) - sum(r{1}(:,1:1000),2); 
        plot(x,airpuffResponse,'b','LineWidth',2)
end

% --- Executes during object creation, after setting all properties.
function chooseFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'all', '90%Cue','90%Delay','50%Reward','90%Airpuff'});

% --- Executes on button press in loadFile.
function loadFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.RectWindow = nan(1,4);
[dataFile, ~] = uigetfile( '*.mat',...
    'Pick one formatted data file(s).','MultiSelect','off');
handles.fileName = dataFile;
set(findobj('Tag','FileName'),'String',dataFile)
handles.data = load(dataFile);
 axes(handles.psthAxes);
plotPSTHGUI(handles.data, 1)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function plotPSTHGUI(data, US)

events = data.events;
responses = data.responses;
if US
    trig = {events.odorOn((events.odorID==3)&(~isnan(events.rewardOn))), ...   ~90% reward
            events.odorOn((events.odorID==1)&(~isnan(events.rewardOn))), ...   ~50% reward
            events.odorOn((events.odorID==2)&(isnan(events.rewardOn))), ...   ~90% no reward
            events.odorOn((events.odorID==4)&(~isnan(events.airpuffOn)))};    % ~90% airpuff
else
    trig = {events.odorOn((events.odorID==3)&(isnan(events.rewardOn))), ...   ~90% reward
            events.odorOn((events.odorID==1)&(isnan(events.rewardOn))), ...   ~50% reward
            events.odorOn((events.odorID==2)&(~isnan(events.rewardOn))), ...   ~90% no reward
            events.odorOn((events.odorID==4)&(isnan(events.airpuffOn)))};    % ~90% airpuff
end
CueColor= [  0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % red
cla;
legText = {'Reward cue', '50% cue','No reward cue', 'Airpuff cue'};
[~,~,~,~,~,~,~,~,legh] = ...
  plotPSTH(responses.spike, trig, 1000, 4000, 'plottype','PSTH', ...
    'smooth','psp',50,'legend', legText,...
    'ax',gca,'co',CueColor);
set(legh,'box','off','Location','NorthWest');
plot([0 0],ylim,'k--');
plot([2000 2000],ylim,'k--');
title('Neuron PSTH')
hold off;


% --- Executes on button press in DrawWindow.
function DrawWindow_Callback(hObject, eventdata, handles)
% hObject    handle to DrawWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hrect = imrect(handles.featureAxes)

% RectWindow: [xmin ymin width height]
handles.RectWindow = getPosition(hrect); 
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in Next.
function Next_Callback(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    filelist = what(pwd);
    filelist = filelist.mat;
    idx = strfind(filelist, handles.fileName);
    a = find(~cellfun(@isempty,idx));
    nextfile = filelist{a+1};
    save_data(handles);
    handles.RectWindow = nan(1,4);
    handles.fileName = nextfile;
    set(findobj('Tag','FileName'),'String',nextfile)
    handles.data = load(nextfile);
     axes(handles.psthAxes);
    plotPSTHGUI(handles.data, 1)
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over DrawWindow.
function DrawWindow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to DrawWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function save_data (handles)
        % RectWindow: [xmin ymin width height]
timeWindow = handles.RectWindow([1 3]);
timeWindow(2) = timeWindow(1) + timeWindow(2);
save([handles.fileName],'-append','timeWindow');

