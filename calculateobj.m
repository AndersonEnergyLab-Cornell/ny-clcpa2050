function calculateobj_v3(yr)
addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
DU_f = readmatrix('DU_factors_v3_300.csv');
DU_factors = sortrows(DU_f,7);
nsamples = 300;
for year = yr+1997
    result = zeros(nsamples,11);
    for scenario = 1:nsamples
        if scenario == 0
            s1 = input;
            bd_rateAE= 0.92;
            bd_rateFI= 0.92;
            bd_rateJK= 0.92;
            ev_rateAE = 0.9;
            ev_rateFI = 0.9;
            ev_rateJK = 0.9;
            wind_cap = 1;
            solar_cap = 1;
            batt_cap = 1;
        else
            s1 = DU_factors(scenario,7);
            temp = DU_factors(scenario,1);
            bd_rateAE= DU_factors(scenario,2);
            
            ev_rateAE = DU_factors(scenario,3);
           
            wind_cap = DU_factors(scenario,4);
            solar_cap = DU_factors(scenario,5);
            batt_cap = DU_factors(scenario,6);
        end

    
        gen = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/gen_'+string(year)+'.csv');
        flow = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/flow_'+string(year)+'.csv');
        ifsum = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/ifsum_'+string(year)+'.csv');
        charge = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/charege_'+string(year)+'.csv');
        disch = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/disch_'+string(year)+'.csv');
        wc = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/wc_'+string(year)+'.csv');
        sc = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/sc_'+string(year)+'.csv');
        battstate = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/battstate_'+string(year)+'.csv');
        ls = readmatrix('SolarS0_300_v4/Scenario'+string(scenario)+'/loadshed_'+string(year)+'.csv');
        tempchange = readtable('Load/temperature.changes.csv');

        loadshedsum = sum(sum(ls(4:49,:)));
        tsls = sum(ls(4:49,:));
        nonzerotsls =length(tsls(tsls~=0));
        renewablecurtail = sum(sum(wc))+sum(sum(sc));
        maxls = max(sum(ls(4:49,:),1));
        %  energy needed in X amount of time
            lssum = sum(ls(4:49,:),1);
            horizon = 168;
            energyneed = zeros(1,8760 - horizon+1);
            for h = 1:8760 - horizon+1
                energyneed(h) = sum(lssum(h:h+horizon-1));
            end

        result(scenario,1) = temp;
        result(scenario,2) = bd_rateAE;
        result(scenario,3) = ev_rateAE;
        result(scenario,4) = wind_cap;
        result(scenario,5) = solar_cap;
        result(scenario,6) = batt_cap;
        result(scenario,7) = loadshedsum;
        result(scenario,8) = nonzerotsls;
        result(scenario,9) = maxls;
        result(scenario,10) = renewablecurtail;
        result(scenario,11) = max(energyneed);
        
    end
    writematrix(result,'SolarS0_300_v4/objs_'+string(year)+'.csv');
end

