function [] = gui_MirrorCmdWindow

%% // just to remove the listener in case something goes wrong
%closeup = onCleanup(@() cleanup);

%% // create figure and uicontrol
h.f = figure('Position',[810 50 500 100]);
fig1=gcf;
fig1.ToolBar = 'none';
fig1.MenuBar = 'none'; 
fig1.NumberTitle = 'off'; 
h.txtOut = uicontrol('Style','edit','Max',30,'Min',0,...
                   'HorizontalAlignment','left',...
                   'FontName','FixedWidth',...
                   'Units','Normalized',...
                   'Enable','On',...
                   'Position',[.01 .02 .98 .9]);

%h.f = gcf;

guidata(h.f,h)

%// intercept close request function to cleanup before close
set(gcf,'CloseRequestFcn',@myCloseRequestFcn) 

%% // Get the handle of the Matlab control window
jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
jCmdWin = jDesktop.getClient('Command Window');
jTextArea = jCmdWin.getComponent(0).getViewport.getView;
%cwText = char(jTextArea.getText);
%% // Get the handle of the jave edit box panel component
jtxtBox = findjobj(h.txtOut) ;
jTxtPane = jtxtBox.getComponent(0).getComponent(0) ;

%// Save these handles
setappdata( h.f , 'jTextArea', jTextArea ) ;
setappdata( h.f , 'jTxtPane',  jTxtPane ) ;


tab
    function tab
   getappdata(h.f) ;
    jTextArea = getappdata( h.f , 'jTextArea' ) ;

    %my_command = 'ping google.com -n 10' ;
    startPos = jTextArea.getCaretPosition ;
    set(jTextArea,'CaretUpdateCallback',{@commandWindowMirror,h.f,startPos}) ;
%     for i=1:10
%         display('ans is %d');
%     end
    %pause(1) %// just to make sure we catch the last ECHO before we kill the callback
    %set(jTextArea,'CaretUpdateCallback',[]) ;
  
    end

function commandWindowMirror(~,~,hf,startPos)
    h = guidata(gcf) ;
    jTextArea = getappdata( h.f , 'jTextArea' ) ;

    %// retrieve the text since the start position
    txtLength = jTextArea.getCaretPosition-startPos ;
    if txtLength > 0 %// in case a smart bugger pulled a 'clc' between calls
        cwText = char(jTextArea.getText(startPos-1,txtLength) ) ; 
    end
    %// display it in the gui textbox
    set( h.txtOut, 'String',cwText ) ; 
  
% jhText1 = findjobj(h.txtOut);
% jTxtPane1 = jhText1.getComponent(0).getComponent(0) ;
jtxtBox = findjobj(h.txtOut) ;
jTxtPane = jtxtBox.getComponent(0).getComponent(0) ;
jTxtPane.setCaretPosition(jTxtPane.getDocument.getLength);
end

function scroll_to_bottom(hf)
    %// place caret at the end of the texbox (=scroll to bottom)
    jTxtPane  = getappdata( hf , 'jTxtPane' ) ;
    jTxtPane.setCaretPosition(jTxtPane.getDocument.getLength)
end

function myCloseRequestFcn(hobj,~)
    cleanup ;       %// make sure we remove the listener
    delete(hobj) ;  %// delete the figure
end

function cleanup
    jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    jCmdWin = jDesktop.getClient('Command Window');
    jTextArea = jCmdWin.getComponent(0).getViewport.getView;
    set(jTextArea,'CaretUpdateCallback',[]) ;
end
end