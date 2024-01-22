function processclimatefactor(input1)
addpath(genpath([pwd filesep 'yalmip']));
addpath(genpath([pwd filesep 'matpower']));
% totalscenario = 1:159;
% subscenario = [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94];
% scenariolist = setxor(totalscenario,subscenario);
for year = input1+1997
    for scenario = 1:159
%     for scenario = [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]
        windspeed = readmatrix('Data/WindSpeed/WindSpeed'+string(year)+'.csv');
        solarrad = readmatrix('Data/SolarRad/SolarRad'+string(year)+'.csv');
        temp = readmatrix('Data/Temperature/Temp'+string(year)+'.csv');
        tempchange = readtable('Load/temperature.changes.csv');
        deltat = tempchange(tempchange.scenario==scenario,:).temperature_change_deg_C;
        Zonelist = ['A','B','C','D','E','F','G','H','I','J','K'];
    %     for i = 1:length(Zonelist)
    %         temp{i} = importdata('Data/ZonalTemp_dstfixed_2020/temp_zone'+string(Zonelist(i))+'_'+string(year)+'.txt');
    %         temp{i} = temp{i}.data+deltat;
    %     end
        temp(:,3:end) = temp(:,3:end)+deltat;
        Cablemodel = readtable('Data/Cablemodel.csv');
        Voltage = [500,345,230,115,69];
        normwindv = 0.61;
        normtemp = 25;
        normdelta = 1000;
        Vlist = [500,345,230,115,69];
        normrate = [];
        for i = 1:length(Vlist)
            model = Cablemodel{find(Cablemodel{:,'V'} == Voltage(i)),:};
            D = model(2)/100;
            R25 = model(3)/1000;
            R50 = model(4)/1000;
            R75 = model(5)/1000;
            N = model(6);
            Cap(i) = dynamicrating(Vlist(i),D,R25,R50,R75,N,normtemp,...
                normdelta,normwindv);
            normrate = [normrate,Cap(i)];
        end
        load('Data/mpc2050.mat')
        businfo = readtable('Data/npcc_new.csv');
        branch = mpcreduced.branch;
        bus = mpcreduced.bus;
        busind = mpcreduced.bus(:,1);
        busreduced = businfo(busind,:);
        for i = 1:length(mpcreduced.branch(:,1))
            xcoordf(i) = busreduced{busreduced.idx == mpcreduced.branch(i,1),'xcoord'};
            ycoordf(i) = busreduced{busreduced.idx == mpcreduced.branch(i,1),'ycoord'};
        end
        
        for i = 1:length(mpcreduced.branch(:,1))
            xcoord2t(i) = busreduced{busreduced.idx == mpcreduced.branch(i,2),'xcoord'};
            ycoord2t(i) = busreduced{busreduced.idx == mpcreduced.branch(i,2),'ycoord'};
        end
        branchf = [xcoordf',ycoordf'];
        brancht = [xcoord2t',ycoord2t'];
        windcoord = windspeed(:,1:2);
        solarcoord = solarrad(:,1:2);
        tempcoord = temp(:,1:2);
        windcoord([41,52,63,78],:)=[];
        tempcoord([41,52,63,78],:)=[];
        windv = windspeed(:,3:end);
        windv([41,52,63,78],:)=[];
        solar = solarrad(:,3:end);
        tp = temp(:,3:end);
        tp([41,52,63,78],:)=[];
        % windcoord = table2array(windcoord);
        % solarcoord = table2array(solarcoord);
        Voltage = [];
        for i = 1:length(branch)
            V1 = bus(find(bus(:,1) == branch(i,1)),10);
            V2 = bus(find(bus(:,1) == branch(i,2)),10);
            Voltage = [Voltage;max(V1,V2)];
        end
        
        A = [54 55 56 57 58 59 60 61];
        B = [62 52 53];
        C = [50 51 63 64 65 66 67 68 70 71 72];
        D = [48 49];
        E = [69 38 43 44 45 46 47];
        F = [37 40 41 42];
        G = [39 73 75 76 77];
        H = [74];
        I = 78;
        J = [82 81];
        K = [79 80];
        
        bus2zone{1} = A;
        bus2zone{2} = B;
        bus2zone{3} = C;
        bus2zone{4} = D;
        bus2zone{5} = E;
        bus2zone{6} = F;
        bus2zone{7} = G;
        bus2zone{8} = H;
        bus2zone{9} = I;
        bus2zone{10} = J;
        bus2zone{11} = K;
        br2temp = zeros(length(branch),2);
        for i = 1:length(branch)
            for j = 1:11
                if any(bus2zone{j} == branch(i,1))
                    br2temp(i,1) = j;
                end
                if any(bus2zone{j} == branch(i,2))
                    br2temp(i,2) = j;
                end
            end
        end
        brtemp = zeros(94,8760);
        brwindv = zeros(94,8760);
        brsolar = zeros(94,8760);
        dyrate = zeros(94,8760);
        ndyrate = zeros(94,8760);
        
        
        
        
        for t = 1:8760
            for b = 1:length(branch)
                [wv,ind] = findwindv(branchf(i,:),brancht(i,:),windcoord);
                temp3 = tp(ind,t);
                wind3 = windv(ind,t);
                solar3 = solar(ind,t);
                    
    %             if br2temp(b,1) && br2temp(b,2)
    %                 brtemp(b,t) = max(temp{br2temp(b,1)}(t),temp{br2temp(b,2)}(t));
    %                 [wv,indwv] = findwindv(branchf(i,:),brancht(i,:),windcoord);
    %                 [sr,indsr] = findsolar(branchf(i,:),brancht(i,:),solarcoord);
    %                 brwindv(b,t) = min(windv(indwv,t));
    %                 brsolar(b,t) = max(solar(indsr,t));
    %             elseif br2temp(b,1)
    %                 brtemp(b,t) = temp{br2temp(b,1)}(t);
    %                 [wv,indwv] = findwindv(branchf(i,:),brancht(i,:),windcoord);
    %                 [sr,indsr] = findsolar(branchf(i,:),brancht(i,:),solarcoord);
    %                 brwindv(b,t) = min(windv(indwv,t));
    %                 brsolar(b,t) = max(solar(indsr,t));
    %             elseif br2temp(b,2)
    %                 brtemp(b,t) = temp{br2temp(b,2)}(t);
    %                 [wv,indwv] = findwindv(branchf(i,:),brancht(i,:),windcoord);
    %                 [sr,indsr] = findsolar(branchf(i,:),brancht(i,:),solarcoord);
    %                 brwindv(b,t) = min(windv(indwv,t));
    %                 brsolar(b,t) = max(solar(indsr,t));
    %             else
    %                 brtemp(b,t)=25;
    %                 [wv,indwv] = findwindv(branchf(i,:),brancht(i,:),windcoord);
    %                 [sr,indsr] = findsolar(branchf(i,:),brancht(i,:),solarcoord);
    %                 brwindv(b,t) = min(windv(indwv,t));
    %                 brsolar(b,t) = max(solar(indsr,t));
    %             end
            
            
            if Voltage(b) == 220
                Voltage(b) = 230;
            end
            model = Cablemodel{find(Cablemodel{:,'V'} == Voltage(b)),:};
            D = model(2)/100;
            R25 = model(3)/1000;
            R50 = model(4)/1000;
            R75 = model(5)/1000;
            N = model(6);
            dyrate1 = dynamicrating(Voltage(b),D,R25,R50,R75,N,temp3(1),solar3(1),wind3(1)/3.6066);
            dyrate2 = dynamicrating(Voltage(b),D,R25,R50,R75,N,temp3(2),solar3(2),wind3(2)/3.6066);
            dyrate3 = dynamicrating(Voltage(b),D,R25,R50,R75,N,temp3(3),solar3(3),wind3(3)/3.6066);
    %         dyrate(b,t) = dynamicrating(Voltage(b),D,R25,R50,R75,N,brtemp(b,t),brsolar(b,t),brwindv(b,t)/3.6066);
            dyrate(b,t) = min([dyrate1,dyrate2,dyrate3]);
            ndyrate(b,t) = normrate(find(Cablemodel{:,'V'} == Voltage(b)));
            end
        end
        ifdyrate = zeros(15,8760);
        ifndyrate = zeros(15,8760);
        for i = 1:15
            idx = mpcreduced.if.map(mpcreduced.if.map(:,1)==i,2);
            ifdyrate(i,:) = sum(dyrate(abs(idx),:),1);
            ifndyrate(i,:) = sum(ndyrate(abs(idx),:),1);
        end
        ratio = ifdyrate./ifndyrate;
        ratio = min(ratio,1);
        Lup = [2200;1500;5650;2650;3925;2300;5400;7375;8450;4350;1293;5650;1300;1650;500];
        Ldn = [-9999;-9999;-9999;-1100;-9999;-1600;-5400;-9999;-8450;-9999;-515;-3400;-1700;-2000;-900];
        Lup = repmat(Lup,1,8760);
        iflimdyup = ratio.*Lup;
        Ldn = repmat(Ldn,1,8760);
        iflimdydn = ratio.*Ldn;
        writematrix(iflimdyup,'Data/iflim/iflimup_'+string(year)+'_'+string(scenario)+'.csv')
        writematrix(iflimdydn,'Data/iflim/iflimdn_'+string(year)+'_'+string(scenario)+'.csv')

    end
end
end
% avgtemp = sum(brtemp(1:75,:),1);

function distance = GetPointLineDistance(x3,y3,x1,y1,x2,y2)
try
	
	% Find the numerator for our point-to-line distance formula.
	numerator = abs((x2 - x1) * (y1 - y3) - (x1 - x3) * (y2 - y1));
	
	% Find the denominator for our point-to-line distance formula.
	denominator = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
	
	% Compute the distance.
	distance = numerator ./ denominator;
catch ME
	callStackString = GetCallStack(ME);
	errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s',...
		mfilename, callStackString, ME.message);
	uiwait(warndlg(errorMessage))
end
return; % from GetPointLineDistance()
end
function [wv,indwv] = findwindv(fb,tb,windcoord)
    dist = [];
    for ind = 1:length(windcoord)
        point = windcoord(ind,:);
        disti = GetPointLineDistance(point(1),point(2),fb(1),fb(2),tb(1),tb(2));
        dist = [dist;disti];
    end
    [wv,indwv] = mink(dist,3);
end    

function [sr,indsr] = findsolar(fb,tb,solarcoord)
    dist = [];
    for ind = 1:length(solarcoord)
        point = solarcoord(ind,:);
        disti = GetPointLineDistance(point(1),point(2),fb(1),fb(2),tb(1),tb(2));
        dist = [dist;disti];
    end
    [sr,indsr] = mink(dist,3);
end 
