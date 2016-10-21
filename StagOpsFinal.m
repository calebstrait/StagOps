%CES 1/23/2011

function StagOpsFinal(initcell)

% Variables that can/should be changed according to task
chance3op = .333333; %Chance of a 3option trial
rewardmin = 0; %Small reward duration
rewardmed = .10; %Medium reward duration
rewardlarge = .12; %Large reward duration
rewardhuge = .16; %Huge reward duration
radius = 10; %Radius of fixation dot
fixmin = .1; %Fixation time min for reward
fixminbox = 0.2; %Fixation time min for reward

recttime = .35; %Time with each rect on
xtra3optime = .15;
btwnrecttime = .2; %Time between rects
feedbacktime = .25; %Feedback circle display length
reciti = .8; %Intertrial interval
noreciti = 3; %Intertrial interval for when not recording

wr = 50; %Wiggle room around choice
hD2 = 275; %Rectangles' horizontal displacement from center for 2options
hD3 = 350; %Rectangles' horizontal displacement from center for 3options
vD3 = 200; %Rectangles' vertical displacement from center for 3options
width = 80; %Width of rects
global height; height = 300; %Height of rects
fixbox = 5; % Thickness of rect fixation cue
windheight = 175; %Height of fixation window
windwidth = 175; %Width of fixation window
dispwind = 0; %Show fixation window
chanceHuge = 0.5; %Chance of huge reward trial
chanceSafe = 0.125; %Chance of safe trial

global hugecolor; hugecolor = [0 255 0]; %Huge reward color
global largecolor; largecolor = [0 0 255]; %Large reward color
global medcolor; medcolor = [100 100 100]; %Medium reward color
global smallcolor; smallcolor = [255 0 0]; %Small reward color
fixcuecolor = [255 255 255]; %Rect fixation cue color
backcolor = [50 50 50]; %Background color
maincolor = [255 255 0]; %Color of fixation dot
feedbackcolor = [255 255 255]; %Color of feedback circle

% Create data file*****************
% initcell is subject initial and cell letter, e.g. 'GA' for George, cell A
% if there is no cell just input the initial, e.g. 'G'
cd /Data/StagOps;
dateS = datestr(now, 'yymmdd');
initial = initcell(1);
if(numel(initcell) == 1)
    cell = '';
else
    cell = initcell(2);
end
filename = [initial dateS '.' cell '1.SO.mat'];
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
        filename = [initial dateS '.' cell num2str(trynum) '.SO.mat'];
    else
        savename = [initial dateS '.' cell num2str(trynum) '.SO.mat'];
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
Lxmin = (targX - (width / 2))-hD2; Lxmax = (targX + (width / 2))-hD2;
Lymin = (targY - (height / 2)); Lymax = (targY + (height / 2));
Rxmin = (targX - (width / 2))+hD2; Rxmax = (targX + (width / 2))+hD2;
Rymin = (targY - (height / 2)); Rymax = (targY + (height / 2));
L3xmin = (targX - (width / 2))-hD3; L3xmax = (targX + (width / 2))-hD3;
T3ymin = (targY - (height / 2))-vD3; T3ymax = (targY + (height / 2))-vD3;
R3xmin = (targX - (width / 2))+hD3; R3xmax = (targX + (width / 2))+hD3;
B3ymin = (targY - (height / 2))+vD3; B3ymax = (targY + (height / 2))+vD3;
fixating = 0;
step = 9;
trial = 0;
pause = 0;
onset = 0;
firstgaze = 0;
numOps = 0;
order = [0 0 0];
positions = 0;
iti = noreciti;
timeofchoice = GetSecs - (feedbacktime + iti);
reactiontime = 0;
savecommand = ['save ' savename ' data'];
correct2 = 0;
possible2 = 0;
correct3 = 0;
possible3 = 0;
pcent2graph(1) = 0;
pcent3graph(1) = 0;
cancel = 0;
acount = -1;
bcount = -1;
ccount = -1;
dcount = -1;
starttime = GetSecs;

while(continuing)
    % Set Screen*****************
    if(step == 7)
        if(fixating == 1)
            Screen('FillRect', window, fixcuecolor, [(x1min-fixbox) (y1min-fixbox) (x1max+fixbox) (y1max+fixbox)]);
        elseif(fixating == 2)
            Screen('FillRect', window, fixcuecolor, [(x2min-fixbox) (y2min-fixbox) (x2max+fixbox) (y2max+fixbox)]);
        elseif(fixating == 3)
            Screen('FillRect', window, fixcuecolor, [(x3min-fixbox) (y3min-fixbox) (x3max+fixbox) (y3max+fixbox)]);
        end
    end
    if(step == 6)
        if(dispwind == 1)
            Screen('FillRect', window, [0 255 0], [(Fxmin) (Fymin) (Fxmax) (Fymax)]);
            Screen('FillRect', window, [0 0 0], [(Fxmin+5) (Fymin+5) (Fxmax-5) ((Fymax)-5)]);
        end
        Screen('FillOval', window, maincolor, [(targX-radius) ((targY-radius)) (targX+radius) ((targY+radius))]);
    end
    if(step == 7 || (order(1) == 1 && step == 1) || (order(2) == 1 && step == 3) || (order(3) == 1 && step == 5))
        if(notBlueOps(1) == 1)
            createGamble(gambleLeft, x1min, x1max, y1min, y1max, 1, 0);
        elseif(notBlueOps(1) == 2)
            createGamble(1, x1min, x1max, y1min, y1max, 0, 1);
        else
            createGamble(gambleLeft, x1min, x1max, y1min, y1max, 0, 0);
        end
    end
    if(step == 7 || (order(1) == 2 && step == 1) || (order(2) == 2 && step == 3) || (order(3) == 2 && step == 5))
        if(notBlueOps(2) == 1)
            createGamble(gambleRight, x2min, x2max, y2min, y2max, 1, 0);
        elseif(notBlueOps(2) == 2)
            createGamble(1, x2min, x2max, y2min, y2max, 0, 1);
        else
            createGamble(gambleRight, x2min, x2max, y2min, y2max, 0, 0);
        end
    end
    if(numOps == 3 && (step == 7 || (order(1) == 3 && step == 1) || (order(2) == 3 && step == 3) || (order(3) == 3 && step == 5)))
        if(notBlueOps(3) == 1)
            createGamble(gambleCent, x3min, x3max, y3min, y3max, 1, 0);
        elseif(notBlueOps(3) == 2)
            createGamble(1, x3min, x3max, y3min, y3max, 0, 1);
        else
            createGamble(gambleCent, x3min, x3max, y3min, y3max, 0, 0);
        end
    end
    if(step == 8)
        if(choice == 1)
            Screen('FillRect', window, fixcuecolor, [(x1min-fixbox) (y1min-fixbox) (x1max+fixbox) (y1max+fixbox)]);
            if(gambleoutcome == 0)
                Screen('FillRect', window, medcolor, [x1min y1min x1max y1max]);
            elseif(gambleoutcome == 2)
                if(notBlueOps(1) == 1)
                    Screen('FillRect', window, hugecolor, [x1min y1min x1max y1max]);
               	else
                    Screen('FillRect', window, largecolor, [x1min y1min x1max y1max]);
                end
                Screen('FillOval', window, feedbackcolor, [(mean([x1max x1min])-25) (mean([y1max y1min])-25) (mean([x1max x1min])+25) (mean([y1max y1min])+25)]);
            elseif(gambleoutcome == 1)
                Screen('FillRect', window, smallcolor, [x1min y1min x1max y1max]);
            end
        elseif(choice == 2)
            Screen('FillRect', window, fixcuecolor, [(x2min-fixbox) (y2min-fixbox) (x2max+fixbox) (y2max+fixbox)]);
            if(gambleoutcome == 0)
                Screen('FillRect', window, medcolor, [x2min y2min x2max y2max]);
            elseif(gambleoutcome == 2)
                if(notBlueOps(2) == 1)
                    Screen('FillRect', window, hugecolor, [x2min y2min x2max y2max]);
                else
                    Screen('FillRect', window, largecolor, [x2min y2min x2max y2max]);
                end
                Screen('FillOval', window, feedbackcolor, [(mean([x2max x2min])-25) (mean([y2max y2min])-25) (mean([x2max x2min])+25) (mean([y2max y2min])+25)]);
            elseif(gambleoutcome == 1)
                Screen('FillRect', window, smallcolor, [x2min y2min x2max y2max]);
            end
        elseif(choice == 3)
            Screen('FillRect', window, fixcuecolor, [(x3min-fixbox) (y3min-fixbox) (x3max+fixbox) (y3max+fixbox)]);
            if(gambleoutcome == 0)
                Screen('FillRect', window, medcolor, [x3min y3min x3max y3max]);
            elseif(gambleoutcome == 2)
                if(notBlueOps(3) == 1)
                    Screen('FillRect', window, hugecolor, [x3min y3min x3max y3max]);
                else
                    Screen('FillRect', window, largecolor, [x3min y3min x3max y3max]);
                end
                Screen('FillOval', window, feedbackcolor, [(mean([x3max x3min])-25) (mean([y3max y3min])-25) (mean([x3max x3min])+25) (mean([y3max y3min])+25)]);
            elseif(gambleoutcome == 1)
                Screen('FillRect', window, smallcolor, [x3min y3min x3max y3max]);
            end
        end
    end
    Screen(window,'flip');
    if((step == 1) && (onset == 1)), toplexon(4001);end %1st op appears
    if((step == 2) && (onset == 1)), toplexon(4002);end %1st op disappears
    if((step == 3) && (onset == 1)), toplexon(4003);end %2nd op appears
    if((step == 4) && (onset == 1)), toplexon(4004);end %2nd op disappears
    if((step == 5) && (onset == 1)), toplexon(4005);end %3rd op appears
    if((step == 6) && (onset == 1)), toplexon(4006);end %3rd op disappears / fixation dot appears
    if((step == 7) && (onset == 1)), toplexon(4007);end %Go signal
    if((step == 8) && (onset == 1)), toplexon(4008);end %Feedback appears
    if((step == 9) && (onset == 1) && (cancel == 0))
        toplexon(4009); %Feedback disappears
        ITIdatatime = GetSecs;
        %-----ITI Data-----
        toplexon(trial);                                                 % 1) Trial #
        toplexon(numOps);                                                % 2) # of options
        toplexon(uint64(gambleLeft*100));                                % 3) Gamble % for left
        toplexon(uint64(gambleRight*100));                               % 4) Gamble % for right
        toplexon(uint64(gambleCent*100));                                % 5) Gamble % for center
        toplexon((order(1)*100)+(order(2)*10)+order(3));                 % 6) Order of presentation 1:Left 2:Right 3:Center
        toplexon((notBlueOps(1)*100)+(notBlueOps(2)*10)+notBlueOps(3));  % 7) Color of rectangles 0:Blue 1:Green 2:Safe
        toplexon(choice);                                                % 8) Choice 1:Left 2:Right 3:Center
        toplexon(gambleoutcome);                                         % 9) Gamble outcome 0:Safe 1:Lose 2:Win
        toplexon(uint64(rewardmin*1000));                                %10) Small reward size in ms
        toplexon(uint64(rewardmed*1000));                                %11) Safe reward size in ms
        toplexon(uint64(rewardlarge*1000));                              %12) Large reward size in ms
        toplexon(uint64(rewardhuge*1000));                               %13) Huge reward size in ms
        toplexon(uint64(chance3op*100));                                 %14) Chance that a given trial has 3ops
        toplexon(uint64(chanceSafe*100));                                %15) Chance that a given rect is safe
        toplexon(uint64(chanceHuge*100));                                %16) Chance that a given rect is huge
        toplexon(positions);                                             %17) 3op rect positions 1:TL 2:BL 3:BR 4:TR
        %Save data to .m file
        data(trial).choice = choice;
        data(trial).numOps = numOps; 
        data(trial).left = gambleLeft; 
        data(trial).right = gambleRight;
        data(trial).center = gambleCent;
        data(trial).order = order;
        data(trial).EVleft = EVleft; 
        data(trial).EVright = EVright;
        data(trial).EVcenter = EVcenter;
        data(trial).notBlueOps = notBlueOps;
        data(trial).gambleoutcome = gambleoutcome;
        data(trial).rewardmin = rewardmin;
        data(trial).rewardmed = rewardmed;
        data(trial).rewardlarge = rewardlarge;
        data(trial).rewardhuge = rewardhuge;
        data(trial).reactiontime = (reactiontime - timeofchoice);
        data(trial).positions = positions;
        eval(savecommand);
        %disp(sprintf('Data send: %3.4fs', (GetSecs-ITIdatatime)));
    end 
    onset = 0;
    
    % Check eye position*****************
    e = Eyelink('newestfloatsample');
    if(firstgaze == 0)
        if((order(1) == 1 && step == 1) || (order(2) == 1 && step == 3) || (order(3) == 1 && step == 5))
            if(((x1min < e.gx(1)) && (e.gx(1) < x1max)) && ((y1min < e.gy(1)) && (e.gy(1) < y1max)))
                toplexon(4051); %First look at option #1
                firstgaze = 1;
            end
        elseif((order(1) == 2 && step == 1) || (order(2) == 2 && step == 3) || (order(3) == 2 && step == 5))
            if(((x2min < e.gx(1)) && (e.gx(1) < x2max)) && ((y2min < e.gy(1)) && (e.gy(1) < y2max)))
                toplexon(4052); %First look at option #2
                firstgaze = 1;
            end
        elseif(numOps == 3 && ((order(1) == 3 && step == 1) || (order(2) == 3 && step == 3) || (order(3) == 3 && step == 5)))
            if(((x3min < e.gx(1)) && (e.gx(1) < x3max)) && ((y3min < e.gy(1)) && (e.gy(1) < y3max)))
                toplexon(4053); %First look at option #3
                firstgaze = 1;
            end
        end
    end
    if(step == 6)
        if(((Fxmin < e.gx(1)) && (e.gx(1) < Fxmax)) && (((Fymin) < e.gy(1)) && (e.gy(1) < (Fymax)))) %Gaze is in box around fixation dot
            if(fixating == 0)
                toplexon(4061); %Fixation acquired
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) 
                reactiontime = GetSecs;
                step = 7;
                onset = 1; 
                fixating = 0;
            end
        elseif(fixating == 1)
            toplexon(4062); %Fixation lost
            fixating = 0;
        end
    elseif(step == 7)
        if(((x1min-wr < e.gx(1)) && (e.gx(1) < x1max+wr)) && ((y1min-wr < e.gy(1)) && (e.gy(1) < y1max+wr))) %Gaze is in box around LEFT
            if(fixating == 0)
                toplexon(4071); %Left op fixation acquired
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixminbox + fixtime))) 
                timeofchoice = GetSecs;
                if(notBlueOps(1) == 2)
                    reward(rewardmed);
                    gambleoutcome = 0;
                elseif(rand <= gambleLeft)
                    gambleoutcome = 2;
                    if(notBlueOps(1) == 1)
                        reward(rewardhuge);
                    else
                        reward(rewardlarge);
                    end
                else
                    reward(rewardmin);
                    gambleoutcome = 1;
                end
                choice = 1;
            end
        elseif(fixating == 1)
            toplexon(4072); %Left op fixation lost
            fixating = 0;
        end
        if(((x2min-wr < e.gx(1)) && (e.gx(1) < x2max+wr)) && ((y2min-wr < e.gy(1)) && (e.gy(1) < y2max+wr))) %Gaze is in box around RIGHT
            if(fixating == 0)
                toplexon(4073); %Right op fixation acquired
                fixtime = GetSecs;
                fixating = 2;
            elseif((fixating == 2) && (GetSecs > (fixminbox + fixtime))) 
                timeofchoice = GetSecs;
                if(notBlueOps(2) == 2)
                    reward(rewardmed);
                    gambleoutcome = 0;
                elseif(rand <= gambleRight)
                    gambleoutcome = 2;
                    if(notBlueOps(2) == 1)
                        reward(rewardhuge);
                    else
                        reward(rewardlarge);
                    end
                else
                    reward(rewardmin);
                    gambleoutcome = 1;
                end
                choice = 2;
            end
        elseif(fixating == 2)
            toplexon(4074); %Right op fixation lost
            fixating = 0;
        end
        if(numOps == 3 && (((x3min-wr < e.gx(1)) && (e.gx(1) < x3max+wr)) && ((y3min-wr < e.gy(1)) && (e.gy(1) < y3max+wr)))) %Gaze is in box around CENTER
            if(fixating == 0)
                toplexon(4075); %Center op fixation acquired
                fixtime = GetSecs;
                fixating = 3;
            elseif((fixating == 3) && (GetSecs > (fixminbox + fixtime))) 
                timeofchoice = GetSecs;
                if(notBlueOps(3) == 2)
                    reward(rewardmed);
                    gambleoutcome = 0;
                elseif(rand <= gambleCent)
                    gambleoutcome = 2;
                    if(notBlueOps(3) == 1)
                        reward(rewardhuge);
                    else
                        reward(rewardlarge);
                    end
                else
                    reward(rewardmin);
                    gambleoutcome = 1;
                end
                choice = 3;
            end
        elseif(fixating == 3)
            toplexon(4076); %Center op fixation lost
            fixating = 0;
        end
    end
    
    % Watch for keyboard interaction*****************
    comm=keyCapture();
    if(comm==-1) % ESC stops the session
        continuing=0;
    end
    if(comm==1) % Space rewards monkey
        reward(rewardlarge);
    end
    if(comm==2) % Control pauses/unpauses
        if(pause == 0)
            pause = 1;
        else
            timeofchoice = GetSecs - (feedbacktime + iti);
            pause = 0;
        end
    end
    if(comm==3) % Left arrow cancels trial
        cancel = 1;
        timeofchoice = GetSecs - (feedbacktime + iti);
    end
    if(comm==4) % A starts/stops cell A trial count
        if(acount == -1)
            acount = 1;
        else
            acount = -1;
        end
    end
    if(comm==5) % B starts/stops cell B trial count
        if(bcount == -1)
            bcount = 1;
        else
            bcount = -1;
        end
    end
    if(comm==6) % C starts/stops cell C trial count
        if(ccount == -1)
            ccount = 1;
        else
            ccount = -1;
        end
    end
    if(comm==7) % D starts/stops cell D trial count
        if(dcount == -1)
            dcount = 1;
        else
            dcount = -1;
        end
    end
    comm = 0;
    
    % Progress between steps*****************
    if((step == 1 && GetSecs > (timeofchoice + feedbacktime + iti + recttime + xtratime)))
        step = 2;
        onset = 1;
        firstgaze = 0;
    elseif((step == 2 && GetSecs > (timeofchoice + feedbacktime + iti + recttime + btwnrecttime)))
        step = 3;
        onset = 1;
    elseif((step == 3 && GetSecs > (timeofchoice + feedbacktime + iti + recttime + btwnrecttime + recttime + (2*xtratime))))
        step = 4;
        if(numOps == 2)
            step = 6;
        end
        onset = 1;
        firstgaze = 0;
    elseif((step == 4 && GetSecs > (timeofchoice + feedbacktime + iti + recttime + btwnrecttime + recttime + btwnrecttime)))
        step = 5;
        onset = 1;
    elseif((step == 5 && GetSecs > (timeofchoice + feedbacktime + iti + recttime + btwnrecttime + recttime + btwnrecttime + recttime + (3*xtratime))))
        step = 6;
        onset = 1;
        firstgaze = 0;
    elseif(step == 7 && choice ~= 0)
        step = 8;
        onset = 1;
        fixating = 0;
        
        %Calculate EV of each option
        if(notBlueOps(1) == 2)
            EVleft = rewardmed;
        elseif(notBlueOps(1) == 1)
            EVleft = gambleLeft * rewardhuge;
        else
            EVleft = gambleLeft * rewardlarge;
        end
        if(notBlueOps(2) == 2)
            EVright = rewardmed;
        elseif(notBlueOps(2) == 1)
            EVright = gambleRight * rewardhuge;
        else
            EVright = gambleRight * rewardlarge;
        end
        if(numOps == 2)
            EVcenter = -1;
        elseif(notBlueOps(3) == 2)
            EVcenter = rewardmed;
        elseif(notBlueOps(3) == 1)
            EVcenter = gambleCent * rewardhuge;
        else
            EVcenter = gambleCent * rewardlarge;
        end
        
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
        if(numOps == 3)
            possible3 = possible3 + 1;
        else
            possible2 = possible2 + 1;
        end
        if(numOps == 3 && ((((EVleft >= EVright) && (EVleft >= EVcenter)) && (choice == 1)) || (((EVright >= EVleft) && (EVright >= EVcenter)) && (choice == 2)) || (((EVcenter >= EVleft) && (EVcenter >= EVright)) && (choice == 3)))) 
            correct3 = correct3 + 1;
        elseif(numOps == 2 && (((EVleft >= EVright) && (choice == 1)) || ((EVleft <= EVright) && (choice == 2))))
            correct2 = correct2 + 1;
        end
        if(possible2 > 0)
            disp(sprintf('Correct 2Ops: %3.2f%%', (100*correct2/possible2)));
        end
        if(possible3 > 0)
            disp(sprintf('Correct 3Ops: %3.2f%%', (100*correct3/possible3)));
        end
        pcent2graph(trial) = (100*correct2/possible2);
        pcent3graph(trial) = (100*correct3/possible3);
        if(acount ~= -1)
            disp(sprintf('Cell A: %.0f', acount));
            acount = acount + 1;
        end
        if(bcount ~= -1)
            disp(sprintf('Cell B: %.0f', bcount));
            bcount = bcount + 1;
        end
        if(ccount ~= -1)
            disp(sprintf('Cell C: %.0f', ccount));
            ccount = ccount + 1;
        end
        if(dcount ~= -1)
            disp(sprintf('Cell D: %.0f', dcount));
            dcount = dcount + 1;
        end
        if(acount==-1 && bcount==-1 && ccount==-1 && dcount==-1)
            iti = noreciti;
        else
            iti = reciti;
        end
        
    elseif((step == 8 && GetSecs > (timeofchoice + feedbacktime)) || cancel == 1)
        step = 9;
        onset = 1;
    elseif(((step == 9 && GetSecs > (timeofchoice + feedbacktime + iti)) && (pause == 0)) || (step == 9 && cancel == 1))
        cancel = 0;
        gambleoutcome = 0;
        choice = 0;
        trial = trial + 1;
        if(rand <= chance3op)
            numOps = 3;
            xtratime = xtra3optime;
            order = randperm(3);
            empty = randperm(4);
            if(empty(1) == 1)
                x1min = L3xmin; x1max = L3xmax; y1min = B3ymin; y1max = B3ymax;
                x2min = R3xmin; x2max = R3xmax; y2min = B3ymin; y2max = B3ymax;
                x3min = R3xmin; x3max = R3xmax; y3min = T3ymin; y3max = T3ymax;
                positions = 234;
            elseif(empty(1) == 2)
                x1min = L3xmin; x1max = L3xmax; y1min = T3ymin; y1max = T3ymax;
                x2min = R3xmin; x2max = R3xmax; y2min = B3ymin; y2max = B3ymax;
                x3min = R3xmin; x3max = R3xmax; y3min = T3ymin; y3max = T3ymax;
                positions = 134;
            elseif(empty(1) == 3)
                x1min = L3xmin; x1max = L3xmax; y1min = T3ymin; y1max = T3ymax;
                x2min = L3xmin; x2max = L3xmax; y2min = B3ymin; y2max = B3ymax;
                x3min = R3xmin; x3max = R3xmax; y3min = T3ymin; y3max = T3ymax;
                positions = 124;
            elseif(empty(1) == 4)
                x1min = L3xmin; x1max = L3xmax; y1min = T3ymin; y1max = T3ymax;
                x2min = L3xmin; x2max = L3xmax; y2min = B3ymin; y2max = B3ymax;
                x3min = R3xmin; x3max = R3xmax; y3min = B3ymin; y3max = B3ymax;
                positions = 123;
            end
        else
            numOps = 2;
            xtratime = 0;
            order = [randperm(2) 3];
            x1min = Lxmin; x1max = Lxmax; y1min = Lymin; y1max = Lymax;
            x2min = Rxmin; x2max = Rxmax; y2min = Rymin; y2max = Rymax;
        end
        gambleLeft = rand;
        gambleRight = rand;
        gambleCent = rand;
        notBlueOps = [0 0 0];
        if(rand <= chanceHuge), notBlueOps(1) = 1;end %L
        if(rand <= chanceHuge), notBlueOps(2) = 1;end %R
        if(rand <= chanceHuge), notBlueOps(3) = 1;end %C
        if(rand <= chanceSafe), notBlueOps(1) = 2;end %L
        if(rand <= chanceSafe), notBlueOps(2) = 2;end %R
        if(rand <= chanceSafe), notBlueOps(3) = 2;end %C
        step = 1;
        onset = 1;
    end
end
if(length(pcent2graph) > 1 && length(pcent3graph) > 1)
    hold on;
    plot(pcent2graph);
    plot(pcent3graph);
    hold off;
end
Eyelink('stoprecording');
sca;
%keyboard
end

function f = createGamble(pcentNotRed, xmin, xmax, ymin, ymax, isHuge, isSafe)
global hugecolor; global largecolor; global medcolor; global smallcolor; global window; global height;
Screen('FillRect', window, smallcolor, [xmin ymin xmax ymax]);
if(isHuge == 1)
    Screen('FillRect', window, hugecolor, [xmin ymin xmax (ymin + (pcentNotRed * height))]);
elseif(isSafe == 1)
    Screen('FillRect', window, medcolor, [xmin ymin xmax (ymin + (pcentNotRed * height))]);
else
    Screen('FillRect', window, largecolor, [xmin ymin xmax (ymin + (pcentNotRed * height))]);
end
end

function a = keyCapture()
stopkey=KbName('ESCAPE');
pause=KbName('RightControl');
reward=KbName('space');
cancel=KbName('LeftArrow');
acount=KbName('a');
bcount=KbName('b');
ccount=KbName('c');
dcount=KbName('d');
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(stopkey)
    a = -1;
elseif keyCode(reward)
    a = 1; 
elseif keyCode(pause)
    a = 2;
elseif keyCode(cancel)
    a = 3;
elseif keyCode(acount)
    a = 4;
elseif keyCode(bcount)
    a = 5;
elseif keyCode(ccount)
    a = 6;
elseif keyCode(dcount)
    a = 7;
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