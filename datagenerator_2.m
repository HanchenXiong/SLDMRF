function [source,target] = datagenerator_2(filename1,filename2)
%DATAGENERATOR_2 Summary of this function goes here
%   Detailed explanation goes here
pointcloud= load(filename1);
num_point=size(pointcloud,1);

point_mean=mean(pointcloud);                           % mean
pointcloud=pointcloud-repmat(point_mean,num_point,1);  % centralization
point_std=std(pointcloud,1,1);                         % standard deviation
pointcloud=pointcloud/mean(point_std);                 % rescale
source=pointcloud;
source_h=[source,ones(num_point,1)];
% rotation parameters: the angle of yaw, pitch, roll  
phi = rand*100;     % yaw
chi = rand*100;     % pitch
psi = rand*100;     % roll

% tranlation: 
l_x=rand*5;
l_y=rand*5;
l_z=rand*5;

% pose is composed of rotation matrix and translation
pose(1,1)=cos(phi)*cos(chi);
pose(1,2)=cos(phi)*sin(chi)*sin(psi)-sin(phi)*cos(psi);
pose(1,3)=cos(phi)*sin(chi)*cos(psi)+sin(phi)*sin(psi);
pose(1,4)=l_x;
pose(2,1)=sin(phi)*cos(chi);
pose(2,2)=sin(phi)*sin(chi)*sin(psi)+cos(phi)*cos(psi);
pose(2,3)=sin(phi)*sin(chi)*cos(psi)-cos(phi)*sin(psi);
pose(2,4)=l_y;
pose(3,1)=-sin(chi);
pose(3,2)=cos(chi)*sin(psi);
pose(3,3)=cos(chi)*cos(psi);
pose(3,4)=l_z;
pose(4,1)=0;
pose(4,2)=0;
pose(4,3)=0;
pose(4,4)=1;
% disp('rotation:');
% disp(pose(1:3,1:3));
% disp('translation;');
% disp(pose(1:3,4));

source_h=source_h*pose';
source=source_h(:,1:3);



pointcloud= load(filename2);
num_point=size(pointcloud,1);
point_mean=mean(pointcloud);                           % mean
pointcloud=pointcloud-repmat(point_mean,num_point,1);  % centralization
point_std=std(pointcloud,1,1);                         % standard deviation
pointcloud=pointcloud/mean(point_std);                 % rescale
target=pointcloud;

end

