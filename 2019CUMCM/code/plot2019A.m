% 2019_A Q3_2_4 殷振豪新方案，在油泵给油管加油后，压力P<100后，减压阀开始工作，工作至高压油管压力P=100结束。
% time: 2019/09/14 15:25
% author: null

% 
clear all;
Rho_fuel = 0.850; % unit mg/mm^3
P_A = 160; % unit is MPa
P_tube=100; % unit is MPa. Pressure of high pressure oil pipe in initial state
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
clear Rho_fuel_i P_tube_i theta V_pump h_Needle1 h_Needle2 Rho_pump_i P_pump_i m_Q_in A_out1 A_out2 m_Q_out m_Q_outD
a=0;
b=0.01;
c=1000;
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

for pp=101:105
    k=1;
    Rho_fuel_i(k,1)=exp(-(1/(0.0039*exp(7.31)))*(exp(-0.0039*pp)-exp(-0.39)) + log(0.85));;
    P_tube_i(k,1)= pp;
    sign_prv=0;
    for t =a:b:c
        if k>1
            if t-a>10 && sign_prv==0
            sign_prv=1;
            end

            if sign_prv==1 && P_tube_i(k-1,1)>100
            m_Q_outD(k,1)=C*A_D*sqrt(2*(P_tube_i(k-1,1) - 0.5)*Rho_fuel_i(k-1,1))*b;
            else
            m_Q_outD(k,1)=0;
            end
            Rho_fuel_i(k,1)=(Rho_fuel_i(k-1,1)*V_tube-m_Q_outD(k,1))/V_tube;
            P_tube_i(k,1) = log(-(log(Rho_fuel_i(k,1)/Rho_fuel) - (exp(-0.39)/(0.0039*exp(7.31))))*0.0039*exp(7.31))*(-1/0.0039);
        end
        k=k+1;
    end
    variance=sum((P_tube_i-P_aims).^2)/n;
%     data(i,1)=omega/pi;
%     data(i,2)=t1;
%     data(i,3)=variance;
    i=i+1;
    plot(a:b:a+b*(length(P_tube_i)-1),P_tube_i)
    hold on
    grid on
    title('减压阀对不同压力系统作用效果图');
    ylabel('压力P （MPa）');
    xlabel('时间t （ms）');
    xlim([0,30]);
    ylim([98,107]);
end


