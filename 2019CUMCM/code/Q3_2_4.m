% 2019_A Q3_2_4 殷振豪新方案，在油泵给油管加油后，压力P<100后，减压阀开始工作，工作至高压油管压力P=100结束。
% time: 2019/09/14 15:25
% author: null

% 
clear all;
Rho_fuel = 0.850; % unit mg/mm^3
C= 0.85 ; %Flow Coefficient
A_in= pi*0.7^2; % Area of the small hole. unit is mm^2
A_D= pi*0.7^2; % The area of the D port of the pressure reducing valve

% Needle valve motion data
load('Needle.mat');
% Cam edge data
load('Cam.mat');

V_tube=pi*500*5^2;
Rho_160 = exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*160)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 160 MPa
Rho_0_5= exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*0.5)-exp(-0.39)) + log(0.85)); % Fuel density at a pressure of 0.5 MPa
i=1;
data=zeros(10000,1);
for omega=1600/60*2*pi % unit is rad/s . Cam angular velocity
    clear Rho_fuel_i P_tube_i theta V_pump h_Needle1 h_Needle2 Rho_pump_i P_pump_i m_Q_in A_out1 A_out2 m_Q_out m_Q_outD
    a=0;
    b=0.01;
    c=1000*(2*pi)/omega;
    n=floor((c-a)/b) + 1;
    P_aims=100;
    sign_break = 0;
    % 分配内存
    Rho_fuel_i=zeros(n,1);
    P_tube_i=zeros(n,1);
    theta=zeros(n,1);
    V_pump=zeros(n,1);
    h_Needle1=zeros(n,1);
    h_Needle2=zeros(n,1);
    Rho_pump_i=zeros(n,1);
    P_pump_i=zeros(n,1);
    m_Q_in=zeros(n,1);
    A_out1=zeros(n,1);
    A_out2=zeros(n,1);
    m_Q_out=zeros(n,1);
    m_Q_outD=zeros(n,1);
    
    for t1=0:0.01:100 % Range: 0~100, indicating the starting working time of the injector during the period T=100ms.
        k=1;
        Rho_fuel_i(k,1)=Rho_fuel;
        P_tube_i(k,1)= 100;
        sign_prv=0;
        for t=a:b:c % unit is ms. Simulate the entire working time frame
            theta(k,1)=mod(pi+omega*t/1000,2*pi); % The polar angle of the current moment cam. (unit is rad)
            n_R= floor(theta(k,1)*100); % Theta index in Cam data
            R_theta = (Cam(mod(n_R+1,628)+1,2)-Cam(mod(n_R,628)+1,2))*(theta(k,1)*100-n_R)+Cam(mod(n_R,628)+1,2) ; % The diameter of the current moment cam. (unit is mm)
            V_pump(k,1) = 20+pi*(5/2)^2*(Cam(1,2)-R_theta); % Relationship between oil pump volume and pole diameter.

            % Fuel injector 1
            Needle_t1=floor(mod(100*((100-t1)+t),100*100)+1); %Index of time t in Needle data
            if Needle_t1<247
                h_Needle1(k,1)=Needle(Needle_t1,2); % h is the Lift of Needle.
            else
                h_Needle1(k,1)=0;
            end

            % Fuel injector 2
%             Needle_t2=floor(mod(100*((100-t2)+t),100*100)+1); %Index of time t in Needle data
%             if Needle_t2<247
%                 h_Needle2(k,1)=Needle(Needle_t2,2); % h is the Lift of Needle.
%             else
%                 h_Needle2(k,1)=0;
%             end

            if k==1
                Rho_pump_i(k,1)= Rho_0_5; 
            else
                if floor(mod(100*t,100*1000*(2*pi)/omega))==0 % High pressure oil pump replenishment operation.
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
                
                % 检测P<100 MPa
                if P_pump_i(k,1)-P_pump_i(k-1,1)<0 && P_pump_i(k,1)<100 && sign_prv==0
                    sign_prv=1;
                end
                
                % 根据sign_prv判断减压阀释放多少燃油
                if sign_prv==1 && P_tube_i(k-1,1)>100
                    m_Q_outD(k,1)=C*A_D*sqrt(2*(P_tube_i(k-1,1) - 0.5)*Rho_fuel_i(k-1,1))*b;
                else
                    m_Q_outD(k,1)=0;
                end
                A_out1(k,1) = pi*((h_Needle1(k,1)+1.25/(tan(pi*9/180)))*tan(pi*9/180))^2-pi*1.25^2;

%                 A_out2(k,1) = pi*((h_Needle2(k,1)+1.25/(tan(pi*9/180)))*tan(pi*9/180))^2-pi*1.25^2;
                if P_tube_i(k-1,1)>12 
                    m_Q_out(k,1) = C*A_out1(k,1)*sqrt(2*(P_tube_i(k-1,1) - 12)*Rho_fuel_i(k-1,1))*b;
                else
                    m_Q_out(k,1) = 0;
                end
                Rho_fuel_i(k,1)=(Rho_fuel_i(k-1,1)*V_tube-m_Q_out(k,1)-m_Q_outD(k,1)+m_Q_in(k,1))/V_tube;
                P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
            end
            if abs(P_tube_i(k,1)-100) >1.5 % If the deviation is greater than 5, the loop is jumped out and the next traversal is performed.
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
        data(i,3)=variance;
        i=i+1;
%         plot(a:b:a+b*(length(P_tube_i)-1),P_tube_i)
%         hold on
%         ylim([0,200]);
    end
end
