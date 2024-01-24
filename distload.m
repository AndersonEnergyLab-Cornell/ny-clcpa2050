for scenario = 101:159
    scenario
%     for scenario = [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]
%     for scenario = [5:117,119,120]
    for year = 1998:2019
        busInfo = importBusInfo("Data/npcc_new.csv");
        NYSBus = busInfo(busInfo.zone ~= 'NA', :);
        zoneIDs = ['A','B','C','D','E','F','G','H','I','J','K'];
        zoneload = {};
        for i = 1:11
            zoneload{i} = readtable('Data/Load/Baseload/Scenario'+string(scenario)+'/loadex_'+string(zoneIDs(i))+'_'+ string(year)+'.csv');
        end
        
        
        % Subset bus with load connected, could be all types of bus
        NYSBusWLoad = NYSBus(NYSBus.sumLoadP0 > 0, :);
        
        %% Load bus and ratio calculation
        % zoneIDs = {'A','B','C','D','E','F','G','H','I','J','K'};
        zoneIDs = unique(busInfo.zone);
        loadBusZone = cell(11, 1);
        loadRatioZone = cell(11, 1);
        numLoadBusZone = zeros(11, 1);
        for i=1:11
            % If the zone has bus with load, then distribute the load according to
            % the original load ratio
            % Including zone A, B, C, D, E, F, H, I, K
            loadBusTable = NYSBusWLoad(NYSBusWLoad.zone == zoneIDs(i), :);
            loadBusZone{i} = loadBusTable.idx;
            loadRatioZone{i} = loadBusTable.sumLoadP0/sum(loadBusTable.sumLoadP0);
            
            % If the zone doesn't have bus with load, then evenly distribute the
            % load among all buses in that zone
            % Including zone G, J
            if isempty(loadBusZone{i})
                loadBusZone{i} = NYSBus.idx(NYSBus.zone == zoneIDs(i));
                loadRatioZone{i} = repmat(1/length(loadBusZone{i}),2,1);
            end
            numLoadBusZone(i) = length(loadBusZone{i});
        end
        numLoadBusTot = sum(numLoadBusZone);
        
        zoneLoadBus = cell(11, 1);
        loadBusIdx = zeros(numLoadBusTot, 1);
        loadBusLoad = zeros(numLoadBusTot, 8761);
        n = 1;
        for i=1:11
        %     zoneLoadTot = hourlyLoadZonal.Load(hourlyLoadZonal.ZoneID == categorical(zoneIDs(i)));
            zoneLoadTot = zoneload{i}.Var1;
            zoneLoadBus{i} = loadRatioZone{i}.*zoneLoadTot';
            loadBusIdx(n:n+numLoadBusZone(i)-1) = loadBusZone{i};
            loadBusLoad(n:n+numLoadBusZone(i)-1,:) = zoneLoadBus{i};
            n = n+numLoadBusZone(i);
        end
        loadBusLoad(:,1) = loadBusIdx;
        zonalload = sortrows(loadBusLoad);
        load = zeros(46,8760);
        for i = 1:46
            if any(zonalload(:,1)==i+36)
                load(i,:) = zonalload(find(zonalload(:,1)==i+36),2:8761);
            end
        end
                
        load2019 = readmatrix('Data/Load/newloadwowind.csv');
        sumNY = sum(load2019(4:49,:),1);
        ratioNE = load2019(1:3,:)./repmat(sumNY,3,1);
        ratioIESO = load2019(50:52,:)./repmat(sumNY,3,1);
        ratioPJM = load2019(53:57,:)./repmat(sumNY,5,1);
        sumNYsim = sum(load,1);
        NEload = ratioNE.*repmat(sumNYsim,3,1);
        IESOload = ratioIESO.*repmat(sumNYsim,3,1);
        PJMload = ratioPJM.*repmat(sumNYsim,5,1);
        loadfinal = [NEload;load;IESOload;PJMload];
        directoryPath = 'Data/Load/AllBaseload/Scenario'+string(scenario);
%         figure(year-1997)
%         plot(sum(loadfinal(4:49,:),1));
        if ~exist(directoryPath, 'dir')
            mkdir(directoryPath);
        end
        writematrix(loadfinal,'Data/Load/AllBaseload/Scenario'+string(scenario)+'/simload_'+string(year)+'.csv')
        if max(max(loadfinal)) >1e10
            year
            scenario
            max(max(loadfinal))
        end
    end
end