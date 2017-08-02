function varargout = oberflaeche(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oberflaeche_OpeningFcn, ...
                   'gui_OutputFcn',  @oberflaeche_OutputFcn, ...
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
% --- Executes just before oberflaeche is made visible.
function oberflaeche_OpeningFcn(hObject, eventdata, handles, varargin)
    %Variablen
    handles.t           = 0:.01:2*pi;
    handles.recordTime  = 3;
    handles.sampVonTcp  = 288044;
    handles.ifRec       = 0;
    handles.sampR       = 48000;
    handles.recT        = 3;
    %TCP/IP einrichten
    %zu Server
    handles.connIp      = '192.168.178.20';
    handles.connPort    = 1447;
    handles.tcServ = tcpip(handles.connIp, handles.connPort, 'NetworkRole', 'client'); 
    %zu Client
    handles.ip          = '0.0.0.0';
    handles.port        = 55056;
    handles.tc = tcpip(handles.ip, handles.port, 'NetworkRole', 'server');
    handles.tc.InputBufferSize = 0.5*1024*1024; %0,5MB
    
    %Soundfiles einlesen
    [handles.signal1,handles.FS] = audioread('sweap1.wav');
    [handles.signal2,handles.FS] = audioread('sweap2.wav');
    [handles.signal3,handles.FS] = audioread('sweap3.wav');
    
    %von Textfeldern
    handles.offs1 = 0;
    handles.offs2 = 0;
    handles.offs3 = 0;
    handles.dehn = 1;
    handles.pa = [0,0];
    handles.pb = [6,0];
    handles.pc = [0,5];
    handles.pos = [0,0];
    handles.seitAB = 6;
    handles.seitBC = 7.5;
    handles.seitAC = 5;
    handles.dista = 0;
    handles.distb = 0;
    handles.distc = 0;
    %Textfelder füllen
    set(handles.offset1, 'String', num2str(handles.offs1));
    set(handles.offset2, 'String', num2str(handles.offs2));
    set(handles.offset3, 'String', num2str(handles.offs3));
    set(handles.dehnung, 'String', num2str(handles.dehn));
    set(handles.x1, 'String', num2str(handles.pa(1)));
    set(handles.y1, 'String', num2str(handles.pa(2)));
    set(handles.x2, 'String', num2str(handles.pb(1)));
    set(handles.y2, 'String', num2str(handles.pb(2)));
    set(handles.x3, 'String', num2str(handles.pc(1)));
    set(handles.y3, 'String', num2str(handles.pc(2)));
    set(handles.posx, 'String', num2str(handles.pos(1)));
    set(handles.posy, 'String', num2str(handles.pos(2)));
    set(handles.seiteAB, 'String', num2str(handles.seitAB));
    set(handles.seiteBC, 'String', num2str(handles.seitBC));
    set(handles.seiteAC, 'String', num2str(handles.seitAC));
    
    boxen_anzeigen(handles)  
    
    handles.output = hObject;
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = oberflaeche_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in tbt_startTcp.
function tbt_startTcp_Callback(hObject, eventdata, handles)
   %Empfang von Audiodaten über TCP starten
    button_state = get(hObject,'Value');
    if button_state == get(hObject,'Max')
        %%%Programm gestartet/Button gedrückt
        set(handles.tbt_startTcp,'BackgroundColor','green');
        pause(0.5)
        while button_state == get(hObject,'Max')
        %Dauerschleife so lange, wie Button gedrückt
            received = 0;
            %Daten per TCP lesen
            while received ~= handles.sampVonTcp
                data = fread(handles.tc,handles.sampVonTcp);%read the data from remote. timeout can occur
                fileID = fopen('tcp.wav','w');
                received = fwrite(fileID,data)
                fclose(fileID);
                disp('received');
            end 
            fileID = fopen('tcp.wav','w');
            fwrite(fileID,data);
            fclose(fileID);
            %Auswertung
             [recordFile, FS] = audioread('tcp.wav');
             auswertung(hObject, handles, recordFile);            
             button_state = get(hObject,'Value');
             pause(3);
        end
    end
    set(handles.tbt_startTcp,'BackgroundColor','0.94,0.94,0.94,');    
 % --- Executes on button press in tbt_startRec.
function tbt_startRec_Callback(hObject, eventdata, handles)
    %Aufnahme von Audiodaten über Mikrofon
    button_state = get(hObject,'Value'); 
    if button_state == get(hObject,'Max')
        starttime = mod(str2double(datestr(now,'SS')),5);
        while button_state == get(hObject,'Max')
            difftime = starttime - mod(str2double(datestr(now,'SS')),5);
            if difftime < 0
                difftime = difftime + 5;
            end 
            pause(difftime);
            set(handles.tbt_startRec,'BackgroundColor','red');
            recordFile = record(handles.sampR,handles.recT);
            set(handles.tbt_startRec,'BackgroundColor','green');
            auswertung(hObject, handles, recordFile);
            
            button_state = get(hObject,'Value');
         end
    end
    set(handles.tbt_startRec,'BackgroundColor','0.94,0.94,0.94');

function bt_connServer_Callback(hObject, eventdata, handles)
    %Verbindung zu Webserver einrichten
    set(handles.bt_connServer,'BackgroundColor','yellow');
    pause(0.5);
    fclose(handles.tcServ);
    fopen(handles.tcServ);
    set(handles.bt_connServer,'BackgroundColor','green');
    guidata(hObject, handles);
    
function bt_connClient_Callback(hObject, eventdata, handles)
    %Verbindung zu Client(Raspberry PI) einrichten
    set(handles.bt_connClient,'BackgroundColor','yellow');
    pause(0.5);
    fclose(handles.tc);
    disp('fopen');
    fopen(handles.tc);
    disp('geopened');
    set(handles.bt_connClient,'BackgroundColor','green');
        
function auswertung(hObject, handles, recordFile)
    [kreuzkorell1, kreuzkorell2, kreuzkorell3] = kreuzkorell(recordFile, handles.signal1, handles.signal2, handles.signal3, handles.FS);
    %Sample offset
    kreuzkorell1 = kreuzkorell1 - handles.offs1;
    kreuzkorell2 = kreuzkorell2 - handles.offs2;
    kreuzkorell3 = kreuzkorell3 - handles.offs3;
    if kreuzkorell1 <= kreuzkorell2 && kreuzkorell1 <= kreuzkorell3
        sampklein = kreuzkorell1; 
    elseif kreuzkorell2 <= kreuzkorell1 && kreuzkorell2 <= kreuzkorell3
        sampklein = kreuzkorell2;
    else
        sampklein = kreuzkorell3;
    end
    kreuzkorell1 = kreuzkorell1 - sampklein;
    kreuzkorell2 = kreuzkorell2 - sampklein;
    kreuzkorell3 = kreuzkorell3 - sampklein;
    %Sampledifferenz ausgeben
    set(handles.sampdiff1, 'String', num2str(kreuzkorell1));
    set(handles.sampdiff2, 'String', num2str(kreuzkorell2));
    set(handles.sampdiff3, 'String', num2str(kreuzkorell3));
    %Differenz der Entfernungen zu Boxen
    handles.ra = kreuzkorell1 /handles.FS * 343.2 * handles.dehn;
    handles.rb = kreuzkorell2 /handles.FS * 343.2 * handles.dehn;
    handles.rc = kreuzkorell3 /handles.FS * 343.2 * handles.dehn;
    %TDOA Berechnung
    [handles.pos,handles.dista, handles.distb, handles.distc] = tdoa(handles.pa, handles.pb, handles.pc, handles.ra, handles.rb, handles.rc);
    %Position an Server senden
    %Entfernung ausgeben
    set(handles.entf1, 'String', num2str(handles.ra));
    set(handles.entf2, 'String', num2str(handles.rb));
    set(handles.entf3, 'String', num2str(handles.rc));
    maxlen = (handles.seitAB + handles.seitBC + handles.seitAC)/2
    if handles.dista < maxlen && handles.distb < maxlen && handles.distc < maxlen   
        if strcmp(handles.tcServ.status, 'open')
            fwrite(handles.tcServ, ['{"x":' num2str(handles.pos(1)) ',"y":' num2str(handles.pos(2)) '}']);
        end
        set(handles.posx,'BackgroundColor','w');
        set(handles.posy,'BackgroundColor','w');

        %Position ausgeben
        set(handles.posx, 'String', num2str(handles.pos(1)));
        set(handles.posy, 'String', num2str(handles.pos(2)));  
        boxen_anzeigen(handles)
    else
        set(handles.posx,'BackgroundColor','red');
        set(handles.posy,'BackgroundColor','red');
    end
    guidata(hObject, handles);
function boxen_anzeigen(handles) 
        cla(handles.diag);
        axis([-1 (handles.pb(1)+1) -1 (handles.pc(2)+1)]);
        hold on;
        plot(handles.diag,0.2*cos(handles.t)+handles.pa(1),0.2*sin(handles.t)+handles.pa(2),'r');
        plot(handles.diag,0.2*cos(handles.t)+handles.pb(1),0.2*sin(handles.t)+handles.pb(2),'r');
        plot(handles.diag,0.2*cos(handles.t)+handles.pc(1),0.2*sin(handles.t)+handles.pc(2),'r');
        plot(handles.diag,0.2*cos(handles.t)+handles.pos(1),0.2*sin(handles.t)+handles.pos(2),'g');
        plot(handles.diag,handles.dista*cos(handles.t)+handles.pa(1),handles.dista*sin(handles.t)+handles.pa(2),'b');
        plot(handles.diag,handles.distb*cos(handles.t)+handles.pb(1),handles.distb*sin(handles.t)+handles.pb(2),'b');
        plot(handles.diag,handles.distc*cos(handles.t)+handles.pc(1),handles.distc*sin(handles.t)+handles.pc(2),'b');
%Funktionen bei Änderung von Eingabefeldern
function seiteAB_Callback(hObject, eventdata, handles)
    handles.seitAB = str2double(get(handles.seiteAB,'String'));
    winkel= acosd(((handles.seitBC)^2-(handles.seitAC)^2-(handles.seitAB)^2) / (-2*(handles.seitAC)*handles.seitAB));
    if isreal(winkel)
        handles.pb(1) = handles.seitAB;
        handles.pc(1) = (handles.seitAC) * cosd(winkel);
        handles.pc(2) = (handles.seitAC) * sind(winkel);
        set(handles.x2, 'String', num2str(handles.pb(1)));
        set(handles.x3, 'String', num2str(handles.pc(1)));
        set(handles.y3, 'String', num2str(handles.pc(2)));
        boxen_anzeigen(handles)
    end
    guidata(hObject, handles);   
function seiteBC_Callback(hObject, eventdata, handles)
    handles.seitBC = str2double(get(handles.seiteBC,'String'));

    winkel= acosd(((handles.seitBC)^2-(handles.seitAC)^2-(handles.seitAB)^2) / (-2*(handles.seitAC)*handles.seitAB));
    if isreal(winkel)
        handles.pb(1) = handles.seitAB;
        handles.pc(1) = (handles.seitAC) * cosd(winkel);
        handles.pc(2) = (handles.seitAC) * sind(winkel);
        set(handles.x2, 'String', num2str(handles.pb(1)));
        set(handles.x3, 'String', num2str(handles.pc(1)));
        set(handles.y3, 'String', num2str(handles.pc(2)));
        boxen_anzeigen(handles)
    end
    guidata(hObject, handles);   
function seiteAC_Callback(hObject, eventdata, handles)
    handles.seitAC = str2double(get(handles.seiteAC,'String'));
    winkel= acosd(((handles.seitBC)^2-(handles.seitAC)^2-(handles.seitAB)^2) / (-2*(handles.seitAC)*handles.seitAB));
    if isreal(winkel)
        handles.pb(1) = handles.seitAB;
        handles.pc(1) = (handles.seitAC) * cosd(winkel);
        handles.pc(2) = (handles.seitAC) * sind(winkel);
        set(handles.x2, 'String', num2str(handles.pb(1)));
        set(handles.x3, 'String', num2str(handles.pc(1)));
        set(handles.y3, 'String', num2str(handles.pc(2)));
        boxen_anzeigen(handles)
    end
    guidata(hObject, handles);    
function offset1_Callback(hObject, eventdata, handles)
    handles.offs1 = str2double(get(handles.offset1,'String'));
    sampdiff = str2double(get(handles.sampdiff1,'String'));
    set(handles.sampdiff1, 'String', num2str(sampdiff - handles.offs1));
    handles.ra = (sampdiff-handles.offs1) /handles.FS * 334 * handles.dehn;
    set(handles.entf1, 'String', num2str(handles.ra));
    guidata(hObject, handles);
function offset2_Callback(hObject, eventdata, handles)
    handles.offs2 = str2double(get(handles.offset2,'String'));
    sampdiff = str2double(get(handles.sampdiff2,'String'));
    set(handles.sampdiff2, 'String', num2str(sampdiff - handles.offs2));
    handles.rb = (sampdiff-handles.offs2) /handles.FS * 334 * handles.dehn;
    set(handles.entf2, 'String', num2str(handles.rb));
    guidata(hObject, handles);
function offset3_Callback(hObject, eventdata, handles)
    handles.offs3 = str2double(get(handles.offset3,'String'));
    sampdiff = str2double(get(handles.sampdiff3,'String'));
    set(handles.sampdiff3, 'String', num2str(sampdiff - handles.offs3));
    handles.rc = (sampdiff-handles.offs3) /handles.FS * 334 * handles.dehn;
    set(handles.entf3, 'String', num2str(handles.rc));
    guidata(hObject, handles);
function dehnung_Callback(hObject, eventdata, handles)
    handles.dehn = str2double(get(handles.dehnung,'String'));
    samp1 = str2double(get(handles.sampdiff1,'String'));
    samp2 = str2double(get(handles.sampdiff2,'String'));
    samp3 = str2double(get(handles.sampdiff3,'String'));
    handles.ra = samp1 /handles.FS * 334 * handles.dehn;
    handles.rb = samp2 /handles.FS * 334 * handles.dehn;
    handles.rc = samp3 /handles.FS * 334 * handles.dehn;
    set(handles.entf1, 'String', num2str(handles.ra));
    set(handles.entf2, 'String', num2str(handles.rb));
    set(handles.entf3, 'String', num2str(handles.rc));
    guidata(hObject, handles);

    %Create Funktionen
function seiteAB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end   
function seiteBC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function seiteAC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sampdiff1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sampdiff2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sampdiff3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function offset1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function offset2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function offset3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function dehnung_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function entf1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function entf2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function entf3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function x1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function y1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function x2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function y2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function x3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function y3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function posx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function posy_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
