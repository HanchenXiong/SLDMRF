function [aligned_point_files, pre_aligned_point_files] = category_alignment(category_directory)
%--------------------------------------------------------------------------
current_path=pwd;                                       % current full path
category_directory=[current_path,category_directory];      % full directory
%----------check if the input is correct form of a directory---------------
if ~isdir(category_directory)
    disp('the input is not a directory');
    return; 
end;
%------------------extract information from input--------------------------
cd (category_directory);              % go to the specified directory
filename=strcat('*.','txt');          % find all '.txt' files
filename=dir(filename);               % extract the corresponding file names
num_D=size(filename,1);               % the number of point_cloud files in the category
%------------------- output -------------------
aligned_point_files=cell(num_D,1);    % output the same number of point clouds
pre_aligned_point_files=cell(num_D,1);
%--------------------------------------------------------------------------

%------------align all other point clouds with the canocial one------------
cd (current_path);                    % come back to the full path 
for i=2:num_D
    %set the first one as the canonical one to align
    [source,target]=datagenerator_2([category_directory,'/',filename(i,1).name],[category_directory,'/',filename(1,1).name]);
    pre_aligned_point_files{i,1}=source;
    [transformed]=PCA_alignment(source,target,1);
    aligned_point_files{i,1}=transformed;
end;
aligned_point_files{1,1}=target;
pre_aligned_point_files{1,1}=target;
end

