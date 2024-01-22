scenario = 0;
Lup = [2200;1500;5650;2650;3925;2300;5400;7375;8750;4350;1293;5650];
Ldn = [-9999;-9999;-9999;-1100;-9999;-1600;-5400;-9999;-8450;-9999;-515;-3400];
Lup = repmat(Lup,1,8760);
Ldn = repmat(Ldn,1,8760);
lhscenario = 6;
for year = 1998:2019

    iflimup = readmatrix('Data/iflim/iflimup_'+string(year)+'_'+string(scenario)+'.csv');
    iflimup(9,:) = iflimup(9,:);
    iflimdn = readmatrix('Data/iflim/iflimdn_'+string(year)+'_'+string(scenario)+'.csv');
    ratioup = iflimup(1:12,:)./Lup;
    ratiodn = iflimdn(1:12,:)./Ldn;
    ls1 = readmatrix('Baseline_v4/Scenario'+string(1)+'/loadshed_'+string(year)+'.csv');
    ls2 = readmatrix('Baseline_v4/Scenario'+string(2)+'/loadshed_'+string(year)+'.csv');
    loadshed1 = sum(ls1(4:49,:),1);
    loadshed2 = sum(ls2(4:49,:),1);
    loadshedwithderatio = (ratioup(5,:)<1).*(loadshed1-loadshed2);
    plot(loadshedwithderatio,'-o')
    hold on
end
dd = 214;
starttime = 1+dd*24;
nt=5*24;
figure(4)
ax1 = subplot(2,1,1);

plot(loadshed1(starttime:starttime+nt-1),'LineWidth',2)
hold on
plot(loadshed2(starttime:starttime+nt-1),'LineWidth',2)
legend('Dynamic rating','Static rating')
xlabel('Hours')
ylabel('Load Shedding (MW)')
ax = gca;
ax.FontSize = 20; 
ax2 = subplot(2,1,2);
% plot(1:nt,hyhdc(starttime:starttime+nt-1),'LineWidth',2,'Color','#0072BD')
% hold on
plot(1:nt,ratioup(5,starttime:starttime+nt-1)*100,'LineWidth',2)
hold on
% plot(1:nt,ratiodn(5,starttime:starttime+nt-1)*100,'LineWidth',2)
% hold on
grid
xlim([0,nt])
% legend('IF lim up','IF lim down')
xlabel('Hours')
ylabel('Interface Limit %')
ax = gca;
ax.FontSize = 20; 
linkaxes([ax1,ax2],'x')
set(gcf, 'Position', [618,404,1559,770]);
