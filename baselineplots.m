%% objectives
objs = {};
for scenario = 1:3
    objs{scenario} = readmatrix('Baseline_v4/objs_'+string(scenario)+'.csv');
end
x = 1:22;


figure(1)
% ax1 = subplot(2,1,1);
plot(x, objs{2}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
hold on
plot(x,objs{1}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{4}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{5}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
xlabel('Year')
ylabel('Load Shedding Quantity (MWh)')
legend('Static Rating for Transmission', 'Dynamic Rating for Transmission')
% legend('Without transmission constraints', 'With transmission constraints')%, ...
   % 'QuaterMonthly hydro Constraints','Dynamic rating for transmission lines')
grid on
ax = gca;
ax.FontSize = 20; 
set(gcf, 'Position', [438,116,1426,725]);
% print(gcf, '-dpng', 'Figures/SupplementFigures/BaselineLSQ.png');
% ax2 = subplot(2,1,2);
% plot(x,objs{3}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{6}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{7}(:,1), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Load Shedding Quantity (MWh)')
% legend('New transmission lines','All together','Without Dynamic Rating')
% grid on
% ax = gca;
% ax.FontSize = 20; 


figure(2)
% ax1 = subplot(2,1,1);
plot(x, objs{2}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
hold on
plot(x,objs{1}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{4}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{5}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
xlabel('Year')
ylabel('Load Shedding Hours')
legend('Static Rating for Transmission', 'Dynamic Rating for Transmission')
% legend('Without transmission constraints', 'With transmission constraints')%, ...
  %  'QuaterMonthly hydro Constraints','Dynamic rating for transmission lines')
grid on
ax = gca;
ax.FontSize = 20; 
set(gcf, 'Position', [438,116,1426,725]);
% print(gcf, '-dpng', 'Figures/SupplementFigures/BaselineLSF.png');
% ax2 = subplot(2,1,2);
% plot(x,objs{3}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{6}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{7}(:,2), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Load Shedding Frequency')
% legend('New transmission lines','All together','Without Dynamic Rating')
% grid on
% ax = gca;
% ax.FontSize = 20; 

figure(3)
% ax1 = subplot(2,1,1);
plot(x, objs{2}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
hold on
plot(x,objs{1}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{4}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{5}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
xlabel('Year')
ylabel('Maximum Load Shedding (MW)')

legend('Static Rating for Transmission', 'Dynamic Rating for Transmission')
% legend('Without transmission constraints', 'With transmission constraints')%, ...
   %'QuaterMonthly hydro Constraints','Dynamic rating for transmission lines')
grid on
ax = gca;
ax.FontSize = 20; 
set(gcf, 'Position', [438,116,1426,725]);
% print(gcf, '-dpng', 'Figures/SupplementFigures/BaselineLSM.png');
% ax2 = subplot(2,1,2);
% plot(x,objs{3}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{6}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{7}(:,3), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Maximum Load Shedding Quantity (MWh)')
% legend('New transmission lines','All together','Without Dynamic Rating')
% grid on
% ax = gca;
% ax.FontSize = 20; 
% 
% figure(4)
% % ax1 = subplot(2,1,1);
% plot(x, objs{1}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{2}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{4}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{5}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Renewable Curtailment (MWh)')
% legend('Without transmission constraints', 'With transmission constraints', ...
%     'QuaterMonthly hydro Constraints','Dynamic rating for transmission lines')
% grid on
% ax = gca;
% ax.FontSize = 20; 
% set(gcf, 'Position', [438,116,1426,725]);
% print(gcf, '-dpng', 'Figures/SupplementFigures/BaselineRC.png');
% % ax2 = subplot(2,1,2);
% % plot(x,objs{3}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% % hold on
% % plot(x,objs{6}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% % hold on
% % plot(x,objs{7}(:,4), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% % xlabel('Year')
% % ylabel('Renewable Curtailment (MWh)')
% % legend('New transmission lines','All together','Without Dynamic Rating')
% % grid on
% % ax = gca;
% % ax.FontSize = 20; 
% 
% figure(5)
% % ax1 = subplot(2,1,1);
% plot(x, objs{1}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{2}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{4}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{5}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Max Energy Deficiency (Weekly)(MWh)')
% legend('Without transmission constraints', 'With transmission constraints', ...
%     'QuaterMonthly hydro Constraints','Dynamic rating for transmission lines')
% grid on
% ax = gca;
% ax.FontSize = 20; 
% set(gcf, 'Position', [438,116,1426,725]);
% print(gcf, '-dpng', 'Figures/SupplementFigures/BaselineEN.png');
% ax2 = subplot(2,1,2);
% plot(x,objs{3}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{6}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% hold on
% plot(x,objs{7}(:,5), '-o', 'LineWidth', 2, 'MarkerSize', 8)
% xlabel('Year')
% ylabel('Max Energy Deficiency (Weekly)( (MWh)')
% legend('New transmission lines','All together','Without Dynamic Rating')
% grid on
% ax = gca;
% ax.FontSize = 20; 





% % load, wind, solar and hydro
% Naghydro = readtable('Data/hydrodata/nypaNiagaraEnergy.climate.change.csv');
% Mshydro = readtable('Data/hydrodata/nypaMosesSaundersEnergy.climate.change.csv');
% colname1 = 'nypaNiagaraEnergy';
% colname2 = 'nypaMosesSaundersEnergy';
% baseload = {};
% comload = {};
% resload = {};
% totalload = {};
% windtotal = {};
% solartotal = {};
% hydrototal = {};
% for year = 1998:2019
%     baseloaddata = readmatrix('Load/AllSimload/Scenario0/simload_'+string(year)+'.csv');
%     baseload{year-1997} = sum(baseloaddata(4:49,:),1);
%     comloaddata = readmatrix('Load/Comload/Scenario0/ComLoad_Bus_'+string(year)+'.csv');
%     comload{year-1997} = sum(comloaddata(:,2:8761),1);
%     resloaddata = readmatrix('Load/Resload/Scenario0/ResLoad_Bus_'+string(year)+'.csv');
%     resload{year-1997} = sum(resloaddata(:,2:8761),1);
%     totalload{year-1997} = baseload{year-1997}+comload{year-1997}+resload{year-1997};
%     nyhy = Naghydro(Naghydro.Year == year,colname1);
%     nyhy = table2array(nyhy);
%     mshy = Mshydro(Mshydro.Year == year,colname2);
%     mshy = table2array(mshy);
%     hydrototal{year-1997} = nyhy+mshy;
%     SolarUPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(0)+'/solarUPV'+string(year)+'_0.csv');
%     SolarDPV = readmatrix('RenewableGen/Solar/SolarFinal/Scenario'+string(0)+'/solarDPV'+string(year)+'_0.csv');
%     Wind = readmatrix('RenewableGen/Wind/WindFinal/Wind'+string(year)+'.csv');
%     windtotal{year-1997} = sum(Wind(:,2:8761),1);
%     solartotal{year-1997} = sum(SolarDPV(:,2:8761),1)+sum(SolarUPV(:,2:8761),1);
% 
% end
% dayofqm = readtable('Data/qm_to_numdays.csv');
% nhours = dayofqm.Days*24;
% 
% sumload = zeros(22,48);
% sumwind = zeros(22,48);
% sumsolar = zeros(22,48);
% for yr = 1:22
%     ct = 0;
%     for i = 1:48
%         sumload(yr,i) = sum(totalload{yr}(ct+1:ct+nhours(i)));
%         sumwind(yr,i) = sum(windtotal{yr}(ct+1:ct+nhours(i)));
%         sumsolar(yr,i) = sum(solartotal{yr}(ct+1:ct+nhours(i)));
%         ct = ct + nhours(i);
%     end
% end
% for i = 1:22
%     shy(i) = sum(hydrototal{i});
%     sw(i) = sum(sumwind(i,:));
%     ss(i) = sum(sumsolar(i,:));
%     sload(i) = sum(sumload(i,:));
% end
% 
% 
% close all
% trange = [8,9,18];
% figure(6)
% subplot(4,1,1)
% for i = trange
%     plot(sumload(i,:),'LineWidth',2,'DisplayName',string(i))
%     hold on
% end
% grid on
% legend()
% xlabel('Week')
% ylabel('MWh')
% title('Load')
% ax = gca;
% ax.FontSize = 20; 
% subplot(4,1,2)
% for i = trange
%     plot(sumwind(i,:),'LineWidth',2,'DisplayName',string(i))
%         hold on
% end
% grid on
% legend()
% xlabel('Week')
% ylabel('MWh')
% title('Wind')
% ax = gca;
% ax.FontSize = 20;
% subplot(4,1,3)
% for i = trange
%     plot(sumsolar(i,:),'LineWidth',2,'DisplayName',string(i))
%         hold on
% end
% grid on
% legend()
% xlabel('Week')
% ylabel('MWh')
% title('Solar')
% ax = gca;
% ax.FontSize = 20;
% subplot(4,1,4)
% for i = trange
%     plot(hydrototal{i},'LineWidth',2,'DisplayName',string(i))
%     hold on
% end
% grid on
% legend()
% xlabel('Week')
% ylabel('MWh')
% title('Hydro')
% ax = gca;
% ax.FontSize = 20;
% figure(7)
% subplot(3,1,1)
% plot(sload,'LineWidth',2,'DisplayName','Load','Color','black')
% % hold on
% % xline(trange,'Color','red','LineWidth',3)
% legend()
% xlabel('Year')
% ylabel('MWh')
% grid on
% ax = gca;
% ax.FontSize = 20;
% subplot(3,1,2)
% plot(sw,'LineWidth',2,'DisplayName','Wind','Color',	"#77AC30")
% hold on
% plot(ss,'LineWidth',2,'DisplayName','Solar','Color',"#EDB120")
% % hold on
% % xline(trange,'Color','red','LineWidth',3)
% legend()
% xlabel('Year')
% ylabel('MWh')
% grid on
% ax = gca;
% ax.FontSize = 20;
% subplot(3,1,3)
% plot(shy,'LineWidth',2,'DisplayName','Hydro','Color','#0072BD')
% % hold on
% % xline(trange,'Color','red','LineWidth',3,'DisplayName',['Day8';'Day9';'Day18'])
% legend()
% xlabel('Year')
% ylabel('MWh')
% grid on
% ax = gca;
% ax.FontSize = 20;