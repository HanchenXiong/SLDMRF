function [point_clouds] = synthesis(psi, theta, p,size_box)
point_clouds=zeros(p,3);
for i=1:p
    k=find(mnrnd(1,psi));
    word=find(mnrnd(1,theta(k,:)));
    word_z=ceil(word/(size_box*size_box));
    residual_1=mod(word,size_box*size_box);
    word_y=max(ceil(residual_1/size_box),1);
    if residual_1==0
        word_y=size_box;
    end;
    word_x=mod(residual_1,size_box);
    if word_x==0
        word_x=size_box;
    end;
    point_clouds(i,:)=[word_x,word_y,word_z]+0.2*rand;
end;
scatter3(point_clouds(:,1),point_clouds(:,2),point_clouds(:,3),30,'filled','blue');
axis equal, axis vis3d;
grid off;
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
set(gca,'zticklabel',[]);
end

