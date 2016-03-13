function [ ] = display_labels_3D(labels,point_clouds)

% get the number of doucments
num_D=size(labels,1);



% ten different color for different labels
scatter_color=[0.0, 0.6, 0.0;
               0.0, 0.6, 1.0;
               0.6, 0.2, 0.2;
               0.8, 0.0, 0.8;
               1.0, 0.6, 0.0;            
               1.0, 0.2, 0.6;
               0.4, 0.6, 1.0;
               0.8, 1.0, 0.0; 
               1.0, 1.0, 0.2;
               0.8, 1.0, 0.2];
for n=1:num_D
    % get the number of words in document
    num_W=size(labels{n,1},2);
    volume_color=zeros(num_W,3); 
    for i=1:num_W
        l=labels{n,1}(1,i);
        volume_color(i,:)=scatter_color(l,:);
    end
    points=point_clouds{n,1};
    figure;
    set(gcf,'color','w');
    scatter3(points(:,1),points(:,2),points(:,3),15,volume_color(:,1:3),'filled')
    axis equal, axis vis3d;
    grid off;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
   % set(gca,'linewidth',2);
    %box on;
    %axis off;
end

