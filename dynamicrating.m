function LimMVA = dynamicrating(V,D,R25,R50,R75,N,Tamb,delta,windv)
% D = 3.04/100;
    %,3.04,3.62,2.77,1.83]/100;%Diameter
% delta = 1000; % solar radiation, to be changed
Tcond = 75+273.1; %conductor temperature, to be changed;
Tamb = Tamb+273.1; %Ambient temperature, to be changed
eps = 0.7;% emissivity of conductor
sigma = 5.670e-8; %Stefan-Boltzmann constant
temp = 200:50:600;
vsample = [7.59,11.44,15.89,20.92,26.41,32.39,38.79,45.57,52.69]*10^(-6);
tcsample = [18.1,22.3,36.3,30.0,33.8,37.3,40.7,43.9,46.9]*10^(-3);
prsample = [0.737,0.720,0.707,0.700,0.690,0.686,0.684,0.683,0.685];
a_s = 0.9; %absorptivity of conductor surface
% V = 345; %voltage
% R25 = 0.061/1000;R50 = 0.067/1000;R75 = 0.073/1000;N=2;

% calculate hbar
% windv = 0.61; %wind speed, to be changed
% v = Dyvis(0.5*(Tcond+Tamb));
v = interp1(temp,vsample,0.5*(Tcond+Tamb));
Pr = interp1(temp,prsample,0.5*(Tcond+Tamb));
k = interp1(temp,tcsample,0.5*(Tcond+Tamb));
hbar = 0.3+(0.62*(windv*D/v)^(1/2)*Pr^(1/3))/(1+(0.4/Pr)^(2/3))^(1/4)*(1+(windv*D/v/282000)^(5/8))^(4/5)*k/D;


R = RTcond(Tcond,R25,R50,R75,N);



I = sqrt((pi*hbar*D*(Tcond-Tamb)+pi*eps*sigma*D*(Tcond^4 - Tamb^4) - delta*D*a_s)/R);
LimMVA = I*V*10^3*sqrt(3)/10^6;

%calculate R(Tcond)

function R = RTcond(Tcond,R25,R50,R75,N)
Tcond = Tcond - 273.1;
    if Tcond >=0 && Tcond <=50
        R = (R25+(R25-R50)/(25-50)*(Tcond-25))/N;
    else
        R = (R50+(R50-R75)/(50-75)*(Tcond-50))/N;
    end
end
end