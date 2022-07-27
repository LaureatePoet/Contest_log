% 2019_A Q3_2 方差改进版 测试用:可以显示整个周期完整
% time: 2019/09/14 15:25
% author: null

% 
clear all;
Rho_fuel = 0.850; % unit mg/mm^3
P_A = 160; % unit is MPa
P_tube=100; % unit is MPa. Pressure of high pressure oil pipe in initial state
C= 0.85 ; %Flow Coefficient
A_in= pi*0.7^2; % Area of the small hole. unit is mm^2


% Needle valve motion data
load('Needle.mat');
% Cam edge data
load('Cam.mat');

V_tube=pi*500*5^2;
Rho_160 = exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*160)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 160 MPa
Rho_0_5= exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*0.5)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 0.5 MPa
i=1;
sign_break = 0;
for omega=30*pi % unit is rad/s . Cam angular velocity
    a=0;
    b=0.01;
    c=1000*(2*pi)/omega;
    n=floor((c-a)/b + 1);
    P_aims=100*ones(n,1);
    sign_break = 0;
    for t1=13.2 % Range: 0~100, indicating the starting working time of the injector during the period T=100ms.
        k=1;
        Rho_fuel_i(k,1)=Rho_fuel;
        P_tube_i(k,1)= 100;
        for t=a:b:c % unit is ms. Simulate the entire working time frame
            theta(k,1)=mod(pi+omega*t/1000,2*pi); % The polar angle of the current moment cam. (unit is rad)
            n_R= floor(theta(k,1)*100); % Theta index in Cam data
            R_theta = (Cam(mod(n_R+1,628)+1,2)-Cam(mod(n_R,628)+1,2))*(theta(k,1)*100-n_R)+Cam(mod(n_R,628)+1,2) ; % The diameter of the current moment cam. (unit is mm)
            V_pump(k,1) = 20+pi*(5/2)^2*(Cam(1,2)-R_theta); % Relationship between oil pump volume and pole diameter.

            % Fuel injector 1
            Needle_t1=floor(100*mod((100-t1)+t,100)+1); %Index of time t in Needle data
            if Needle_t1<247
                h_Needle1(k,1)=Needle(Needle_t1,2); % h is the Lift of Needle.
            else
                h_Needle1(k,1)=0;
            end

            % Fuel injector 2
%             Needle_t2=floor(100*mod((100-t2)+t,100)+1); %Index of time t in Needle data
%             if Needle_t2<247
%                 h_Needle2(k,1)=Needle(Needle_t2,2); % h is the Lift of Needle.
%             else
%                 h_Needle2(k,1)=0;
%             end

            if k==1
                Rho_pump_i(k,1)= Rho_0_5; 
            else
                if floor(100*mod(t,1000*(2*pi)/omega))==0 % High pressure oil pump replenishment operation.
                    Rho_pump_i(k,1)= Rho_0_5;
                else
                    Rho_pump_i(k,1)=Rho_pump_i(k-1,1)*V_pump(k-1,1)/V_pump(k,1); % Fuel density in the oil pump at the current time.
                end
            end
            P_pump_i(k,1) = log(-(log(Rho_pump_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
            if k>1 
                if Rho_pump_i(k,1)>Rho_fuel_i(k-1,1) 
                    m_Q_in(k,1)=C*A_in*sqrt(2*(P_pump_i(k,1) - P_tube_i(k-1,1))*Rho_pump_i(k,1))*b;
                    Rho_pump_i(k,1)=(Rho_pump_i(k,1)*V_pump(k,1)-m_Q_in(k,1))/V_pump(k,1);
                    P_pump_i(k,1) = log(-(log(Rho_pump_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
                else
                    m_Q_in(k,1)=0;
                end
                A_out1(k,1) = pi*((h_Needle1(k,1)+1.25/(tan(pi*9/180)))*tan(pi*9/180))^2-pi*1.25^2;
                %A_out2(k,1) = pi*((h_Needle2(k,1)+1.25/(tan(pi*9/180)))*tan(pi*9/180))^2-pi*1.25^2;
                if P_tube_i(k-1,1)>12 
                    m_Q_out(k,1) = C*A_out1(k,1)*sqrt(2*(P_tube_i(k-1,1) - 12)*Rho_fuel_i(k-1,1))*b;
                else
                    m_Q_out(k,1) = 0;
                end
                Rho_fuel_i(k,1)=(Rho_fuel_i(k-1,1)*V_tube-m_Q_out(k,1)+m_Q_in(k,1))/V_tube;
                P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
            end
            if abs(P_tube_i(k,1)-100)<= -5 % If the deviation is greater than 5, the loop is jumped out and the next traversal is performed.
                sign_break=1;
                break;
            end
            k=k+1;
        end
        if sign_break==1
            sign_break=0;
            continue;
        end
        variance=sum((P_tube_i-P_aims).^2)/n;
        data(i,1)=omega/pi;
        data(i,2)=t1;
%         data(i,3)=t2;
        data(i,4)=variance;
        i=i+1;
        hold on
        plot(a:b:c,P_tube_i)
        % ylim([0,200]);
        
    end
end
