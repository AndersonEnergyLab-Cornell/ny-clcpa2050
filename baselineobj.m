% addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
% DU_f = readmatrix('DU_factors_100.csv');
% DU_factors = sortrows(DU_f,11);
% nsamples = 87;
dayofqm = readtable('Data/qm_to_numdays.csv');
nhours = dayofqm.Days*24;
allobj = [];
for scenario = 1
    result = zeros(22,5);
    for year = 1998:2019
    %     result = zeros(nsamples,15);
    %     for scenario = 1:nsamples
    %         if scenario == 0
    %             s1 = input;
    %             bd_rateAE= 0.92;
    %             bd_rateFI= 0.92;
    %             bd_rateJK= 0.92;
    %             ev_rateAE = 0.9;
    %             ev_rateFI = 0.9;
    %             ev_rateJK = 0.9;
    %             wind_cap = 1;
    %             solar_cap = 1;
    %             batt_cap = 1;
    %         else
    %             s1 = DU_factors(scenario,11);
    %             temp = DU_factors(scenario,1);
    %             bd_rateAE= DU_factors(scenario,2);
    %             bd_rateFI= DU_factors(scenario,3);
    %             bd_rateJK= DU_factors(scenario,4);
    %             ev_rateAE = DU_factors(scenario,5);
    %             ev_rateFI = DU_factors(scenario,6);
    %             ev_rateJK = DU_factors(scenario,7);
    %             wind_cap = DU_factors(scenario,8);
    %             solar_cap = DU_factors(scenario,9);
    %             batt_cap = DU_factors(scenario,10);
    %         end
    
        
        gen = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/gen_'+string(year)+'.csv');
        flow = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/flow_'+string(year)+'.csv');
        ifsum = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/ifsum_'+string(year)+'.csv');
        charge = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/charege_'+string(year)+'.csv');
        disch = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/disch_'+string(year)+'.csv');
        wc = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/wc_'+string(year)+'.csv');
        sc = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/sc_'+string(year)+'.csv');
        battstate = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/battstate_'+string(year)+'.csv');
        ls = readmatrix('Baseline_v4/Scenario'+string(scenario)+'/loadshed_'+string(year)+'.csv');
        tempchange = readtable('Load/temperature.changes.csv');
%           normal result calculation   
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

        result(year-1997,1) = loadshedsum;
        result(year-1997,2) = nonzerotsls;
        result(year-1997,3) = maxls;
        result(year-1997,4) = renewablecurtail;
        result(year-1997,5) = max(energyneed);
% % % qm result calculation
% %         loadshedsum = sum(ls(4:49,:),1);
% %         tsls = sum(ls(4:49,:));
% % %         nonzerotsls =length(tsls(tsls~=0));
% %         renewablecurtail = sum(wc,1)+sum(sc,1);
% % %         maxls = max(sum(ls(4:49,:),1));
% %         
% %         ct = 0;
% %         for i = 1:48
% %            result(i,1) = sum(loadshedsum(ct+1:ct+nhours(i)));
% %            result(i,2) = sum(tsls(ct+1:ct+nhours(i))~=0);
% %            result(i,3) = max(loadshedsum(ct+1:ct+nhours(i)));
% %            result(i,4) = sum(renewablecurtail(ct+1:ct+nhours(i)));
% %            
% %            ct = ct + nhours(i);
% %         end
% %         histogram(result(:,1),'NumBins', 40)
% %     allobj = [allobj;result];
    end
%     max(allobj(:,3))
%     table_data = array2table(allobj, 'VariableNames', {'lsq', 'lsf', 'lsm','rc'});
    writematrix(result,'Baseline_v4/objs_'+string(scenario)+'.csv');
end
% histogram(allobj(:,1),'NumBins', 40)