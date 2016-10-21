%CES 2/21/2011

function FadeOps(initial)

% Variables that can/should be changed according to task
reward1 = 0; %Reward durations
reward2 = .11; 
reward3 = .12; 
reward4 = .14;
reward5 = .16;
reward6 = .18;
radius = 10; %Radius of fixation dot
fixmin = .1; %Fixation time min for reward
fixminbox = 0.2; %Fixation time min for reward

feedbacktime = .25; %Feedback circle display length
iti = 2; %Intertrial interval

wr = 50; %Wiggle room around choice
hD = 275; %Rectangles' horizontal displacement from center
width = 80; %Width of rects
height = 300; %Height of rects
fixbox = 5; % Thickness of rect fixation cue
windheight = 175; %Height of fixation window
windwidth = 175; %Width of fixation window
dispwind = 0; %Show fixation window

color6 = [0 255 255]; %Reward color 6
color5 = [0 255 100]; %Reward color 5
color4 = [0 255 0]; %Reward color 4
color3 = [0 0 255]; %Reward color 3
color2 = [100 100 100]; %Reward color 2
color1 = [255 0 0]; %Reward color 1
fixcuecolor = [255 255 255]; %Rect fixation cue color
backcolor = [50 50 50]; %Background color
maincolor = [255 255 0]; %Color of fixation dot

% Create data file*****************
% initial is subject initial  e.g. 'G' for George
cd /Data/FadeOps;
dateS = datestr(now, 'yymmdd');
filename = [initial dateS '.1.FO.mat'];
foldername = [initial dateS];
warning off all;
try
    mkdir(foldername)
end
warning on all;
cd(foldername)
trynum = 1;
while(trynum ~= 0)
    if(exist(filename)~=0)
        trynum = trynum +1;
        filename = [initial dateS '.' num2str(trynum) '.FO.mat'];
    else
        savename = [initial dateS '.' num2str(trynum) '.FO.mat'];
        trynum = 0;
    end
end
home

% Setup Eyelink*****************
HideCursor; %This hides the Psychtoolbox startup Screen
oldEnableFlag = Screen('Preference', 'VisualDebugLevel', 0);% warning('off','MATLAB:dispatcher:InexactCaseMatch')
oldLevel = Screen('Preference', 'Verbosity', 0);%Hides PTB Warnings
global window; window = Screen('OpenWindow', 1, 0);
if ~Eyelink('IsConnected')
    Eyelink('initialize');%connects to eyelink computer
end
Eyelink('startrecording');%turns on the recording of eye position
Eyelink('Command', 'randomize_calibration_order = NO');
Eyelink('Command', 'force_manual_accept = YES');
Eyelink('StartSetup');
trackerResp = true; % Wait until Eyelink actually enters Setup mode:
while trackerResp && Eyelink('CurrentMode')~=2 % Mode 2 is setup mode
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))% Let the user abort with ESCAPE
        disp('Aborted while waiting for Eyelink!');
        trackerResp = false;
    end
end
Eyelink('SendKeyButton',double('o'),0,10); % Send the keypress 'o' to put Eyelink in output mode
Eyelink('SendKeyButton',double('o'),0,10);

% Count trials for the whole day*****************
cd ..;
daystrials = 0;
thesefiles = dir(foldername);
cd(foldername);
fileIndex = find(~[thesefiles.isdir]);
for i = 1:length(fileIndex)
    thisfile = thesefiles(fileIndex(i)).name;
    thisdata = importdata(thisfile);
    daystrials = daystrials + length(thisdata);
end

% Ask to set up*****************
Screen('FillRect', window, backcolor);
Screen(window,'flip');
continuing = 1;
go = 0;
disp('Right Arrow to start');
gokey=KbName('RightArrow');
nokey=KbName('ESCAPE');
while((go == 0) && (continuing == 1))
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(gokey)
        go = 1;
    elseif keyCode(nokey)
        continuing = 0;
    end
end
while keyIsDown
    [keyIsDown,secs,keyCode] = KbCheck;
end
home

% Set variables*****************
targX = 512;
targY = 384;
Fxmin = targX - (windwidth / 2);
Fxmax = targX + (windwidth / 2);
Fymin = (targY - (windheight / 2));
Fymax = (targY + (windheight / 2));
Lxmin = (targX - (width / 2))-hD; Lxmax = (targX + (width / 2))-hD;
Lymin = (targY - (height / 2)); Lymax = (targY + (height / 2));
Rxmin = (targX - (width / 2))+hD; Rxmax = (targX + (width / 2))+hD;
Rymin = (targY - (height / 2)); Rymax = (targY + (height / 2));
fixating = 0;
step = 6;
trial = 0;
pause = 0;
wait = 0;
buffer = 0;
timeofchoice = GetSecs - (wait + feedbacktime + buffer + iti);
reactiontime = 0;
savecommand = ['save ' savename ' data'];
correct = 0;
possible = 0;
pcent2graph(1) = 0;
starttime = GetSecs;

while(continuing);
    % Set Screen*****************
    if(step == 1)
        if(dispwind == 1)
            Screen('FillRect', window, [0 255 0], [(Fxmin) (Fymin) (Fxmax) (Fymax)]);
            Screen('FillRect', window, [0 0 0], [(Fxmin+5) (Fymin+5) (Fxmax-5) ((Fymax)-5)]);
        end
        Screen('FillOval', window, maincolor, [(targX-radius) ((targY-radius)) (targX+radius) ((targY+radius))]);
    end
    if(step == 2)
        if(fixating == 1)
            Screen('FillRect', window, fixcuecolor, [(x1min-fixbox) (y1min-fixbox) (x1max+fixbox) ((y1min + (leftwait * height))+fixbox)]);
        elseif(fixating == 2)
            Screen('FillRect', window, fixcuecolor, [(x2min-fixbox) (y2min-fixbox) (x2max+fixbox) ((y2min + (rightwait * height))+fixbox)]);
        end
        Screen('FillRect', window, leftcolor, [x1min y1min x1max (y1min + (leftwait * height))]);
        Screen('FillRect', window, rightcolor, [x2min y2min x2max (y2min + (rightwait * height))]);
    end
    if(step == 3)
        now = GetSecs;
        if(choice == 1)
            x1min = Lxmin; x1max = Lxmax; y1min = Lymin;
            y1max = ((((wait*waitrange)-(now - timeofchoice)) / (wait*waitrange)) * height) + y1min;
            eval(['Lcolor = color' leftcolor ';']);
            Screen('FillRect', window, Lcolor, [x1min y1min x1max y1max]);
        elseif(choice == 2)
            x2min = Rxmin; x2max = Rxmax; y2min = Rymin;
            y2max = ((((wait*waitrange)-(now - timeofchoice)) / (wait*waitrange)) * height) + y2min;
            eval(['Rcolor = color' rightcolor ';']);
            Screen('FillRect', window, Rcolor, [x2min y2min x2max y2max]);
        end
    end
    if(step == 4)
        eval(['feedbackcolor = color' choicecolor ';']);
        if(choice == 1)
            Screen('FillOval', window, feedbackcolor, [(mean([x1max x1min])-40) (mean([Lymax y1min])-40) (mean([x1max x1min])+40) (mean([Lymax y1min])+40)]);
        elseif(choice == 2)
            Screen('FillOval', window, feedbackcolor, [(mean([x2max x2min])-40) (mean([Rymax y2min])-40) (mean([x2max x2min])+40) (mean([Rymax y2min])+40)]);
        end
    end
    Screen(window,'flip');
    
    % Check eye position*****************
    e = Eyelink('newestfloatsample');
    if(step == 1)
        if(((Fxmin < e.gx(1)) && (e.gx(1) < Fxmax)) && (((Fymin) < e.gy(1)) && (e.gy(1) < (Fymax)))) %Gaze is in box around fixation dot
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) 
                reactiontime = GetSecs;
                step = 2;
                fixating = 0;
            end
        elseif(fixating == 1)
            fixating = 0;
        end
    elseif(step == 2)
        if(((x1min-wr < e.gx(1)) && (e.gx(1) < x1max+wr)) && ((y1min-wr < e.gy(1)) && (e.gy(1) < y1max+wr))) %Gaze is in box around LEFT
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixminbox + fixtime))) 
                timeofchoice = GetSecs;
                choice = 1;
                choicecolor = leftcolor;
                wait = leftwait;
                buffer = leftbuffer;
            end
        elseif(fixating == 1)
            fixating = 0;
        end
        if(((x2min-wr < e.gx(1)) && (e.gx(1) < x2max+wr)) && ((y2min-wr < e.gy(1)) && (e.gy(1) < y2max+wr))) %Gaze is in box around RIGHT
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 2;
            elseif((fixating == 2) && (GetSecs > (fixminbox + fixtime))) 
                timeofchoice = GetSecs;
                choice = 2;
                choicecolor = rightcolor;
                wait = rightwait;
                buffer = rightbuffer;
            end
        elseif(fixating == 2)
            fixating = 0;
        end
    end
    
    % Watch for keyboard interaction*****************
    comm=keyCapture();
    if(comm==-1) % ESC stops the session
        continuing=0;
    end
    if(comm==1) % Space rewards monkey
        reward(reward5);
    end
    if(comm==2) % Control pauses/unpauses
        if(pause == 0)
            pause = 1;
        else
            timeofchoice = GetSecs - (feedbacktime + iti);
            pause = 0;
        end
    end
    
    % Progress between steps*****************
    if(step == 2 && choice ~= 0)
        step = 3;
        fixating = 0;
    elseif(step == 3 && GetSecs > (timeofchoice + (wait*waitrange)))
        step = 4;
        eval(['rewardsize = reward' choicecolor ';']);
        reward(rewardsize);
    elseif(step == 4 && GetSecs > (timeofchoice + (wait*waitrange) + feedbacktime))
        step = 5;
    elseif(step == 5 && GetSecs > (timeofchoice + (wait*waitrange) + feedbacktime + buffer))
        step = 6;
        
        %Save data to .m file
        data(trial).choice = choice;
        data(trial).leftcolor = leftcolor; 
        data(trial).rightcolor = rightcolor; 
        data(trial).leftwait = leftwait;
        data(trial).rightwait = rightwait;
        data(trial).waitrange = waitrange;
        data(trial).reactiontime = (reactiontime - timeofchoice);
        eval(savecommand);
        
        %Print to command window
        disp(' ');
        home;
        if(trial ~= (trial + daystrials))
            disp(['Trial #' num2str(trial) '/' num2str(trial + daystrials)]);
        else
            disp(['Trial #' num2str(trial)]);
        end
        elapsed = GetSecs-starttime;
        disp(sprintf('Elapsed time: %.0fh %.0fm', floor(elapsed/3600), floor((elapsed-(floor(elapsed/3600)*3600))/60)));
        possible = possible + 1;
        if(((leftcolor >= rightcolor) && (choice == 1)) || ((leftcolor <= rightcolor) && (choice == 2)))
            correct = correct + 1;
        end
        if(possible > 0)
            disp(sprintf('Correct: %3.2f%%', (100*correct/possible)));
        end
        pcent2graph(trial) = (100*correct/possible);
        
        %Set up next trial
        choice = 0;
        trial = trial + 1;
        colors = randperm(6);
        leftcolor = colors(1);
        colors = randperm(6);
        rightcolor = colors(1);
        leftwait = rand;
        rightwait = rand;
        if(leftwait > rightwait)
            rightbuffer = leftwait - rightwait;
            leftbuffer = 0;
        else
            leftbuffer = rightwait - leftwait;
            rightbuffer = 0;
        end
        
    elseif(((step == 6 && GetSecs > (timeofchoice + wait + feedbacktime + buffer + iti)) && (pause == 0)))
        step = 1;
    end
end
if(length(pcent2graph) > 1)
    plot(pcent2graph);
end
Eyelink('stoprecording');
sca;
%keyboard
end

function a = keyCapture()
stopkey=KbName('ESCAPE');
pause=KbName('RightControl');
reward=KbName('space');
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(stopkey)
    a = -1;
elseif keyCode(reward)
    a = 1; 
elseif keyCode(pause)
    a = 2;
else
    a = 0;
end
while keyIsDown
    [keyIsDown,secs,keyCode] = KbCheck;
end
end

function reward(rewardduration)
daq=DaqDeviceIndex;
if(rewardduration ~= 0)
    DaqAOut(daq,0,.6);
    starttime=GetSecs;
    while (GetSecs-starttime)<(rewardduration);
    end;
    DaqAOut(daq,0,0);
    StopJuicer;
end
end