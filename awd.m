close all; clear all;
% WARTOŚCI NOMINALNE
qg0 = 6000;   % 6[kW]
qg0t = 60;    % [s] czas pełnego nagrzania się kaloryfera
qgInit = 0;   % [W] domyślnie na początku kaloryfer jest zimny
fp0 = 0.2;    % [m^3/s]         
Vwew = 15;    % [m^3]
Vp = 7.5;     % [m^3]
cp = 1e3;     % [J/(kg*K)] ciepło właściwe powietrza
rop = 1.2;    % [kg/m^3] gęstość powietrza
Cvw = cp*rop*Vwew;
Cvp = cp*rop*Vp;
crf0 = cp*rop*fp0; % iloczyn: cp*rop*fp0
% WSPÓŁCZYNIKI Kw oraz Kp
Kw = 20; % przenikalność cieplna ścian na parterze
Kp = 50; % przenikalność cieplna poddasza na parterze
% zapytaj użytkownika o temperatury
Twew0 = input('Jaka jest temperatura wewnątrz (parter)? [*C] : '); 
Twew1 = input('Jaka ma być temperatura wewnątrz (parter)? [*C] : ');
Tzew0 = input('Jaka temperatura jest na zewnątrz? [*C] : ');
Tzew1 = input('Jaka będzie temperatura na zewnątrz za godzinę? [*C] : ');
Tp0 = Twew0*0.35; % [*C]
qgPowerDelta = 0.01;
for qgPower = 0 : qgPowerDelta : 1
    % macierze do równań stanu
    A = [(-Kw-crf0)/Cvw, crf0/Cvw; crf0/Cvp, (-Kp-crf0)/Cvp];
    B = [1/Cvw, Kw/Cvw; 0, Kp/Cvp];
    C = [1, 0; 0, 1];
    D = [0, 0; 0, 0];
    % SYMULACJA ----------------------------------------------------
    Stime = 7200;         % czas symulacji
    MaxSkok = 10;         % maksymalny krok obliczeń
    Errtime = 1e-5;       % błąd obliczeniowy
    opcjeRS = simget('rowstan');
    opcjeRS = simset(opcjeRS, 'MaxStep', MaxSkok, 'RelTol', Errtime, 'FixedStep',1);
    [trs] = sim('rowstan', Stime, opcjeRS); % trs - czas symulacji
    
    Twew = rsTwew(end);
    if Twew >= Twew1
        Tp = rsTp(end);
        break;
    end
end
waitTimeIndex = find(rsTwew(4:end)>=Twew1,1) +3;
if waitTimeIndex == []
    error('Za niska maksymalna moc grzejnika, aby spełnić żądanie');
end
waitTime = floor(trs(waitTimeIndex));
% PLOTOWANIE --------------------------------------------------
scrsz = get(0,'ScreenSize'); % screen size
figure;
set(gcf,'Name','Równania stanu temperatury w domu');
set(gcf,'numbertitle','off');
hold on;
grid on;
rsTwew = rsTwew(1:length(trs));
rsTp = rsTp(1:length(trs));
plot(trs,rsTwew,'.-b');
plot(trs,rsTp,'.-r');
line([trs(waitTimeIndex) trs(waitTimeIndex)],[0 rsTwew(waitTimeIndex)]);
title({['Zadana temperatura: ',num2str(Twew1), ...
    ' st. Celsjusza, Moc ogrzewania: ', num2str(qg0*qgPower), 'W'] ...
    ['Tzew0=', num2str(Tzew0),', Tzew1=', num2str(Tzew1),' oraz fp0=', num2str(fp0)]});
ymin = min(rsTp) - 1;
ymin = min(0,ymin);
ymax = max(rsTwew) + 5;
axis([0 Stime ymin ymax]);
ylabel('Temperatura [*C]');
xlabel('Czas [s]');
legend('Temperatura na parterze','Temperatura na poddaszu');
 
fprintf('Ustaw ogrzewanie na %d%% (%dW)\n', uint8(qgPower*100), uint16(qg0*qgPower));
fprintf('Wtedy żądana temperatura zostanie osiągnięta już po %s\n', toTimeString(waitTime));
