%mean tune in time
n = length(abs_thursday);
for i=1:n
    numth(i,1)=abs_thursday{i,6};
end
hth=hist(numth(:,1),500);
pth = 24/500*find(hth==max(hth));


n = length(abs_friday);
for i=1:n
    numf(i,1)=abs_friday{i,6};
end
hf=hist(numf(:,1),500);
pf = 24/500*find(hf==max(hf));

n = length(abs_saturday);
for i=1:n
    numsa(i,1)=abs_saturday{i,6};
end
hsa=hist(numsa(:,1),500);
psa = 24/500*find(hsa==max(hsa));



n = length(abs_sunday);
for i=1:n
    numsu(i,1)=abs_sunday{i,6};
end
hsu=hist(numsu(:,1),500);
psu = 24/500*find(hsu==max(hsu));



n = length(abs_monday);
for i=1:n
    numm(i,1)=abs_monday{i,6};
end
hm=hist(numm(:,1),500);
pm = 24/500*find(hm==max(hm));


n = length(abs_tuesday);
for i=1:n
    numtu(i,1)=abs_tuesday{i,6};
end
htu=hist(numtu(:,1),500);
ptu = 24/500*find(htu==max(htu));

sortnumth=sort(numth);
sortnumf=sort(numf);
sortnumsa=sort(numsa);
sortnumsu=sort(numsu);
sortnumm=sort(numm);
sortnumtu=sort(numtu);

figure;
histfit(sortnumth); title('Thursday Histogram');
figure;
probplot(sortnumth); title('Thursday Probability Plot');
figure;
histfit(sortnumf(84000:134000,1)); title('Friday Histogram');
figure;
probplot(sortnumf); title('Friday Probaility Plot');
figure;
probplot(sortnumf(84000:134000,1)); title('Filtered Friday PP');
figure
histfit(sortnumsa(112730:241765,1)); title('Saturday Histogram');
figure;
probplot(sortnumsa);title('Saturday Probaility Plot');
figure;
probplot(sortnumsa(112730:241765,1));title('Filtered Saturday PP');
figure;
histfit(sortnumsu(150400:423117,1)); title('Sunday Histogram');
figure;
probplot(sortnumsu);title('Sunday Probaility Plot');
figure;
probplot(sortnumsu(150400:423117,1));title('Filtered Sunday PP');
figure;
histfit(sortnumm(83901:145430,1));title('Monday Histogram');
figure;
probplot(sortnumm);title('Monday Probaility Plot');
figure;
probplot(sortnumm(83901:145430,1));title('Filtered Monday PP');
figure;
histfit(sortnumtu(32066:56110,1));title('Tuesday Histogram');
figure;
probplot(sortnumtu);title('Tuesday Probaility Plot');
figure;
probplot(sortnumtu(32066:56110,1));title('Filtered Tuesday PP');

adj_thursday=numth;
adj_friday=numf+24;
adj_saturday=numsa+48;
adj_sunday=numsu+72;
adj_monday=numm+96;
adj_tuesday=numtu+120;

week=[adj_thursday;adj_friday;adj_saturday;adj_sunday;adj_monday;adj_tuesday];
hist(week(1:1418745,1),100);figure(gcf); title('Histogram of All Data');


