function [ ] = display_grid(point_cloud)
%DISPLAY_GRID Summary of this function goes here
% point_cloud: N*3 matrxi with each row as a 3D point
range=zeros(3,1);
for i=1:3
    range(i)=max(point_cloud(:,i))-min(point_cloud(:,i));
end;
max_range=max(range); 
interval=max_range/10;

start_point=zeros(3,1);
end_ponit=zeros(3,1);
for i=1:3
    start_point(i)=min(point_cloud(:,i))-(max_range-range(i))/2;
    end_point(i)=max(point_cloud(:,i))+(max_range-range(i))/2;
end;



clf
figure(1);
set(gcf,'Color',[0.6,0.6,0.6]);

for g = start_point(1):interval:end_point(1)
    for i = start_point(3):interval:end_point(3)
        plot3([g g], [start_point(2) end_point(2)], [i, i],'Color',[0.6,0.6,0.6]);
        hold on;
    end
end

for g = start_point(2):interval:end_point(2)
    for i = start_point(3):interval:end_point(3)
        plot3([start_point(1) end_point(1)], [g g], [i, i],'Color',[0.6,0.6,0.6]);
        hold on;
    end
end

for g = start_point(1):interval:end_point(1)
    for i = start_point(2):interval:end_point(2)
        plot3([g g], [i i], [start_point(3) end_point(3)],'Color',[0.6,0.6,0.6]);
        hold on;
    end
end; 

scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),20,'blue','filled');
set(gca,'xtick',[],'ytick',[],'ztick',[]);
%axis tight;
end

