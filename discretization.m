function [documents,connections,min_3D,interval] = discretization(point_files)
% point_files:  pointcloud files which are of the same category,point_files
% is organized as cell strucutre with each element as a point cloud;
%
% documents:    transform pointcloud files to the documents of words, which
% are discretized with all points put together

%--------------------------------------------------------------------------
% extract information from input data
%--------------------------------------------------------------------------
num_D=size(point_files,1);     % the number of point_cloud files
documents=cell(num_D,1);       % output the same number of corresponding documents
connections=cell(num_D,1);     % the connection of each point in each document
size_box=20;                   % the size of grid for discretization
%----------put all points together----------
accumulated_points=[];        
for i=1:num_D
    accumulated_points=[accumulated_points; point_files{i,1}];
end;
%----------get the range in 3 dimensions----
min_x=min(accumulated_points(:,1));               
min_y=min(accumulated_points(:,2));
min_z=min(accumulated_points(:,3));
min_3D=[min_x; min_y; min_z];  % output the starting word of the dictionary
range=zeros(3,1);   
for i=1:3
    range(i)=max(accumulated_points(:,i))-min(accumulated_points(:,i));
end;

%--------------------------------------------------------------------------
% transfer the point clouds to documents: each point correpond one of 8000
% words
%--------------------------------------------------------------------------
max_range=max(range);               % the maximum range 
interval=max_range/size_box;        % set the max_range/20 as the width of unit cube
                                    % so there will be 20*20*20=8000 words
num_dict=size_box^3;               % the size of dictionary 
for d=1:num_D
    pointcloud=point_files{d,1};    % the dth point cloud
    num_p_d=size(pointcloud,1);     % the size of dth point cloud
    document_d=zeros(1,num_p_d);    % doucment_d has the same size as dth point cloud
    for i=1:num_p_d
        index_x=max(ceil((pointcloud(i,1)-min_x)/interval),1);
        index_y=max(ceil((pointcloud(i,2)-min_y)/interval),1);
        index_z=max(ceil((pointcloud(i,3)-min_z)/interval),1);
        document_d(i)=(index_z-1)*size_box*size_box+(index_y-1)*size_box+index_x;  
    end;
    documents{d,1}=document_d;
end;

%--------------------------------------------------------------------------
% compute the orientation and gravity center for each word in different
% documents
%--------------------------------------------------------------------------
word_orientation=cell(num_D,1);
word_gravity=cell(num_D,1); 

for d=1:num_D
    pointcloud_d=point_files{d,1};        % the dth point cloud
    pointcloud_d_copy=pointcloud_d;       % since point_cloud is changing at each step, so make a copy
    document_d=documents{d,1};            % the dth document
    v_orientation_d=zeros(num_dict,4);    % orientation of each word in pointcloud_d
    v_gravity_d=zeros(num_dict,3);        % gravity center of each word in pointcloud_d
    while 1
        if size(document_d,2)==0
            break;
        end;
        v_i=document_d(1);                % always pick the first point and it corresponds v_i in dictionary 
        v_i_idx=find(document_d==v_i);    % find the index of all points located in v_i, including the first one itself
        v_i_points=pointcloud_d(v_i_idx,1:3);   % all points located in v_i
        document_d(v_i_idx)=[];                 % remove the point already selected
        pointcloud_d(v_i_idx,:)=[];             % so the lengths of document_d
                                                % and pointcloud_d are
                                                % changing at every step
        v_gravity_d(v_i,1:3)=mean(v_i_points); % gravity center of the word v_i in document_d
        
        nearest_idx_vi=knnsearch(pointcloud_d_copy,v_i_points,'k',20);   % find the 10 nearest neighbour of gravity center of word v_i
        nearest_neighbours_vi=pointcloud_d_copy(nearest_idx_vi,1:3);    
        [U,S]=svd(cov(nearest_neighbours_vi)); 
        if (S(1,1)-S(2,2))<(S(2,2)-S(3,3))
            v_orientation_d(v_i,1:3)=U(:,3)';    % the orientation of word v_i in document_d is computes as an eigenvector
        else
            v_orientation_d(v_i,1:3)=U(:,1)';
        end;
        v_orientation_d(v_i,4)=1;                % inidcate that v_i appears document
        
        
        
%         if size(v_i_idx,2)==1
%             % there is only one point in v_i, then the orientation is
%             % computed with the k nearest neighbours
%             nearest_idx_vi=knnsearch(pointcloud_d_copy,v_i_points,'k',10);
%             nearest_neighbours_vi=pointcloud_d_copy(nearest_idx_vi,1:3);
%             [U,S]=svd(cov(nearest_neighbours_vi)); 
%         else
%             [U,S]=svd(cov(v_i_points));       % compute the eigenvectors of points located in v_i
%         end;
%         
%         if (S(1,1)-S(2,2))<(S(2,2)-S(3,3))
%             v_orientation_d(v_i,1:3)=U(:,3)';    % the orientation of word v_i in document_d is computes as an eigenvector
%         else
%             v_orientation_d(v_i,1:3)=U(:,1)';
%         end;
%         v_orientation_d(v_i,4)=1;              % inidcate that v_i appears document
        
    end;
    word_orientation{d,1}=v_orientation_d;
    word_gravity{d,1}=v_gravity_d;
end;

%--------------------------------------------------------------------------
% construct markov random fields for each word 
%--------------------------------------------------------------------------
% for d=1:num_D
%    connections{d,1}=cell(num_dict,1);
%    for v=1:num_dict
%        connections{d,1}{v,1}=[];
%    end;
% end;
%------------conneciton within markov random field----------
for d=1:num_D
    pointcloud_d=point_files{d,1};         % the dth point cloud
    document_d=documents{d,1};             % the dth document
    v_orientation_d=word_orientation{d,1}; % the orientation of each word in dth document
    v_gravity_d=word_gravity{d,1};         % the gravity center of each word in dth document
    connection_d=cell(num_dict,1);
    
    for i=1:num_dict
        if (v_orientation_d(i,4)==1)       % all below will take place only if the ith word in vocaburarry appears in the document_d
            connection_d_vi=[];            % for different word(i), the number of connection can be different
            %---------------corresponding connection-----------------------
            for dd=1:num_D
                if dd~=d   % go through all point clouds but itself
                    pointcloud_dd=point_files{dd,1};        % ddth point cloud
                    v_i_center=v_gravity_d(i,1:3);          % the gravity of ith word in document_d
                                     
                    nearest_idx=knnsearch(pointcloud_dd,v_i_center);   % search the nearest neighbour of v_i_center in document dd
                    nearest_neighbour=pointcloud_dd(nearest_idx,1:3);  

                    nearest_idx_r=knnsearch(pointcloud_d,nearest_neighbour);  % reversly serach  the nearest neighbour
                    nearest_neighbour_r=pointcloud_d(nearest_idx_r,1:3);

                    if (norm(v_i_center-nearest_neighbour_r)<=2*interval)    % if v_i_center and nearest_neighbour correspond each other
                                                                             % then add a connection between them
                            
                            nearest_idx_v=documents{dd,1}(nearest_idx);      % find the corresponiding word of 'nearest_idx'th point in document dd                                                 
                            weight= abs(v_orientation_d(i,1:3)*word_orientation{dd,1}(nearest_idx_v,1:3)'); 
                            connection_d_vi=[connection_d_vi; dd, nearest_idx_v, weight];  % the connection is defind as triple: the index of document dd, the index of word, and the weight;                                                                                   
                            
                    end;
                end;
            end;          
            %---------------spatial connection-----------------------------
            %----------neighbours along x axis----------
            if mod(i,size_box)>1 && mod(i,size_box)<size_box
                if ismember(i-1,document_d)
                    connection_d_vi=[connection_d_vi; d, i-1,abs(v_orientation_d(i,1:3)*v_orientation_d(i-1,1:3)')]; 
                end;
                if ismember(i+1,document_d)
                    connection_d_vi=[connection_d_vi; d, i+1,abs(v_orientation_d(i,1:3)*v_orientation_d(i+1,1:3)')]; 
                end;
                %----------neighbours along y axis----------
                if ismember(i-size_box,document_d)
                    connection_d_vi=[connection_d_vi; d, i-size_box,abs(v_orientation_d(i,1:3)*v_orientation_d(i-size_box,1:3)')]; 
                end;
                if ismember(i+size_box,document_d)
                    connection_d_vi=[connection_d_vi; d, i+size_box,abs(v_orientation_d(i,1:3)*v_orientation_d(i+size_box,1:3)')];
                end;
                %-----------neighbours along z axis---------
                if ismember(i-size_box*size_box,document_d)
                    connection_d_vi=[connection_d_vi; d, i-size_box*size_box,abs(v_orientation_d(i,1:3)*v_orientation_d(i-size_box*size_box,1:3)')]; 
                end;
                if ismember(i+size_box*size_box,document_d)
                    connection_d_vi=[connection_d_vi; d, i+size_box*size_box,abs(v_orientation_d(i,1:3)*v_orientation_d(i+size_box*size_box,1:3)')]; 
                end;  
            end;
            %--finish the connection of word i in doucment d-----
            connection_d{i,1}=connection_d_vi;
        end;
    end;
    connections{d,1}=connection_d;
end;        
