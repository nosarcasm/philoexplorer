n = length(out_monday);
for i=1:n
    num(i,1)=out_monday{i,5};
end
K=find(num(:,1)<=60);

m = length(K);
for j=1:m
    index = K(j,1);
    out_monday(index,:)=[];
end 

output_shows = out_monday;

asd=sortrows(out_sunday,5);