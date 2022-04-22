clear,clc
EKGD = load('inputs/input3.mat');
EKG = EKGD.val;

t=1/10000:1/10000:1;
gs=0.2*sin(2*pi*50*t);
%gs=10000*sin(2*pi*50*t);

figure
subplot(2,1,1);
EKG(1,:) = EKG(1,:)./50000;
%EKG(1,:) = -EKG(1,:); %reverse
EKG(1,:) = EKG(1,:) + gs; %filtered
hold on
plot(EKG(1,:));
hold off
avg1=mean(EKG(1,:));
hline = refline(0, avg1); %isoelectric
hline.Color = 'k';
if avg1<0
    status1="Positive";
    avarage1=mean(allpeaksp(EKG(1,:),avg1));
else
    status1="Negative";
    avarage1=mean(allpeaksn(-EKG(1,:),avg1));
end
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
title('I. Derivation','FontSize', 16)
annotation('textbox',[.91 .7 .1 .2],'String','Average','EdgeColor','none')
annotation('textbox',[.91 .65 .1 .2],'String',avarage1,'EdgeColor','none')
annotation('textbox',[.91 .6 .1 .2],'String',status1,'EdgeColor','none')

subplot(2,1,2);
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
    avarage2=mean(allpeaksp(EKG(6,:),avg2));
else
    status2="Negative";
    avarage2=mean(allpeaksn(-EKG(6,:),avg2));
end
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
title('aVF Derivation','FontSize', 16)
annotation('textbox',[.91 .22 .1 .2],'String','Average','EdgeColor','none')
annotation('textbox',[.91 .17 .1 .2],'String',avarage2,'EdgeColor','none')
annotation('textbox',[.91 .12 .1 .2],'String',status2,'EdgeColor','none')


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
annotation('textbox',[.91 .0 .5 .2],'String',status3,'EdgeColor','none')

function pk = allpeaksp(y, avg)
  Peaks=[];
  for k = 2:length(y)-1
      if y(k) > 0 %avg
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
      if y(k) < 0 %avg
         if y(k) < y(k-1)
             if y(k) < y(k+1)
                 Peaks=[Peaks y(k)];
             end
         end
      end
  end
  pk = Peaks;
end