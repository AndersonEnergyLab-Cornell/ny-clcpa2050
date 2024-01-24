addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
addpath(genpath([pwd filesep 'yalmip']));
addpath(genpath([pwd filesep 'matpower']));
DU_f = readmatrix('DU_factors_v3_300.csv');
DU_factors = sortrows(DU_f,7);
% DU_factors = sortrows(DU_f,1);
%summer plot 1999 day 205

for year = 1997+2
%     for scenario = [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]
    for lhscenario = 299
        scenario = DU_factors(lhscenario,7);
        bd_rateAE= DU_factors(lhscenario,2);
%         bd_rateFI= DU_factors(lhscenario,3);
%         bd_rateJK= DU_factors(lhscenario,4);
        ev_rateAE = DU_factors(lhscenario,3);
%         ev_rateFI = DU_factors(lhscenario,6);
%         ev_rateJK = DU_factors(lhscenario,7);
        wind_cap = DU_factors(lhscenario,4);
        solar_cap = DU_factors(lhscenario,5);
        batt_cap = DU_factors(lhscenario,6);
        starttime = 1;
        gen = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/gen_'+string(year)+'.csv');
        flow = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/flow_'+string(year)+'.csv');
        ifsum = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/ifsum_'+string(year)+'.csv');
        charge = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/charege_'+string(year)+'.csv');
        disch = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/disch_'+string(year)+'.csv');
        wc = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/wc_'+string(year)+'.csv');
        sc = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/sc_'+string(year)+'.csv');
        battstate = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/battstate_'+string(year)+'.csv');
        ls = readmatrix('SolarS0_300_v4/Scenario'+string(lhscenario)+'/loadshed_'+string(year)+'.csv');

%         newload = readmatrix('Load/AllSimload/Scenario'+string(scenario)+'/simload_'+string(year)+'.csv');
        newload = readmatrix('Load/AllBaseload/Scenario'+string(scenario)+'/simload_'+string(year)+'.csv');
%         iflimup = readmatrix('Data/Iflim/iflimup_'+string(year)+'_'+string(scenario)+'.csv');
%         iflimdn = readmatrix('Data/Iflim/iflimdn_'+string(year)+'_'+string(scenario)+'.csv');
        Naghydro = readtable('Data/hydrodata/nypaNiagaraEnergy.climate.change.csv');
        Mshydro = readtable('Data/hydrodata/nypaMosesSaundersEnergy.climate.change.csv');
        if scenario ~= 0
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
        smallhydro = readmatrix('Data/hydrodata/smallhydrogen.csv');
        EVload = readmatrix('Load/EVload/EVload_Bus.csv');
        EVloadbusid = EVload(:,1);
        ResLoad = readmatrix('Load/ResLoad/Scenario'+string(scenario)+'/ResLoad_Bus_'+string(year)+'.csv');
        ComLoad = readmatrix('Load/ComLoad/Scenario'+string(scenario)+'/ComLoad_Bus_'+string(year)+'.csv');

        SolarUPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'/solarUPV'+string(year)+'.csv');
        SolarDPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'/solarDPV'+string(year)+'.csv');
        Wind = readmatrix('RenewableGen/Wind/WindFinal/Wind'+string(year)+'.csv');
        SolarUPV = round(SolarUPV,2);
        SolarDPV = round(SolarDPV,2);
        Wind = round(Wind,2);

        load('Data/mpc2050.mat')
        nt = 8760;


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
        mpc.gen(end-7:end,9) = -mpc.gen(end-7:end,10);
  
        cleanpath1 = [36,0,0,100,-100,1,100,1,1300,-1300,zeros(1,11)];
        cleanpath2 = [48,0,0,100,-100,1,100,1,1300,-1300,zeros(1,11)];
        CHPexpress1 = [15,0,0,100,-100,1,100,1,1250,-1250,zeros(1,11)];
        CHPexpress2 = [48,0,0,100,-100,1,100,1,1250,-1250,zeros(1,11)];
        mpc.gen =[mpc.gen;cleanpath1;cleanpath2;CHPexpress1;CHPexpress2];

        
        smallhydro = readtable('Data/hydrodata/SmallHydroCapacity.csv');
        smallhydrogen = readmatrix('Data/hydrodata/smallhydrogen.csv');
        smallhydrogen = smallhydrogen(:,starttime:starttime+nt-1);
        smallhydrobusid = smallhydro.busIndex;
        for i = 1:length(smallhydrobusid)
            smallhydrobusid(i) = find(mpcreduced.bus(:,1) == smallhydrobusid(i));
        end
        
        load('businfo.mat')

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
        
%         newload(EVloadbusid,:) = newload(EVloadbusid,:) + evload;
    
        %Add building load
        Buldingload = ComLoad(:,starttime+1:starttime+nt)+ResLoad(:,starttime+1:starttime+nt);
        
        Buldingload(AEbd,:) = Buldingload(AEbd,:)*bd_rateAE;
        Buldingload(FIbd,:) = Buldingload(FIbd,:)*bd_rateAE;
        Buldingload(JKbd,:) = Buldingload(JKbd,:)*bd_rateAE;
        
        
%         newload(Buildingidx,:) = newload(Buildingidx,:) + Buldingload;
        

        hourload = sum(newload(4:49,:),1);
        
        exid = find(mpc.genfuel == 'Import');
        hourexgen= sum(gen(exid,:),1);
        nuid = find(mpc.genfuel == 'Nuclear');

        hournugen = sum(gen(nuid,:),1);
        
        hyid = find(mpc.genfuel == 'Hydro');
        hourhygen = sum(gen(hyid,:),1);
        
        wdid = find(mpc.genfuel == 'Wind');
        hourwdgen = sum(gen(wdid,:),1);

        srid = find(mpc.genfuel == 'SolarUPV');
        hoursrgen = sum(gen(srid,:),1);

        NEbranch = [-1;-2];
        PJMbranch = [58;61;70];
        IESObranch = [26;39;40];
     
        NE = sum(repmat(sign(NEbranch),1,nt).*flow(abs(NEbranch),:),1)+gen(68,:);
        PJM = sum(repmat(sign(PJMbranch),1,nt).*flow(abs(PJMbranch),:),1)+sum(gen(69:71,:),1);
        IESO = sum(repmat(sign(IESObranch),1,nt).*flow(abs(IESObranch),:),1);
        HQ = gen(find(mpc.genfuel == 'HQ'),:)+gen(80,:);
         
        importgen = -(NE+PJM+IESO)+HQ;

        hourls = sum(ls(4:49,:),1);
        hourwc = sum(wc,1);
        hoursc = sum(sc,1);
        
        
        hourslbtm = sum(SolarDPV,1);
        hourcharge = sum(charge,1);
        hourdischar = sum(disch,1);
        hoursmhy = sum(smallhydrogen,1);
        hourev = sum(evload,1);
        hourbuilding = sum(Buldingload,1);
        
        hourload = hourload+hourev+hourbuilding;
        balance = hourload - hourls - (hournugen + hourhygen + hoursmhy+hourwdgen+hoursrgen+hourslbtm+hourdischar - hourcharge)-importgen;
        dynu = zeros(1,365);
        dyhd = zeros(1,365);
        dywg = zeros(1,365);
        dysl = zeros(1,365);
        dyload = zeros(1,365);
        dyex = zeros(1,365);
        dywc = zeros(1,365);
        dysc = zeros(1,365);
        dyslbtm = zeros(1,365);
        dysmhy = zeros(1,365);
        dychar = zeros(1,365);
        dydischar = zeros(1,365);
        dyls = zeros(1,365);
        dyev =zeros(1,365);
        dybuild = zeros(1,365);
        dyim = zeros(1,365);
        for i = 1:365
            dynu(i) = sum(hournugen((i-1)*24+1:i*24));
            dyhd(i) = sum(hourhygen((i-1)*24+1:i*24));
            dyex(i) = sum(hourexgen((i-1)*24+1:i*24));
            
            dywg(i) = sum(hourwdgen((i-1)*24+1:i*24));
            dysl(i) = sum(hoursrgen((i-1)*24+1:i*24));
            
            dyload(i) = sum(hourload((i-1)*24+1:i*24));
            
            dywc(i) = sum(hourwc((i-1)*24+1:i*24));
            dysc(i) = sum(hoursc((i-1)*24+1:i*24));
            dyslbtm(i) = sum(hourslbtm((i-1)*24+1:i*24));
            
            dychar(i) = sum(hourcharge((i-1)*24+1:i*24));
            dydischar(i) = sum(hourdischar((i-1)*24+1:i*24));
            dyls(i) = sum(hourls((i-1)*24+1:i*24));

            dysmhy(i) = sum(hoursmhy((i-1)*24+1:i*24));
            dyev(i) = sum(hourev((i-1)*24+1:i*24));
            dybuild(i) = sum(hourbuilding((i-1)*24+1:i*24));
            dyim(i)=sum(importgen((i-1)*24+1:i*24));
        end
        
        yynu = sum(dynu);
        yyhd = sum(dyhd);
        yyex = sum(dyex);
        yyload = sum(dyload);
        yywg = sum(dywg);
        yysl= sum(dysl);
        yywc = sum(dywc);
        yysc = sum(dysc);
        
        

        % sum(NYNEo-NYNEw);
        % sum(NYPJMo-NYPJMw);
        % sum(NYIESOo - NYIESOw);
        % sum(newloadww(50:52,1)) -sum(genwre(253:258,1))
        % sum(newload(53:57,1)) -sum(genwore(259:270,1))
        % sum(newload(1:3,1)) -sum(genwore(244:252,1))
        % sum(newloadww(1:3,1)) -sum(genwre(244:252,1))
        % yysmhydrowre = sum(sum(smallhydrogen));
        % sum(repmat(sign(PJMbranch),1,1).*flowwre(abs(PJMbranch),931),1)
        % sum(newload(53:57,931)) -sum(genwore(259:270,931))
        % sum(newloadww(53:57,931)) -sum(genwre(259:270,931))
        % sum(genwore(273:275,931),1)
        % sum(repmat(sign(PJMbranch),1,1).*flowwore(abs(PJMbranch),931),1)
        % sum(genwre(300:302,931),1)
        yybtmslwre = sum(sum(SolarDPV));
        

        %% bar plot for daily
        dyrenewable = [dynu;dyhd+dysmhy;dysl+dyslbtm;dywg;-dychar;dydischar;dyim;dyls]'/1000;
        color = [[0.7 0.7 0.7];
                [0 0.4470 0.7410];
                [0.9290 0.6940 0.1250];
                [0.4660 0.6740 0.1880];
                [0.3010 0.7450 0.9330];
                [0.6350 0.0780 0.1840];
                [0.4940 0.1840 0.4560];
                [0.8500 0.3250 0.0980]];
        figure(1)
        ax1 = subplot(2,1,1);
        ba = bar(dyrenewable,'stacked','FaceColor','flat');
        for i = 1:8
        ba(i).CData = color(i,:);
        end
        hold on
        plot(dyload/1000,'k-','LineWidth',3)
        
        legend('Nuclear','Hydro','Solar','Wind','Charge','Discharge','Import','Loadshed','Load')
        xlabel('Day of Year')
        ylabel('Generation by fuel type (GWh)')
        ax = gca;
        ax.FontSize = 20; 
        
        ax2 = subplot(2,1,2);
        % plot(1:365,dyhdc/1000,'LineWidth',2,'Color','#0072BD')
        % hold on
        plot(1:365,dywc/1000,'LineWidth',2,'Color','#77AC30')
        hold on
        plot(1:365,dysc/1000,'LineWidth',2,'Color','#EDB120')
        hold on
        grid
        xlim([0,365])
        legend('Wind curtail','Solar curtail')
        xlabel('Day of Year')
        ylabel('Curtailed Energy (GWh)')
        ax = gca;
        ax.FontSize = 20; 
        linkaxes([ax1,ax2],'x')
        set(gcf, 'Position', [618,404,1559,770]);
        % Save the plot as a PNG image
%         print(gcf, '-dpng', 'SolarS0_300_v4/Figures/annualcase'+string(year)+'_'+string(scenario)+'.png');
%         close(1)
        %% figure daily
        %winter year 15, day 50
        dd = 205;
        starttime = 1+dd*24;
        nt=7*24;
        
        
        
        hyrenewable = [hournugen(starttime:starttime+nt-1);...
            hourhygen(starttime:starttime+nt-1)+hoursmhy(starttime:starttime+nt-1);hoursrgen(starttime:starttime+nt-1)+hourslbtm(starttime:starttime+nt-1);...
            hourwdgen(starttime:starttime+nt-1);...
            -hourcharge(starttime:starttime+nt-1);hourdischar(starttime:starttime+nt-1);importgen(starttime:starttime+nt-1);hourls(starttime:starttime+nt-1)]';
        figure(2)
        ax1 = subplot(2,1,1);
        ba2 = bar(hyrenewable,'stacked','FaceColor','flat');
        for i = 1:8
        ba2(i).CData = color(i,:);
        end
        hold on
        plot(hourload(starttime:starttime+nt-1),'k-','LineWidth',3)
        ylim([-2.5*10^4 5.5*10^4])
        legend('Nuclear','Hydro','Solar','Wind','Charge','Discharge','Import','Loadshed','Load')
        xlabel('Hours')
        ylabel('Generation by fuel type (MWh)')
        ax = gca;
        ax.FontSize = 20; 
        ax2 = subplot(2,1,2);
        % plot(1:nt,hyhdc(starttime:starttime+nt-1),'LineWidth',2,'Color','#0072BD')
        % hold on
        plot(1:nt,hourwc(starttime:starttime+nt-1),'LineWidth',2,'Color','#77AC30')
        hold on
        plot(1:nt,hoursc(starttime:starttime+nt-1),'LineWidth',2,'Color','#EDB120')
        hold on
        grid
        xlim([0,nt])
        legend('Wind curtail','Solar curtail')
        xlabel('Hours')
        ylabel('Curtailed Energy (MWh)')
        ax = gca;
        ax.FontSize = 20; 
        linkaxes([ax1,ax2],'x')
        set(gcf, 'Position', [618,404,1559,770]);
        % Save the plot as a PNG image
%         print(gcf, '-dpng', 'SolarS0_300_v4/Figures/dailycase'+string(year)+'_'+string(scenario)+'.png');
%         close(2)
        %% loadshed 
        loadshedsum = sum(sum(ls(4:49,:)))
        tsls = sum(ls(4:49,:));
        nonzerotsls =length(tsls(tsls~=0))
        lslz = sum(ls(4:49,:),2);
        lsex = sum(sum(ls([1,2,3,50:end],:)));
        totalload = sum(sum(newload(4:49,:)))
        loadshedsum/totalload
        rbus = mpc.bus;
            obus = mpcreduced.bus;
            PJMbus = [53:57];
            NEbus = [1:3];
            IESObus = [50:52];
            A = [54 55 56 57 58 59 60 61];
            B = [62 52 53];
            C = [50 51 63 64 65 66 67 68 70 71 72];
            D = [48 49];
            E = [69 38 43 44 45 46 47];
            F = [40 41 42 37];
            G = [39 73 75 76 77];
            H = 74;
            I = 78;
            J = [82 81];
            K = [79 80];
            Abus = [];Bbus = [];Cbus = [];Dbus = [];Ebus = [];Fbus = [];Gbus = [];Hbus = [];Ibus = [];Kbus = [];Jbus = [];
            for i = A
                Abus = [Abus,rbus(obus(:,1)==i,1)];
            end
            
            Als = sum(ls(Abus,:),1);
            for i = B
                Bbus = [Bbus,rbus(obus(:,1)==i,1)];
            end
            
            Bls = sum(ls(Bbus,:),1);
            for i = C
                Cbus = [Cbus,rbus(obus(:,1)==i,1)];
                
            end
            
            Cls = sum(ls(Cbus,:),1);
            for i = D
                Dbus = [Dbus,rbus(obus(:,1)==i,1)];
            end
            
            Dls = sum(ls(Dbus,:),1);
            for i = E
                Ebus = [Ebus,rbus(obus(:,1)==i,1)];
            end
            
            Els = sum(ls(Ebus,:),1);
            for i = F
                Fbus = [Fbus,rbus(obus(:,1)==i,1)];
            end
            
            Fls = sum(ls(Fbus,:),1);
            for i = G
                Gbus = [Gbus,rbus(obus(:,1)==i,1)];
            end
            
            Gls = sum(ls(Gbus,:),1);
            for i = H
                Hbus = [Hbus,rbus(obus(:,1)==i,1)];
            end
            
            Hls = sum(ls(Hbus,:),1);
            for i = I
                Ibus = [Ibus,rbus(obus(:,1)==i,1)];
            end
            
            Ils = sum(ls(Ibus,:),1);
            for i = J
                Jbus = [Jbus,rbus(obus(:,1)==i,1)];
            end
            
            Jls = sum(ls(Jbus,:),1);
            for i = K
                Kbus = [Kbus,rbus(obus(:,1)==i,1)];
            end
            
            Kls = sum(ls(Kbus,:),1);
            
            
            
            binrng = 1:8760;
            figure(3)
            subplot(6,2,1)
            plot(binrng,Als,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('A')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,2)
            plot(binrng,Bls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('B')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,3)
            plot(binrng,Cls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('C')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,4)
            plot(binrng,Dls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('D')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,5)
            plot(binrng,Els,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('E')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,6)
            plot(binrng,Fls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('F')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,7)
            plot(binrng,Gls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('G')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,8)
            plot(binrng,Hls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('H')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,9)
            plot(binrng,Ils,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('I')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,10)
            plot(binrng,Jls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('J')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,11)
            plot(binrng,Kls,'LineWidth',2)
            hold on
            xlabel('Hour')
            ylabel('LoadShed (MW)')
            title('K')
            ax = gca;
            ax.FontSize = 16; 
            grid
            subplot(6,2,12)
            text(0.1,0.5,['Total load shedding amount is:',num2str(loadshedsum),'MWh'],'FontSize',20)
            hold on
            text(0.1,0.3,['Number of hours with load shedding is :',num2str(nonzerotsls)],'FontSize',20)
            title('LoadShed summary')
            ax = gca;
            ax.FontSize = 16; 
            set(gcf, 'Position', [347,1,1457,1271]);
%             print(gcf, '-dpng', 'SolarS0_300_v4/Figures/zonalls'+string(year)+'_'+string(scenario)+'.png');
%             close(3)
        batt = charge.*disch;
        battall = sum(sum(batt))
    end
end