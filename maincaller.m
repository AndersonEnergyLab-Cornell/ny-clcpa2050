function maincaller(input)
    DU_f = readmatrix('DU_factors_v3_300.csv');
    DU_factors = sortrows(DU_f,7);
    if input == 0
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
        s1 = DU_factors(input,7);
        bd_rateAE= DU_factors(input,2);
%         bd_rateFI= DU_factors(input,3);
%         bd_rateJK= DU_factors(input,4);
        ev_rateAE = DU_factors(input,3);
%         ev_rateFI = DU_factors(input,6);
%         ev_rateJK = DU_factors(input,7);
        wind_cap = DU_factors(input,4);
        solar_cap = DU_factors(input,5);
        batt_cap = DU_factors(input,6);
    end
    
%     main(s1,bd_rateAE,bd_rateFI,bd_rateJK,ev_rateAE,ev_rateFI,ev_rateJK,wind_cap,solar_cap,batt_cap,input)
main(s1,bd_rateAE,ev_rateAE,wind_cap,solar_cap,batt_cap,input)