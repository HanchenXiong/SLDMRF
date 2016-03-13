function [transformed,time] = PCA_alignment(source,target,vis)
% asumme that we align data1 with data2
%--------------------------------------------------------------------------
% extract information from data1 and data2
%--------------------------------------------------------------------------
tic
num_1=size(source,1);
num_2=size(target,1);
original_data1=source;
original_data2=target;

%--------------------------------------------------------------------------
% normalized two point clouds in the same reference frameword
%--------------------------------------------------------------------------
data1_mean=mean(source,1);   data2_mean=mean(target,1);     % mean
data1=source-repmat(data1_mean,num_1,1);                    % normalization
data2=target-repmat(data2_mean,num_2,1); 
%--------------------------------------------------------------------------
% set up the kernel parameters
%--------------------------------------------------------------------------
sigma=10*mean(std([data1;data2],0,1));
%--------------------------------------------------------------------------
% compute the kerel matrix of data1 and data_2
%--------------------------------------------------------------------------
K_1=kernel_eval(data1,data1,3,sigma);
K_2=kernel_eval(data2,data2,3,sigma);
%--------------------------------------------------------------------------
% centralization of kernel matrix K_1 and K_2
%--------------------------------------------------------------------------
E_1=ones(num_1,num_1);
K_1_C=K_1-(E_1*K_1)/num_1-(K_1*E_1)/num_1+(E_1*K_1*E_1)/(num_1*num_1);
E_2=ones(num_2,num_2);
K_2_C=K_2-(E_2*K_2)/num_2-(K_2*E_2)/num_2+(E_2*K_2*E_2)/(num_2*num_2);
%--------------------------------------------------------------------------
% apply kernel_pca 
%--------------------------------------------------------------------------
D=3; % the number of eigenvectors used in alignment
alpha1=kernel_pca_2(K_1_C,D);
alpha2=kernel_pca_2(K_2_C,D);
%--------------------------------------------------------------------------
% random select a subset (size=subset_size) of data1  
%--------------------------------------------------------------------------
subset_size=10;
permutation=randperm(num_1);    % random permutation of [1,num_1]
idx=permutation(1:subset_size); % select the first subset_size indices (random selection)
idx=sort(idx); 
subset=data1(idx,1:3);
signs=[  0 0 0;
         0 0 1;
         0 1 0;
         0 1 1;
         1 0 0;
         1 0 1;
         1 1 0;
         1 1 1 ];
%--------------------------------------------------------------------------
% comput \Theta_alpha and corresponding \rho 
%--------------------------------------------------------------------------
Theta=cell(2^D,1);
rho=cell(2^D,1);
for pp=1:2^D
    signed_alpha1(:,1)=alpha1(:,1)*(-1)^signs(pp,1);
    signed_alpha1(:,2)=alpha1(:,2)*(-1)^signs(pp,2);
    signed_alpha1(:,3)=alpha1(:,3)*(-1)^signs(pp,3);
    Theta{pp,1}=(eye(num_2)-ones(num_2)/num_2)*alpha2*signed_alpha1'*(eye(num_1)-ones(num_1)/num_1);
    rho{pp,1}=zeros(num_2,subset_size);
    for i=1:subset_size                
        rho{pp,1}(:,i)=Theta{pp,1}*(K_1(:,idx(i))-K_1*ones(num_1,1)/num_1)+ones(num_2,1)/num_2;
    end;
end;
%--------------------------------------------------------------------------
% prearation for alignment
%--------------------------------------------------------------------------
h_subset=[subset,ones(subset_size,1)]'; % homegeous coordinate of subset points, size is 4 by subset_size 
h_data2=[data2,ones(num_2,1)]';         % homegeous coordinate of data2 points, size is 4 by num_2
h_data1=[data1,ones(num_1,1)]';         % homegeous ccordiante of data1 points, size is 4 by num_1
%--------------------------------------------------------------------------
% begin 2^D loop (2^D possible alignment
%--------------------------------------------------------------------------
best_alignment=cell(2^D,1);            % go through all possible alignments
alignment_error=zeros(2^D,1);          % record the error of each alignemnt
for pp=1:2^D
    cstep=0;           % current step number
    nstep=800;         % the total number of steps
    current_R=eye(3);                              % intial rotation matrix
    current_L=(mean(data2)-mean(data1))';          % intial translation vector
    current_P=[current_R,current_L; 0 0 0 1];      % intial pose matrix
    %----------------------------------------------------------------------
    % gradient ascent iteration on SE(3) manifold
    %----------------------------------------------------------------------
      while cstep<nstep                % stop until itration goes until nstep
        cstep=cstep+1;
        scale=10/(cstep^0.5);              % update scale at every iteration
        h_trans_subset=current_P*h_subset;  % transformed subset points with current pose 
        gradient_w=zeros(1,3);              % gradient w.r.t w
        gradient_v=zeros(1,3);              % gradient w.r.t v

        cross_kernel=kernel_eval(h_trans_subset(1:3,:)',data2,3,sigma);
        cross_kernel=cross_kernel';

        %-----------------the convergence criterion------------------------ 
%        objective_value=sum(sum(FX));
%        if abs(objective_value-old_objective_value)/objective_value<0.001
%       %     cstep
%            break;
%        else 
%            old_objective_value=objective_value;
%        end;
        FX=cross_kernel.*rho{pp,1}';  
        D1=h_trans_subset'.*(FX*ones(num_2,1)*ones(1,4))-FX*h_data2';

        for i=1:subset_size
            gradient_w=gradient_w-D1(i,:)*[-Omega(h_trans_subset(1:3,i));zeros(1,3)]/sigma^2;
            gradient_v=gradient_v-D1(i,:)*[eye(3);zeros(1,3)]/sigma^2;
        end;
        if norm(gradient_w)<0.0001 && norm(gradient_v)<0.0001
            break;
        end;
        w=(gradient_w')*scale;
        v=(gradient_v')*scale;
        exp_Gamma=expm([Omega(w),v;0 0 0 0]);
        current_P=exp_Gamma*current_P;
    end;
    %---------end of the gradient on SE(3)---------------------------------
    % store the tranformed point cloud and corresponding estimated pose
    best_alignment{pp,1}=current_P;
    transformed=current_P*h_data1;
    transformed=transformed(1:3,:)';
    % cacluate the error of the current (pp) alignment
    nearest_neighbour=knnsearch(transformed,data2);   % search the nearest neighbour in data2
    error=0;
    for i=1:num_2
        error=error+norm(data2(i,:)-transformed(nearest_neighbour(i),:)); % compute the accumulated nearest distance
    end; 
    alignment_error(pp)=error;   
end;           
%------------find the alignment with minimial erorr-----------------------
[min_error,min_idx]=min(alignment_error);  
pose=best_alignment{min_idx,1};
transformed=pose*h_data1+repmat([data2_mean';1],1,num_1);
transformed=transformed(1:3,:)';

time=toc
%--------------------------------------------------------------------------
% visualize the source and target point clouds for alignment
%--------------------------------------------------------------------------
if vis~=0
   figure;
   set(gcf,'position',[400,200,750,500]);
   subplot(1,2,1); 
   scatter3(original_data2(:,1),original_data2(:,2),original_data2(:,3),10,'filled','black'); hold on;
%  scatter3(original_data2(:,1),original_data2(:,2),original_data2(:,3),20,'+','black'); hold on;
   scatter3(original_data1(:,1),original_data1(:,2),original_data1(:,3),10,'red');
   set(gca,'xticklabel',[]);
   set(gca,'yticklabel',[]);
   set(gca,'zticklabel',[]);
   axis equal; axis vis3d;
   grid off;
   view(60,40);
% %----------------visualization the correspondence based on the rho---------
%   rho_optimal=rho{min_idx,1};
%   for i=1:subset_size
%       [max_value,max_rho_i_colum]=max(rho_optimal(:,i));  % find the correspondence in the ith column
%       point_data1=original_data1(idx(i),1:3);
%       point_data2=original_data2(max_rho_i_colum,1:3); 
%       point_combine=[point_data1;point_data2];
%       plot3(point_combine(:,1),point_combine(:,2),point_combine(:,3),'green');
%   end;

  
   % -----------visualize the final optimal alignment-------------------------
   subplot(1,2,2); 
   scatter3(target(:,1),target(:,2),target(:,3),10,'filled','black'); hold on;
  % scatter3(target(:,1),target(:,2),target(:,3),20,'+','black'); hold on;
   scatter3(transformed(:,1),transformed(:,2),transformed(:,3),10,'red');
   set(gca,'xticklabel',[]);
   set(gca,'yticklabel',[]);
   set(gca,'zticklabel',[]);
   axis equal; axis vis3d;
   grid off;
   view(60,40);

end;
   %--------------------------------------------------------------------------
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [alpha] = kernel_pca_2(Kernel_matrix,D)
%% output data strucure: 
%alpha=[];
%% eigenvector decomposition of Gram matrix
%[U,S,V]=svd(Kernel_matrix);
%% [U,S] = eigs(Kernel_matrix,D)
%% figure;
%% plot(diag(S));
%% disp(diag(S));
%eigen_vectors=U;
%eigen_values=S;
%% only most principal D eigenvectors are selected;
%for i=1:D
%    temp=eigen_vectors(:,i);
%    lambda=(eigen_values(i,i));
%    temp=temp/(sqrt(lambda));
%    alpha=[alpha,temp];
%end;
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[alpha] =kernel_pca_2(Kernel_matrix,D)
alpha=[];
[U,S]=fast_pca(Kernel_matrix,D);

eigen_vectors=U;
eigen_values=S;
% only most principal D eigenvectors are selected;
for i=1:D
    temp=eigen_vectors(:,i);
    lambda=(eigen_values(i));
    temp=temp/(sqrt(lambda));
    alpha=[alpha,temp];
end;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m]=Omega(w)
if size(w)~=[3,1]
    disp('the input of function Omega is not in right form');
else
    m=zeros(3,3);
    m(1,2)=-w(3);
    m(1,3)=w(2);
    m(2,1)=w(3);
    m(2,3)=-w(1);
    m(3,1)=-w(2);
    m(3,2)=w(1);
end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [K]=kernel_eval(X1,X2,ktype,ipar1,ipar2)
% X1,X2: two data set in which each data is a row, usualy is training set
% and test set 
% ktype: the type of kernel(0-linear 1-polynomial 2-sigmoid 3 Gaussian) 
% ipar1,par2: parameters used in different kernels, e.g. ipar1 is sigma 
% in Gaussian 
%--------------------------------------------------------------------------
    mtrain=size(X1,1);
    mtest=size(X2,1);
  
    d1=sum(X1.^2,2);
    d2=sum(X2.^2,2);

    K=X2*X1'; 
    switch ktype
      case 0     % linear kernel
      case 1     % polynomial
        K=(K+ipar2).^ipar1;
      case 2     % sigmoid
        K=tanh(ipar1*K+ipar2);
      case 3     % Gaussian
        K=d2*ones(1,mtrain)+ones(mtest,1)*d1'-2*K;
        K=exp(-K/(2*(ipar1^2)));
      case 31    % unisotroph Gaussian
        K=d2*ones(1,mtrain)+ones(mtest,1)*d1'-2*K;
        K=exp(-K/(2*(ipar1^2)));
        d1=(d1+0.001).^ipar2;
        d2=(d2+0.001).^ipar2;
        ku=sqrt(d2)*(ones(mtrain,1)./sqrt(d1))';
        ku=abs(log(ku+1));
        K=K./ku;   
    end
end

