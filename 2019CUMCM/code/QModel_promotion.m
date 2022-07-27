% 2019_A 模型推广:胶州湾
% time: 2019/09/14 10:30
% author: null

% Task: 造个新油泵！
clear all;
Rho_fuel = 0.850; % unit mg/mm^3
P_tube=100; % unit is MPa. Pressure of high pressure oil pipe in initial state
C= 0.85 ; %Flow Coefficient
A_in= pi*0.7^2; % Area of the small hole. unit is mm^2

% Create a tube
L_tube=320; % unit mm
R_tube=1.5; % unit mm

% Needle valve motion data
load('Needle.mat');

% Create an oil pump
omega_pump=1250/60*2*pi;% rad/s
Lift_pump=10.98; % mm
r_pump=7.5; % mm
L_pump=26.06; % mm
P_pump_low=10; % MPa

Rho_10=exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*10)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 10 MPa

V_tube=pi*L_tube*R_tube^2;

Rho_170 = exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*170)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 160 MPa
Rho_0_5= exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*0.5)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 0.5 MPa
i=1;
sign_break = 0;
data=zeros(10000,1);
for omega=omega_pump % unit is rad/s . Cam angular velocity
    clear P_pump_i P_tube_i Rho_fuel_i Rho_pump_i theta V_pump m_Q_in m_Q_out h_Needle1 A_out1
    a=0;
    b=0.01;
    c=10000;
    n=floor((c-a)/b) + 1;
    P_aims=170;
    % 分配内存
    Rho_fuel_i=zeros(n,1);
    P_tube_i=zeros(n,1);
    theta=zeros(n,1);
    V_pump=zeros(n,1);
    h_Needle=zeros(n,1);
    Rho_pump_i=zeros(n,1);
    P_pump_i=zeros(n,1);
    h_theta=zeros(n,1);
    m_Q_in=zeros(n,1);
    A_out=zeros(n,1);
    m_Q_out=zeros(n,1);
    for T_Need=60
        k=1;
        Rho_fuel_i(k,1)=Rho_170;
        P_tube_i(k,1)= 170;
        for t=a:b:c % unit is ms. Simulate the entire working time frame
            theta(k,1)=mod(omega*t/1000,2*pi); % The polar angle of the current moment cam. (unit is rad)
            
            h_theta(k,1)= (Lift_pump/2)*sin(theta(k,1)-pi/2)+Lift_pump/2;
            V_pump(k,1) = pi*(L_pump-h_theta(k,1))*r_pump^2  ; % Relationship between oil pump volume and pole diameter.

            if k==1
                Rho_pump_i(k,1)= Rho_10; 
            else
                if floor(mod(100*t,100*1000*(2*pi)/omega))==0
                    Rho_pump_i(k,1)= Rho_10;
                else
                    Rho_pump_i(k,1)=Rho_pump_i(k-1,1)*V_pump(k-1,1)/V_pump(k,1); % Fuel density in the oil pump at the current time.
                end
            end
            P_pump_i(k,1) = log(-(log(Rho_pump_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
            if k>1 
                if Rho_pump_i(k,1)>Rho_fuel_i(k-1,1) % Description will supply oil.
                    m_Q_in(k,1)=C*A_in*sqrt(2*(P_pump_i(k,1) - P_tube_i(k-1,1))*Rho_pump_i(k,1))*b;
                    Rho_pump_i(k,1)=(Rho_pump_i(k,1)*V_pump(k,1)-m_Q_in(k,1))/V_pump(k,1);
                    P_pump_i(k,1) = log(-(log(Rho_pump_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
                else
                    m_Q_in(k,1)=0;
                end
                Needle_t=floor(mod(100*t,100*T_Need)+1); %Index of time t in Needle data
                if Needle_t<247 
                    h_Needle(k,1)=Needle(Needle_t,2); % h is the Lift of Needle.
                else
                    h_Needle(k,1)=0;
                end
                A_out(k,1) = pi*((h_Needle(k,1)+1.25/(tan(pi*9/180)))*tan(pi*9/180))^2-pi*1.25^2;
                if P_tube_i(k-1,1)>12 
                    m_Q_out(k,1) = 2* C*A_out(k,1)*sqrt(2*(P_tube_i(k-1,1) - 12)*Rho_fuel_i(k-1,1))*b;
                else
                    m_Q_out(k,1) = 0;
                end
                Rho_fuel_i(k,1)=(Rho_fuel_i(k-1,1)*V_tube-m_Q_out(k,1)+m_Q_in(k,1))/V_tube;
                P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
            end
            if abs( P_tube_i(k,1) - 170) > 10000000
                sign_break=1;
                break;
            end
            k=k+1;
        end
        if sign_break == 1
            sign_break = 0;
            continue;
        end
        variance=sum((P_tube_i-P_aims).^2);
        data(i,1)=omega/pi;
        data(i,2)=T_Need;
        data(i,3)=variance;
        i=i+1;
        plot(a:b:c,P_tube_i);
        hold on;
        % ylim([0,200]);
    end
end
