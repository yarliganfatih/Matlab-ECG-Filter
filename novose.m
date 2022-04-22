clear,clc
EKGD = load('inputs/input3.mat');
EKG = EKGD.val;

t=1/10000:1/10000:1;
gs=0.2*sin(2*pi*50*t);
%gs=10000*sin(2*pi*50*t);

%% I. Derivation
figure
subplot(3,1,1);
EKG(1,:) = EKG(1,:)./50000;
%EKG(1,:) = -EKG(1,:); %reverse
EKG(1,:) = EKG(1,:) + gs; %filtered
hold on
plot(EKG(1,:));
hold off
avg1=mean(EKG(1,:))
hline = refline(0, avg1); %isoelectric
hline.Color = 'k';


if avg1<0
    status1="Positive";
    average1=mean(allpeaksp(EKG(1,:),avg1));
    peakspX = allpeakspX(EKG(1,:),avg1);
    V1 = FindQRSandV(EKG(1,:),avg1,peakspX)
else
    status1="Negative";
    average1=mean(allpeaksn(-EKG(1,:),avg1));
    peaksnX = allpeaksnX(EKG(1,:),avg1);
    V1 = FindQRSandVn(EKG(1,:),avg1,peaksnX)
end
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
title('I. Derivation','FontSize', 16)
annotation('textbox',[.91 .7 .1 .2],'String','Average','EdgeColor','none')
annotation('textbox',[.91 .65 .1 .2],'String',average1,'EdgeColor','none')
annotation('textbox',[.91 .6 .1 .2],'String',status1,'EdgeColor','none')

%% aVF Derivation
subplot(3,1,2);
EKG(6,:) = EKG(6,:)./50000;
%EKG(6,:) = -EKG(6,:); %reverse
EKG(6,:) = EKG(6,:) + gs; %filtered
hold on
plot(EKG(6,:));
hold off
avg2=mean(EKG(6,:));
hline = refline(0, avg2); %isoelectric
hline.Color = 'k';


if avg2<0
    status2="Positive";
    average2=mean(allpeaksp(EKG(6,:),avg2));
    peakspX = allpeakspX(EKG(6,:),avg2);
    VaVF = FindQRSandV(EKG(6,:),avg2,peakspX)
else
    status2="Negative";
    average2=mean(allpeaksn(-EKG(6,:),avg2));
    peaksnX = allpeaksnX(EKG(6,:),avg2);
    VaVF = FindQRSandVn(EKG(6,:),avg2,peaksnX)
end
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
title('aVF Derivation','FontSize', 16)
annotation('textbox',[.91 .22 .1 .4],'String','Average','EdgeColor','none')
annotation('textbox',[.91 .17 .1 .4],'String',average2,'EdgeColor','none')
annotation('textbox',[.91 .12 .1 .4],'String',status2,'EdgeColor','none')

%% Decide Statements
if status1=="Positive"
    if status2=="Positive"
        status3="Normal Axis Deviation";
    else
        status3="Left Axis Deviation";
    end
else
    if status2=="Positive"
        status3="Right Axis Deviation";
    else
        status3="Extreme Axis Deviation";
    end
end
annotation('textbox',[.2 .1 .0 .2],'String',status3,'EdgeColor','none')

%% Calculate Degree
divideV = VaVF / V1
divideC = 2 / sqrt(3)
Degree = atand(divideV*divideC)

%if the signs are different
if(Degree/VaVF<0)
    if Degree<0
        Degree = Degree + 180
    elseif Degree>0
        Degree = Degree - 180
    end
end

annotation('textbox',[.45 .1 .0 .2],'String',['Degree ',num2str(Degree)],'EdgeColor','none')

if Degree > -30 & Degree < 90 
    status4 = "Normal Axis Deviation"
elseif Degree > 90 & Degree < 180
    status4 = "Right Axis Deviation"
elseif Degree > -90 & Degree <= -30
    status4 = "Left Axis Deviation"
elseif Degree >= -180 & Degree < -90
    status4 = "Extreme Axis Deviation"
end
    
annotation('textbox',[.6 .1 .0 .2],'String',status4,'EdgeColor','none')

function pk = allpeaksp(y, avg)
  Peaks=[];
  for k = 2:length(y)-1
      if y(k) > abs(avg)/4*3 %avg
         if y(k) > y(k-1)
             if y(k) > y(k+1)
                 Peaks=[Peaks y(k)];
             end
         end
      end
  end
  pk = Peaks;
end

function pk = allpeaksn(y, avg)
  Peaks=[];
  for k = 2:length(y)-1
      if y(k) < -abs(avg)/4*3 %avg
         if y(k) < y(k-1)
             if y(k) < y(k+1)
                 Peaks=[Peaks y(k)];
             end
         end
      end
  end
  pk = Peaks;
end

function pk = allpeakspX(y, avg)
  Peaks=[];
  for k = 2:length(y)-1
      if y(k) > abs(avg)/4*3 %avg
         if y(k) > y(k-1)
             if y(k) > y(k+1)
                 Peaks=[Peaks k];
             end
         end
      end
  end
  pk = Peaks;
end

function pk = allpeaksnX(y, avg)
  Peaks=[];
  for k = 2:length(y)-1
      if y(k) < -abs(avg)/4*3 %avg
         if y(k) < y(k-1)
             if y(k) < y(k+1)
                 Peaks=[Peaks k];
             end
         end
      end
  end
  pk = Peaks;
end

function pk = FindQRSandV(y, avg, peakspX)
  AllQx=[];
  AllQy=[];
  AllRx=peakspX;
  AllRy=y(peakspX);
  AllSx=[];
  AllSy=[];
  
  for m = 1:length(peakspX)
      
      interval = 5;
      
      %Calculate Q
      iq=20;
      while 1
          k=peakspX(m)-iq;
          %y(k)
          if k-interval<1
              AllSx=[AllSx k];
              AllSy=[AllSy y(k)];
              break
          else
              if y(k) < avg %0
                 if y(k) < y(k-interval)
                     if y(k) < y(k+interval)
                        AllQx=[AllQx k];
                        AllQy=[AllQy y(k)];
                        break
                     end
                 end
              end
          end
          iq=iq+interval;
      end
      
      %Calculate S
      is=20;
      while 1
          k=peakspX(m)+is;
          if k-interval<1
              AllSx=[AllSx k];
              AllSy=[AllSy y(k)];
              break
          end
          if y(k) < avg %0
             if y(k) < y(k-interval)
                 if y(k) < y(k+interval)
                    AllSx=[AllSx k];
                    AllSy=[AllSy y(k)];
                    break
                 end
             end
          end
          is=is+interval;
      end
  end
  
  %Display points
  X = [AllQx; AllRx; AllSx];
  Y = [AllQy; AllRy; AllSy];
  
  text(AllQx,AllQy,['→Q']);
  text(AllRx,AllRy,['→R']);
  text(AllSx,AllSy,['→S']);
  
  %Calculate means
  meanQ = -abs(mean(AllQy)-avg)
  meanR = abs(mean(AllRy)-avg)
  meanS = -abs(mean(AllSy)-avg)
  
  
  V = meanR - (meanQ + meanS);
  
  pk=V;
end


function pk = FindQRSandVn(y, avg, peakspX)
  AllQx=[];
  AllQy=[];
  AllRx=peakspX;
  AllRy=y(peakspX);
  AllSx=[];
  AllSy=[];
  
  for m = 1:length(peakspX)
      
      interval = 5;
      
      %Calculate Q
      iq=20;
      while 1
          k=peakspX(m)-iq;
          %y(k)
          if k-interval<1
              AllSx=[AllSx k];
              AllSy=[AllSy y(k)];
              break
          else
              if y(k) > avg %0
                 if y(k) > y(k-interval)
                     if y(k) > y(k+interval)
                        AllQx=[AllQx k];
                        AllQy=[AllQy y(k)];
                        break
                     end
                 end
              end
          end
          iq=iq+interval;
      end
      
      %Calculate S
      is=20;
      while 1
          k=peakspX(m)+is;
          if k-interval<1
              AllSx=[AllSx k];
              AllSy=[AllSy y(k)];
              break
          end
          if y(k) > avg %0
             if y(k) > y(k-interval)
                 if y(k) > y(k+interval)
                    AllSx=[AllSx k];
                    AllSy=[AllSy y(k)];
                    break
                 end
             end
          end
          is=is+interval;
      end
  end
  
  %Display points
  X = [AllQx; AllRx; AllSx];
  Y = [AllQy; AllRy; AllSy];
  
  text(AllQx,AllQy,['→Q']);
  text(AllRx,AllRy,['→R']);
  text(AllSx,AllSy,['→S']);
  
  %Calculate means
  meanQ = abs(mean(AllQy)-avg)
  meanR = -abs(mean(AllRy)-avg)
  meanS = abs(mean(AllSy)-avg)
  
  
  V = meanR - (meanQ + meanS);
  
  pk=V;
end

%% [TR]
% Q ve S noktalarının her zaman izoelektrik çizginin altında olacağını varsayıyorum
% Q R S noktaları, izoelektrik çizgi ile aralarındaki mesafe hesaplanır. (mutlak değer)
% Noktalar hesaplanırken hata payını düşürmek için interval değerini arttırabilir. (fazlası bozar)