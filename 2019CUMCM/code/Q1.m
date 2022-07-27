% 2019_A
% time: 2019/09/12 21:50
% author: null

% Task: keep 100MPa
clear all;
Rho_fuel = 0.850; % unit mg/mm^3
C= 0.85 ; %Flow Coefficient
A= pi*0.7^2; % Area of the small hole. unit is mm^2

V_tube=pi*500*5^2;
Rho_160 = exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*160)-exp(-0.39)) + log(0.85))  ; % Fuel density at a pressure of 160 MPa
i=1;
data=zeros(10000,1);
for T=0.289 % unit is ms. The time each time the one-way valve is opened
    a=0;
    b=0.01;
    c=100000;
    n=(c-a)/b + 1;
    P_aims=100;
    Rho_fuel_i=zeros(n,1);
    P_tube_i=zeros(n,1);
    k=1;
    Rho_fuel_i(k,1)=Rho_fuel;
    for t=a:b:c % unit is ms. Simulate the entire working time frame
        
        P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
        
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
    plot(a:b:c,P_tube_i);
    i=i+1;
end
