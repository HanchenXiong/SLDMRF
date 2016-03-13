function [] = display_theta_3D(theta)
[num_compo,num_dict]=size(theta);         % the number of component in theta
size_box=round(num_dict^(1/3));           % the size of bounding box 
% create the matrices of three views
matrix_1_m=zeros(size_box,size_box);
matrix_2_m=zeros(size_box,size_box);
matrix_3_m=zeros(size_box,size_box);
% creat the bounding volume with grid size_box*size_box*size_box
for i=1:size_box
    for j=1:size_box
        for k=1:size_box
            volume_points(i,j,k)=0;
        end;
    end;
end;
figure;
set(gcf,'position',[400,300,num_compo*300,500]);
% for each unit in bounding volume, a value is speicfied
for k=1:num_compo
    for v=1:num_dict
        index_z=floor(v/(size_box*size_box))+1;
        residual_1=mod(v,size_box*size_box);
        index_y=floor(residual_1/size_box)+1;
        index_x=mod(residual_1,size_box)+1;
        volume_points(index_x,index_y,index_z)=theta(k,v);
    end; 
    matrix_1=sum(volume_points,1);
    matrix_2=sum(volume_points,2);
    for i=1:size_box
        for j=1:size_box
            matrix_1_m(i,j)=matrix_1(1,i,j);
            matrix_2_m(i,j)=matrix_2(i,1,j);
        end;
    end;
    matrix_3=sum(volume_points,3);
    matrix_3_m=matrix_3;
    subplot(3,num_compo,k);
    imagesc(matrix_1_m);
    subplot(3,num_compo,num_compo+k);
    imagesc(matrix_2_m);
    subplot(3,num_compo,num_compo*2+k);
    imagesc(matrix_3_m);
end;
end


