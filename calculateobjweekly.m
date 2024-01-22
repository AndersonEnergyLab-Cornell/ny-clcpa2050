function calculateobjweekly(scenario)
addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
dayofqm = readtable('Data/qm_to_numdays.csv');
nhours = dayofqm.Days*24;
allobj = [];

    result = zeros(48,4);
    for year = 1998:2019
        
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

        loadshedsum = sum(ls(4:49,:),1);
        tsls = sum(ls(4:49,:));
        nonzerotsls =length(tsls(tsls~=0));
        renewablecurtail = sum(wc,1)+sum(sc,1);
        maxls = max(sum(ls(4:49,:),1));
        
        ct = 0;
        for i = 1:48
           result(i,1) = sum(loadshedsum(ct+1:ct+nhours(i)));
           result(i,2) = sum(tsls(ct+1:ct+nhours(i))~=0);
           result(i,3) = max(loadshedsum(ct+1:ct+nhours(i)));
           result(i,4) = sum(renewablecurtail(ct+1:ct+nhours(i)));
           
           ct = ct + nhours(i);
        end
    allobj = [allobj;result];
    end
%     max(allobj(:,3))
    table_data = array2table(allobj, 'VariableNames', {'lsq', 'lsf', 'lsm','rc'});
    writetable(table_data,'SolarS0_300_v4/QMresults/objsqm_'+string(scenario)+'.csv');

