function [ ] = display_category_alignment(aligned_point_files, pre_aligned_point_files )
figure;
set(gcf,'position',[400,100,600,600]);
num_D=size(aligned_point_files,1);
%-----specify color for each point clour scatter-----------
scatter_color=[0.0, 0.6, 0.0;
              0.0, 0.6, 1.0;
              0.8, 1.0, 0.2;
              0.6, 0.0, 0.6;
              1.0, 0.6, 0.0;
              0.6, 0.2, 0.2;
              1.0, 0.2, 0.6;
              0.4, 0.6, 1.0;
              0.8, 1.0, 0.0; 
              1.0, 1.0, 0.2];
              
for i=1:num_D
    %------------------
    subplot(3,2,[1,3,5]); 
    point_cloud=pre_aligned_point_files{i,1};
    scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),10,scatter_color(i,:),'filled'); hold on;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
    axis equal; axis vis3d;
    set(gca,'linewidth',2.5)
    grid off;
    view(60,40);
    %------------------
    subplot(3,2,2);
    point_cloud=aligned_point_files{i,1};
    scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),10,scatter_color(i,:),'filled'); hold on;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
    axis equal; axis vis3d;
    set(gca,'linewidth',2)
    grid off;
    view(0,0);
    
    %------------------
    subplot(3,2,4);
    point_cloud=aligned_point_files{i,1};
    scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),10,scatter_color(i,:),'filled'); hold on;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
    axis equal; axis vis3d;
    set(gca,'linewidth',2)
    grid off;
    view(90,90);
    
    %------------------
    subplot(3,2,6);
    point_cloud=aligned_point_files{i,1};
    scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),10,scatter_color(i,:),'filled'); hold on;
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
    axis equal; axis vis3d;
    set(gca,'linewidth',2)
    grid off;
    view(90,0); 
end

