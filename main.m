 %%
% clear all
% close all
% function main(s1,bd_rateAE,bd_rateFI,bd_rateJK,ev_rateAE,ev_rateFI,ev_rateJK,wind_cap,solar_cap,batt_cap,lhsce)
function main(s1,bd_rateAE,ev_rateAE,wind_cap,solar_cap,batt_cap,lhsce)
addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
addpath(genpath([pwd filesep 'yalmip']));
addpath(genpath([pwd filesep 'matpower']));
scenario = s1;
scenario2 = 1;
% set time horizon
battduration = 8;

lhscenario = lhsce;

for year = 1998:2019
    newHVDC = 1;
    HydroCon = 1;
    tranRating = 1;
    networkcon = 1;
%     newload = readmatrix('Load/AllSimload/Scenario'+string(scenario)+'/simload_'+string(year)+'.csv');
    newload = readmatrix('Load/AllBaseload/Scenario'+string(scenario)+'/simload_'+string(year)+'.csv');
    iflimup = readmatrix('Data/iflim/iflimup_'+string(year)+'_'+string(scenario)+'.csv');
%     iflimup(9,:) = iflimup(9,:)/8750*8450;
    iflimdn = readmatrix('Data/iflim/iflimdn_'+string(year)+'_'+string(scenario)+'.csv');
    Naghydro = readtable('Data/hydrodata/nypaNiagaraEnergy.climate.change.csv');
    Mshydro = readtable('Data/hydrodata/nypaMosesSaundersEnergy.climate.change.csv');
    if scenario ~=0
        colname1 = 'nypaNiagaraEnergy_'+string(scenario);
        colname2 = 'nypaMosesSaundersEnergy_'+string(scenario);
    else
        colname1 = 'nypaNiagaraEnergy';
        colname2 = 'nypaMosesSaundersEnergy';
    end
    nyhy = Naghydro(Naghydro.Year == year,colname1);
    nyhy = table2array(nyhy);
    mshy = Mshydro(Mshydro.Year == year,colname2);
    mshy = table2array(mshy);
    EVload = readmatrix('Load/EVload/EVload_Bus.csv');
    EVloadbusid = EVload(:,1);
    
    ResLoad = readmatrix('Load/ResLoad/Scenario'+string(scenario)+'/ResLoad_Bus_'+string(year)+'.csv');
    ComLoad = readmatrix('Load/ComLoad/Scenario'+string(scenario)+'/ComLoad_Bus_'+string(year)+'.csv');
    
    genresult = [];
    flowresult = [];
    ifsumresult = [];
    chargeresult = [];
    dischargeresult = [];
    curtailwind = [];
    curtailsolar = [];
    curtailhydro = [];
    lmpresult = [];
    loadshedresult=[];
    battstateresult = [];
    curtailresult = [];
    for daytime = 0
        constraints = [];
        nt=365*24; % time horizon
        starttime = 1+daytime*nt;
        load('Data/mpc2050.mat')
        nogen = length(mpcreduced.gen);
        SolarUPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'/solarUPV'+string(year)+'.csv');
        SolarDPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'/solarDPV'+string(year)+'.csv');
        Wind = readmatrix('RenewableGen/Wind/WindFinal/Wind'+string(year)+'.csv');
        SolarUPV = round(SolarUPV,2);
        SolarDPV = round(SolarDPV,2);
        Wind = round(Wind,2);
        SolarUPVbus = SolarUPV(:,1);
        SolarDPVbus = SolarDPV(:,1);
        SolarUPV = SolarUPV(:,starttime+1:starttime+nt)*solar_cap;
        SolarDPV = SolarDPV(:,starttime+1:starttime+nt)*solar_cap;
        Windbus = Wind(:,1);
        Wind = Wind(:,starttime+1:starttime+nt)*wind_cap;
    
        %Add wind generators and change the upper bounds for each hour
        windgen = zeros(length(Windbus),21);
        windgen(:,1) = Windbus;
        windgen(:,4) = 9999;
        windgen(:,5) = -9999;
        windgen(:,6) = 1;
        windgen(:,7) = 100;
        windgen(:,8) = 1;
        windgen(:,17:19) = inf;
        mpcreduced.gen = [mpcreduced.gen;windgen];
    
        windcost = zeros(length(Windbus),6);
        windcost(:,1) = 2;
        windcost(:,4) = 2;
        mpcreduced.gencost = [mpcreduced.gencost;windcost];
        windtype = repmat(['Wind'],length(Windbus),1);
        mpcreduced.genfuel = [mpcreduced.genfuel;windtype];
    
        %Add Utility Solar generators and change the upper bounds for each hour
        solargen = zeros(length(SolarUPVbus),21);
        solargen(:,1) = SolarUPVbus;
        solargen(:,4) = 9999;
        solargen(:,5) = -9999;
        solargen(:,6) = 1;
        solargen(:,7) = 100;
        solargen(:,8) = 1;
        solargen(:,17:19) = inf;
        mpcreduced.gen = [mpcreduced.gen;solargen];
    
        solarcost = zeros(length(SolarUPVbus),6);
        solarcost(:,1) = 2;
        solarcost(:,4) = 2;
        mpcreduced.gencost = [mpcreduced.gencost;solarcost];
    
        solartype = repmat(['SolarUPV'],length(SolarUPVbus),1);
        mpcreduced.genfuel = [mpcreduced.genfuel;solartype];
    
        %convert mpcreduce to mpc
        mpc = ext2int(mpcreduced);
        % mpc.gen(end-7:end,10)=0;
        mpc.gen(end-7:end,9) = -mpc.gen(end-7:end,10);
      
        cleanpath1 = [36,0,0,100,-100,1,100,1,1300,-1300,zeros(1,11)];
        cleanpath2 = [48,0,0,100,-100,1,100,1,1300,-1300,zeros(1,11)];
        CHPexpress1 = [15,0,0,100,-100,1,100,1,1250,-1250,zeros(1,11)];
        CHPexpress2 = [48,0,0,100,-100,1,100,1,1250,-1250,zeros(1,11)];
        HQgen = [15,0,0,100,-100,1,100,1,1250,-1250,zeros(1,11)];
        mpc.gen = [mpc.gen;HQgen];
        mpc.gen =[mpc.gen;cleanpath1;cleanpath2;CHPexpress1;CHPexpress2];
        
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %take Kenji's load model to predict for each load zone with modified
    %temperature, decompose load to each bus with the factor in NYgrid model
        load('businfo.mat')
        loads = newload(:,starttime:starttime+nt-1);
        [ngen ~] = size(mpc.gen); 
        [nbus,~] = size(mpc.bus);
        [nbranch,~] = size(mpc.branch);
    
        %Add Btm Solar to Negative load
        for i = 1:length(SolarDPVbus)
            SolarDPVbus(i) = find(mpcreduced.bus(:,1) == SolarDPVbus(i));
        end
        loads(SolarDPVbus,:) = loads(SolarDPVbus,:) - SolarDPV;
    
      
        %Add small hydro as Negative load
        smallhydro = readtable('Data/hydrodata/SmallHydroCapacity.csv');
        smallhydrogen = readmatrix('Data/hydrodata/smallhydrogen.csv');
        smallhydrogen = smallhydrogen(:,starttime:starttime+nt-1);
        smallhydrobusid = smallhydro.busIndex;
        for i = 1:length(smallhydrobusid)
            smallhydrobusid(i) = find(mpcreduced.bus(:,1) == smallhydrobusid(i));
        end
        loads(smallhydrobusid,:) = loads(smallhydrobusid,:) - smallhydrogen;
    
        %Add EVload
        Buildingidx = ComLoad(:,1);
        for i = 1:length(EVloadbusid)
            EVloadbusid(i) = find(mpcreduced.bus(:,1) == EVloadbusid(i));
        end
        for i = 1:length(Buildingidx)
            Buildingidx(i) = find(mpcreduced.bus(:,1) == Buildingidx(i));
        end

        AEev = [];
        AEbd = [];
        FIev = [];
        FIbd = [];
        JKev = [];
        JKbd = [];
        for i = 1: length(AE)
            AEev =[AEev, find(EVloadbusid == AE(i))];
            AEbd =[AEbd, find(Buildingidx == AE(i))];
        end
        for i = 1: length(FI)
            FIev = [FIev, find(EVloadbusid == FI(i))];
            FIbd = [FIbd, find(Buildingidx == AE(i))];
        end
        for i = 1: length(JK)
            JKev = [JKev, find(EVloadbusid == JK(i))];
            JKbd = [JKbd, find(Buildingidx == AE(i))];
        end

        evload = EVload(:,starttime+1:starttime+nt);
        evload(AEev,:) = evload(AEev,:)*ev_rateAE;
        evload(FIev,:) = evload(FIev,:)*ev_rateAE;
        evload(JKev,:) = evload(JKev,:)*ev_rateAE;
        
        loads(EVloadbusid,:) = loads(EVloadbusid,:) + evload;
    
        %Add building load
        Buldingload = ComLoad(:,starttime+1:starttime+nt)+ResLoad(:,starttime+1:starttime+nt);
        
        Buldingload(AEbd,:) = Buldingload(AEbd,:)*bd_rateAE;
        Buldingload(FIbd,:) = Buldingload(FIbd,:)*bd_rateAE;
        Buldingload(JKbd,:) = Buldingload(JKbd,:)*bd_rateAE;
        
        
        loads(Buildingidx,:) = loads(Buildingidx,:) + Buldingload;
        % Add storage
    
        Storage = readmatrix('Data/StorageData/StorageAssignment.csv');
        Storagebus = Storage(:,1);
        for i = 1:length(Storagebus)
            Storagebus(i) = find(mpcreduced.bus(:,1) == Storagebus(i));
        end
    
        %read generator upper limits, fixed now, to be changed later for renewables
        Gmax = [];
        Gmin = [];
%         mpc.gen(5,9) = mpc.gen(5,9)*1.5;
        for i = 1:nogen % to be changed later
            Gmax = [Gmax;mpc.gen(i,9)*ones(1,nt)];
            Gmin = [Gmin;mpc.gen(i,10)*ones(1,nt)];
        end
       
        Gmax = [Gmax;Wind;SolarUPV];
        Gmin = [Gmin;zeros(size(Wind));zeros(size(SolarUPV))];
    
        for i = length(mpc.gen(:,9))-12:length(mpc.gen(:,9))
            Gmax = [Gmax;mpc.gen(i,9)*ones(1,nt)];
            Gmin = [Gmin;mpc.gen(i,10)*ones(1,nt)];
        end
    
    
        %% Set parameters
    
    
        % Rdn = mpc.gen(:,19)*ones(1,nt)*2;
        Rdn = max(mpc.gen(:,19)*ones(1,nt)*2,mpc.gen(:,9));
        Rup = Rdn;
        % Rup = mpc.gen(:,19)*ones(1,nt)*2;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% branchlim will change over time 
        branchlim = mpc.branch(:,6);
        branchlim(branchlim == 0) = inf;
        lineC = repmat(branchlim,1,nt);    
    
        % lineC = inf*lineC;
        %% Define variables
        pg=sdpvar(ngen,nt,'full');
        flow = sdpvar(nbranch,nt,'full');
        angle = sdpvar(nbus,nt,'full');
        charge = sdpvar(length(Storagebus),nt,'full');
        discharge = sdpvar(length(Storagebus),nt,'full');
        battstate = sdpvar(length(Storagebus),nt+1,'full');
        loadshedding = sdpvar(nbus,nt,'full');
        bincharge= binvar(length(Storagebus),nt,'full');
        bindischarge= binvar(length(Storagebus),nt,'full');
        curtailment = sdpvar(nbus,nt,'full');
        %% Define Constraints
        Constraints = [];
        NodeBalance = [];
    
        % branch limits and power flow 
        for l = 1:nbranch
            Constraints =[Constraints, - lineC(l,:)<=flow(l,:)<=lineC(l,:)];
            Constraints = [Constraints,flow(l,:)-100/mpc.branch(l,4)*(angle(mpc.branch(l,1),:)- angle(mpc.branch(l,2),:))==0]; 
        end    
    
        % Power balance and phase angle 
        for i=1:nbus
            if mpc.bus(i,2)~=3
                if ismember(i, Storagebus)
                    NodeBalance = [NodeBalance,loads(i,:) == -sum(flow(mpc.branch(:,1)==i,:),1)+sum(flow(mpc.branch(:,2)==i,:),1)+sum(pg(mpc.gen(:,1)==i,:),1)+sum(discharge(Storagebus==i,:),1)-sum(charge(Storagebus==i,:),1)+loadshedding(i,:)];
                    Constraints = [Constraints, -2*pi <= angle(i,:)<=2*pi];
                else
                    NodeBalance = [NodeBalance,loads(i,:) == -sum(flow(mpc.branch(:,1)==i,:),1)+sum(flow(mpc.branch(:,2)==i,:),1)+sum(pg(mpc.gen(:,1)==i,:),1)+sum(discharge(Storagebus==i,:),1)-sum(charge(Storagebus==i,:),1)+loadshedding(i,:)];
                    Constraints = [Constraints, -2*pi <= angle(i,:)<=2*pi];
                end
            else
                NodeBalance = [NodeBalance,loads(i,:) == -sum(flow(mpc.branch(:,1)==i,:),1)+sum(flow(mpc.branch(:,2)==i,:),1)+sum(pg(mpc.gen(:,1)==i,:),1)+sum(discharge(Storagebus==i,:),1)-sum(charge(Storagebus==i,:),1)+loadshedding(i,:)];
    %             NodeBalance = [NodeBalance,loads(i,:) == -sum(flow(mpc.branch(:,1)==i,:),1)+sum(flow(mpc.branch(:,2)==i,:),1)+sum(pg(mpc.gen(:,1)==i,:),1)+loadshedding(i,:)];    
                 Constraints = [Constraints, angle(i,:)==0.2979/180*pi];
            end
        end
        eff = 0.85;
        effGilboa = 0.75;
        Chargecap = repmat(Storage(:,2),1,nt)*batt_cap;
        storagecap = repmat(Storage(1:length(Storagebus)-1,2)*battduration,1,nt+1)*batt_cap;
        storagecap = [storagecap;repmat(Storage(length(Storagebus),2)*12,1,nt+1)*batt_cap];
        Constraints = [Constraints,0<=charge<=Chargecap];
        Constraints = [Constraints,0<=discharge<=Chargecap];
%         Constraints = [Constraints,0<=charge<=Chargecap.*bincharge];
%         Constraints = [Constraints,0<=discharge<=Chargecap.*bindischarge];
%         Constraints = [Constraints,bincharge + bindischarge==1];
        Constraints = [Constraints,battstate(1:length(Storagebus)-1,2:nt+1) == battstate(1:length(Storagebus)-1,1:nt) + sqrt(eff)*charge(1:length(Storagebus)-1,:) - 1/sqrt(eff)*discharge(1:length(Storagebus)-1,:)]; 
        Constraints = [Constraints,battstate(length(Storagebus),2:nt+1) == battstate(length(Storagebus),1:nt) + sqrt(effGilboa)*charge(length(Storagebus),:) - 1/sqrt(effGilboa)*discharge(length(Storagebus),:)];
        Constraints = [Constraints, 0.0*storagecap<=battstate<=storagecap];
    
    
        if daytime == 0
            Constraints = [Constraints,battstate(:,1)==0.3*storagecap(:,1)];
        else
    %         Constraints = [Constraints,battstate(:,1)==tempbattstate];
            Constraints = [Constraints,battstate(:,1)==initialbatt];
    %         Constraints = [Constraints,battstate(:,1)==0.8*storagecap(:,1)];
        end
    
        
        % Interface flow 
        ifmap = mpc.if.map;
    
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% mpc.if.lims should change with time
    %     iflimup(1:11,:) = iflimdy(:,starttime:starttime+nt-1);

        if tranRating
            if ~networkcon
                iflimdn(1:12,:) = -inf;
                iflimup(1:12,:) = inf;
            end
            for i = 1:15
                idx = ifmap(ifmap(:,1)==i,2);
                Constraints = [Constraints, iflimdn(i,starttime:starttime+nt-1) <= sum(repmat(sign(idx),1,nt).*flow(abs(idx),:),1) <= iflimup(i,starttime:starttime+nt-1)];
            end
        else
            iflimdn =  mpc.if.lims(:,2)*ones(1,nt); 
            iflimup =  mpc.if.lims(:,3)*ones(1,nt); 
            if ~networkcon
                iflimdn(1:12,:) = -inf;
                iflimup(1:12,:) = inf;
            end
            for i = 1:15
                
                idx = ifmap(ifmap(:,1)==i,2);
                Constraints = [Constraints, iflimdn(i,starttime:starttime+nt-1) <= sum(repmat(sign(idx),1,nt).*flow(abs(idx),:),1) <= iflimup(i,starttime:starttime+nt-1)];
            end
        end
    
    
    
        %nuclear always fully dispatch
        nuclearid = find(mpc.genfuel == 'Nuclear');
        Constraints = [Constraints,pg(nuclearid,:)== Gmax(nuclearid,:)];
        
        if HydroCon 
            dayofqm = readtable('Data/qm_to_numdays.csv');
            nhours = dayofqm.Days*24;
            caprate = max(mshy./nhours/mpc.gen(5,9));
            if caprate > 1
                Gmax(5,:) = Gmax(5,:)*caprate;
            end

            ct = 0;
            for i = 1:48
                Constraints = [Constraints,sum(pg(4,ct+1:ct+nhours(i)))==nyhy(i)];
                Constraints = [Constraints,sum(pg(5,ct+1:ct+nhours(i)))==mshy(i)];
                ct = ct + nhours(i);
            end
        end
    %     Constraints = [Constraints,pg(234,:)>=1100];
    %     Constraints = [Constraints,pg(238,:)>=500];
    
        % generator ramping, bounds and HVDC lines (modelled as two dummpy
        % generators on each side of the lines
        Constraints = [Constraints,Gmin<=pg<=Gmax];
        Constraints = [Constraints,pg(end-12,:) == -pg(end-8,:)];
        Constraints = [Constraints,pg(end-11,:) == -pg(end-7,:)];
        Constraints = [Constraints,pg(end-10,:) == -pg(end-6,:)];
        Constraints = [Constraints,pg(end-9,:) == -pg(end-5,:)];
        Constraints = [Constraints,pg(end-3,:) == -pg(end-2,:)];
        Constraints = [Constraints,pg(end-1,:) == -pg(end,:)];
        Constraints = [Constraints,pg(end-4,:) == -pg(end-1,:)];
        if ~newHVDC
            Constraints = [Constraints,pg(end-3,:) == 0];
            Constraints = [Constraints,pg(end-1,:) == 0];
        end
        Constraints = [Constraints,-Rdn(:,2:nt)<=pg(:,2:nt)-pg(:,1:nt-1)<=Rup(:,2:nt)]; % ramping CO
        Constraints = [Constraints,0<=loadshedding<=max(loads,0)];
    %     Constraints = [Constraints,0<=curtailment];
        wg = pg(mpcreduced.genfuel == 'Wind',:);
        wc = Wind-wg;
        sg = pg(mpcreduced.genfuel == 'SolarUPV',:);
        sc = SolarUPV-sg;
    %     hg = pg(mpcreduced.genfuel == 'Hydro',:);
    %     hc = Gmax(4:5,:)-hg;
    %     if externalgen
    %    
    %         ogen = orgen(244:271,starttime:starttime+nt-1);
    %         Constraints = [Constraints,pg(244:271,:) == ogen];
    %     end
    
        %% Solve Optimization
%         OO = 0;
        OO =sum(sum(loadshedding))+ 0.05*(sum(sum(charge))+sum(sum(discharge)));
%         OO = sum(sum(loadshedding));
        options = sdpsettings('verbose',1,'solver','GUROBI');
        options.gurobi.TokenServer = 'infrastructure3.tc.cornell.edu';
    %     options.gurobi.Method = 3;
    %     options.gurobi.Crossover = 0;
        options.gurobi.BarConvTol = 1e-10;
    %     options.gurobi.Threads = 1;
    %     options.gurobi_params.LicenseFile = '/opt/ohpc/pub/apps/gurobi/9.5.1/gurobi.lic';
    %     options.gurobi.BarHomogeneous = 1;
    %     options = sdpsettings('verbose',1,'solver','gurobi','gurobi.crossover',0);
    %     options = optimoptions('gurobi','Crossover',0);
        optimize([Constraints,NodeBalance],OO,options)
        initialbatt = value(battstate(:,nt+1));
    
        %% Inspect values of interest
        pg = value(pg);
    %     writematrix(pg,'generation.csv')
        flow = value(flow);
    %     writematrix(flow,'powerflow.csv')
        angle = value(angle)*180/pi;
    %     writematrix(angle,'angle.csv')
        charge = value(charge);
    %     writematrix(charge,'charge.csv')
        discharge = value(discharge);
    %     writematrix(discharge,'discharge.csv')
        battstate = value(battstate);
    %     writematrix(battstate,'battstate.csv')
        loadshedding = value(loadshedding);
        wc = value(wc);
        sc = value(sc);
    %     hc = value(hc);
    %     writematrix(loadshedding,'loadshedding.csv')
        ifsum = zeros(15,nt);
        for i = 1:15
            idx = ifmap(ifmap(:,1)==i,2);
            ifsum(i,:) = sum(repmat(sign(idx),1,nt).*flow(abs(idx),:),1);
        end
    %     writematrix(ifsum,'interfaceflow.csv')
    %     Nodelmp = [];
    %     for i = 1:57
    %         Nodelmp = [Nodelmp; dual(NodeBalance(i))];
    %     end
    %     writematrix(Nodelmp,'lmp.csv')
        
        genresult = [genresult,pg];
        flowresult = [flowresult,flow];
        ifsumresult = [ifsumresult,ifsum];
        chargeresult = [chargeresult,charge];
        dischargeresult = [dischargeresult,discharge];
        curtailwind = [curtailwind,wc];
        curtailsolar = [curtailsolar,sc];
    %     curtailhydro = [curtailhydro,hc];
    %     lmpresult = [lmpresult,Nodelmp];
        loadshedresult = [loadshedresult,loadshedding];
        battstateresult = [battstateresult,battstate];
        curtailresult = [curtailresult,curtailment];
    end
    directory_path = 'SolarS0_300_v4/Scenario'+string(lhscenario);
    if ~exist("directory_path",'dir')
        mkdir(directory_path)
    end
    % writematrix(result,'lmpwre.csv')
    writematrix(genresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/gen_'+string(year)+'.csv')
    writematrix(flowresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/flow_'+string(year)+'.csv')
    writematrix(ifsumresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/ifsum_'+string(year)+'.csv')
    writematrix(chargeresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/charege_'+string(year)+'.csv')
    writematrix(dischargeresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/disch_'+string(year)+'.csv')
    writematrix(curtailwind,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/wc_'+string(year)+'.csv')
    writematrix(curtailsolar,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/sc_'+string(year)+'.csv')
    % writematrix(curtailhydro,'SolarS0_300_v4/hcwre'+string(testcase)+'.csv')
    % writematrix(lmpresult,'SolarS0_300_v4/lmpwre'+string(testcase)+'.csv')
    writematrix(battstateresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/battstate_'+string(year)+'.csv')
    writematrix(loadshedresult,'SolarS0_300_v4/Scenario'+string(lhscenario)+'/loadshed_'+string(year)+'.csv')
end