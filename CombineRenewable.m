addpath('/opt/ohpc/pub/apps/gurobi/9.5.1/matlab')
scenario2 = 3;
% for scenario = [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]
for scenario = 1:159
    for year = 1998:2019
        Files=dir('RenewableGen/Solar/SolarData/Scenario'+string(scenario)+'_'+string(scenario2)+'/'+string(year)+'_SolarDPV*.csv');
        solarUPVk = [];
        for k = 1 : length(Files)
          baseFileName = Files(k).name;
          solari = readmatrix('RenewableGen/Solar/SolarData/Scenario'+string(scenario)+'_'+string(scenario2)+'/'+string(baseFileName));
          solarUPVk = [solarUPVk;solari];
        end
    % zoneD = (solarUPVk(9,:)+solarUPVk(10,:)+solarUPVk(11,:))/3/673*69;
    % zoneD(1,1) = 49;
    % solarUPVk = [solarUPVk;zoneD];
    % zoneKDPV = (solarUPVk(19,:)/90/2 + solarUPVk(20,:)/672)*846;
    % KDPV80 = zoneKDPV/2;
    % KDPV80(1,1) = 80;
    % KDPV79 = zoneKDPV/2;
    % KDPV79(1,1) = 79;
    % solarUPVk = [solarUPVk;KDPV79;KDPV80];
    % zoneKUPV = (solarUPVk(19,:)/90/2 + solarUPVk(20,:)/672)*77;
    % KUPV80 = zoneKUPV/2;
    % KUPV80(1,1) = 80;
    % KUPV79 = zoneKUPV/2;
    % KUPV79(1,1) = 79;
        directoryPath = 'RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'_'+string(scenario2);

        if ~exist(directoryPath, 'dir')
            mkdir(directoryPath);
        end
        writematrix(solarUPVk,'RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'_'+string(scenario2)+'/solarDPV'+string(year)+'.csv')

        Files=dir('RenewableGen/Solar/SolarData/Scenario'+string(scenario)+'_'+string(scenario2)+'/'+string(year)+'_SolarUPV*.csv');
        solarUPVk = [];
        for k = 1 : length(Files)
          baseFileName = Files(k).name;
          solari = readmatrix('RenewableGen/Solar/SolarData/Scenario'+string(scenario)+'_'+string(scenario2)+'/'+string(baseFileName));
          solarUPVk = [solarUPVk;solari];
        end
        % solarUPVk = [solarUPVk;KUPV79;KUPV80];
        directoryPath = 'RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'_'+string(scenario2);

        if ~exist(directoryPath, 'dir')
            mkdir(directoryPath);
        end
        writematrix(solarUPVk,'RenewableGen/Solar/SolarFinal/Scenario'+string(scenario)+'_'+string(scenario2)+'/solarUPV'+string(year)+'.csv')
    end
end



% for year = 1980:2019
% 
%     Files=dir('RenewableGen/Wind/WindData/'+string(year)+'_Wind*.csv');
%     solarUPVk = [];
%     for k = 1 : length(Files)
%       baseFileName = Files(k).name;
%       solari = readmatrix('RenewableGen/Wind/WindData/'+string(baseFileName));
%       solarUPVk = [solarUPVk;solari];
%     end
%     writematrix(solarUPVk,'RenewableGen/Wind/WindFinal/Wind'+string(year)+'.csv')
% end