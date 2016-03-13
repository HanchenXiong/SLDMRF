function [labels,psi,theta]=ldmrf_gibbs_sampler(documents,connections,K,V)
%-------------------------------------------------------------
% author: Hanchen Xiong   University of Innsbruck
%-------------------------------------------------------------

%--------------------------------------------------------------------------
%      extract information from 
%--------------------------------------------------------------------------
% the number of documents in copora 
M=size(documents,1);
% the number of words in each document
N_m=zeros(M,1);
for m=1:M
    N_m(m)=size(documents{m,1},2);
end;
%  the size of bounding box
size_box=round(V^(1/3));
% the class label of words in each document
labels=documents;
% record word-label relationship
word_label=cell(M,1);
% each word in all documents is initialized as lable 0
for m=1:M
    word_label{m,1}=zeros(V,1);
end;


% groups=cell(1,1);
% num_groups=1;
% i=1;
% while 1
%     i=i+1;
%     if i>V
%         break;
%     end;
%     if sum_dict(i)~=0 && sum_dict(i-1)==0
%         num_groups=num_groups+1;
%         new_group=[i,sum_dict(i)];
%         groups=[groups;new_group];
%     elseif sum_dict(i)~=0 && sum_dict(i-1)~=0
%         groups{num_groups,1}=[groups{num_groups,1};[i,sum_dict(i)]];
%     end;
% end;
% num_groups=size(groups,1);
% size_of_group=zeros(num_groups,1);
% for i=1:num_groups
%     size_of_group(i,1)=size(groups{i,1},1);
% end;
% [sorted_size,group_index]=sort(size_of_group,'descend');
% 
% max_K_groups=group_index(1:K);
% Gaussian_means=zeros(K,3);
% for i=1:K
%     group_words=groups{max_K_groups(i),1};
%     words_position=[0,0,0];
%     all_num_words=0;
%     for j=1:size_of_group(max_K_groups(i))
%         word=group_words(j,1);
%         word_z=floor(word/(size_box*size_box))+1;
%         residual_1=mod(word,size_box*size_box);
%         word_y=floor(residual_1/size_box)+1;
%         word_x=mod(residual_1,size_box)+1;
%         num_word=group_words(j,2);
%         words_position=words_position+num_word*[word_x,word_y,word_z];
%         all_num_words=all_num_words+num_word;
%     end;
%     Gaussian_means(i,:)=words_position/all_num_words;
% end;


% -------------------------------------------------------------------------
%  construct output data
% -------------------------------------------------------------------------

psi=zeros(M,K);            % p(topic|m)    |topic|=K, |document|=M
theta=zeros(K,V);          % p(word|topic) |word|=V, |topic|=K

% hyperparameters control 
alpha=0.1*ones(1,K);           % all initialized wiht symmetric paprameters
beta=0.1*ones(1,V);



% threes data structure to recorde the count
N_W_Z=zeros(K,V);  % the count of words (W) which are assigend to topics (Z)
N_Z_D=zeros(M,K);  % the count of topics (Z) which are assigend to documents (D)
N_Z=zeros(K);      % the sum of all count \sum_W{N_W_Z} for each Z
%--------------------------------------------------------------------------
%                        initialization
%--------------------------------------------------------------------------
for m=1:M
    for n=1:N_m(m)
        w=documents{m,1}(n);                     % the index w of word W_{m,n}
        k=find(mnrnd(1,ones(1,K)/K));       % sample a topic associated with word w;
        labels{m,1}(n)=k;                       % label with the selected topic k;
        N_Z_D(m,k)=N_Z_D(m,k)+1;   
        N_W_Z(k,w)=N_W_Z(k,w)+1;   
        N_Z(k)=N_Z(k)+1;
    end;
    % ------------update dictionary-label relationship in document m-------
    word_label_m=zeros(V,1);       % the dictionary-label relationship in document m
    document_m=documents{m,1};
    label_m=labels{m,1};
    while 1
        if size(document_m,2)==0
            break;
        end;
        v_i=document_m(1);                % always pick the first point and it corresponds v_i in dictionary 
        v_i_idx=find(document_m==v_i);    % find the index of all points located in v_i, including the first one itself
        v_i_labels=label_m(v_i_idx);      % find the corresponding labels of points located in v_i
        document_m(v_i_idx)=[];           % remove the point already selected
        label_m(v_i_idx)=[];           
        %-----------majority vote to decide the corresponding label of
        % word v_i 
        %-------------------------------------------------------------
        num_v_i_label=zeros(K,1);       % the number of each label which is assigned to connected words
        for ii=1:size(v_i_labels,2)
            num_v_i_label(v_i_labels(1,ii))=num_v_i_label(v_i_labels(1,ii))+1;
        end;
        [max_num,majority_label]=max(num_v_i_label);
        word_label_m(v_i)=majority_label;
    end;
    word_label{m,1}=word_label_m;
end;

%--------------------------------------------------------------------------
%                     burn-in
%--------------------------------------------------------------------------
% gibbs sampling until converge
cstep=0;
nstep=50;

while cstep<nstep
    cstep=cstep+1
    for m=1:M
        word_label_m=zeros(V,1);       % the dictionary-label relationship in document m
        for n=1:N_m(m)
            w=documents{m,1}(n);       % the index w of word W_{m,n}
            k=labels{m,1}(n);          % the corresponding label (index of topic)
            w_connection=connections{m,1}{w,1};      % the connection of word w in document m 
            
            
            % all count realated word m and topic k are decreased by 1
            N_Z_D(m,k)=N_Z_D(m,k)-1;   
            N_W_Z(k,w)=N_W_Z(k,w)-1;   
            N_Z(k)=N_Z(k)-1;
              
            % -----sampling a new topic label for word W_{m,n}-------------
            
            sample_prob_1=zeros(1,K);  %--------sampling probability of LDA
            for z=1:K
                sum_z_v=N_Z(z)+sum(beta);
                sample_prob_1(z)=((N_W_Z(z,w)+1)/sum_z_v)*(N_Z_D(m,z)+alpha(z));
            end;
            sample_prob_1=sample_prob_1/sum(sample_prob_1);
            
            sample_prob_2=zeros(1,K);  %--------sampling probability of MRF
            num_w_connection=size(w_connection,1);   % the number of connections word w in document m 
            for z=1:K
                sum_potential=0;
                for cc=1:num_w_connection
                    doc_idx=w_connection(cc,1);
                    word_idx=w_connection(cc,2);
                    weight=w_connection(cc,3);
                    %----find the labels of all other connected words------
                    connec_label=word_label{doc_idx,1}(word_idx);
                    if connec_label==z
                        sum_potential=sum_potential+weight;
%                     else
%                         sum_potential=sum_potential-weight;
                    end;    
                end;
                sample_prob_2(z)=exp(sum_potential);
            end;
            sample_prob_2=sample_prob_2/sum(sample_prob_2);
        
            
            % combine the LDA gibbs sampler, MRF gibbbs sampler and
            sample_prob=sample_prob_1.*sample_prob_2;
            norm_sample_prob=sample_prob/sum(sample_prob);
         
            new_l=find(mnrnd(1,norm_sample_prob)); % new label
            
            % updat new label and corresponding counts
            labels{m,1}(n)=new_l;
            N_Z_D(m,new_l)=N_Z_D(m,new_l)+1;   
            N_W_Z(new_l,w)=N_W_Z(new_l,w)+1;   
            N_Z(new_l)=N_Z(new_l)+1;
        end;
        
        % -----------update dictionary-label relationship in document m
        document_m=documents{m,1};
        label_m=labels{m,1};
        while 1
            if size(document_m,2)==0
                break;
            end;
            v_i=document_m(1);                % always pick the first point and it corresponds v_i in dictionary 
            v_i_idx=find(document_m==v_i);    % find the index of all points located in v_i, including the first one itself
            v_i_labels=label_m(v_i_idx);      % find the corresponding labels of points located in v_i
                
            document_m(v_i_idx)=[];           % remove the point already selected
            label_m(v_i_idx)=[];           
            %-----------majority vote to decide the corresponding label of
            % word v_i 
            %-------------------------------------------------------------
            num_v_i_label=zeros(K,1);       % the number of each label which is assigned to connected words
            for ii=1:size(v_i_labels,2)
                num_v_i_label(v_i_labels(1,ii))=num_v_i_label(v_i_labels(1,ii))+1;
            end;
            [max_num,majority_label]=max(num_v_i_label);
            word_label_m(v_i)=majority_label;
        end;
        word_label{m,1}=word_label_m;
    end;
   
   %----------------visualization of parameters theta----------------------
%    if mod(cstep,50)==0
%        for kk=1:K  
%            sum_k_v=sum(N_W_Z(kk,:))+sum(beta);
%            for v=1:V
%                theta(kk,v)=(N_W_Z(kk,v)+beta(v))/sum_k_v;
%            end;
%        end;
%        display_theta_3D(theta);
%    end;
end;
%-----------------------read out parameter theta---------------------------
for kk=1:K  
    sum_k_v=sum(N_W_Z(kk,:))+sum(beta);
    for v=1:V
        theta(kk,v)=(N_W_Z(kk,v)+beta(v))/sum_k_v;
    end;
end;
end
          
  




