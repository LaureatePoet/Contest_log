% 2019_A Q1_(2)
% time: 2019/09/13 10:20
% author: null

% Task: keep 150MPa

clear all;
Rho_fuel = 0.850; % unit mg/mm^3
P_A = 160; % unit is MPa
P_tube=100; % unit is MPa. Pressure of high pressure oil pipe in initial state
C= 0.85 ; %Flow Coefficient
A= pi*0.7^2; % Area of the small hole. unit is mm^2

V_tube=pi*500*5^2;
Rho_160 =exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*160)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 160 MPa
Rho_150 = exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*150)-exp(-0.39)) + log(0.85));
i=1;
for T=0.71 % unit is ms. The time each time the one-way valve is opened
    a=0;
    b=0.01;
    c=200000;
    n=(c-a)/b + 1;
    P_aims=150*ones(n,1);
    %Rho_fuel_i=zeros(n+1,1);
    %P_tube_i=zeros(n+1,1);
    k=1;
    Rho_fuel_i(k,1)=Rho_150;
    for t=a:b:c % unit is ms. Simulate the entire working time frame
        if k==1
            P_tube_i(1,1)=150;
        else
            P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel)-((exp(-0.39))/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
        end
        
        t_fuel_in=mod(t,T+10); % Fuel s cycle time
        t_fuel_out=mod(t,100); % Fuel injection cycle time
        if t_fuel_in>0 && t_fuel_in<=T && P_tube_i(k,1) <=160
            Q_in = C*A*sqrt(2*(160-P_tube_i(k,1))/Rho_160)*b;
        else
            Q_in=0;
        end

        if 0<t_fuel_out && t_fuel_out < 0.2 
           Q_out = 100*t_fuel_out * b;
        elseif 0.2 <= t_fuel_out && t_fuel_out<2.2
           Q_out = 20 * b;
        elseif 2.2 <= t_fuel_out && t_fuel_out<=2.4
           Q_out = (-100*t_fuel_out+240) * b;
        else
           Q_out = 0;
        end
        
        Rho_fuel_i(k+1,1) = (Rho_fuel_i(k,1) * (V_tube- Q_out) + Rho_160 * Q_in) /V_tube;
        
        k=k+1;
    end
    variance=sum((P_tube_i-P_aims).^2);
    data(i,1)=T;
    data(i,2)=variance;
    i=i+1;
	plot(a:b:c,P_tube_i)
    ylim([90,160]);
end
