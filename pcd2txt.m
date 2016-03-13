category_directory='/Milera_data/cuttleries';
current_path=pwd;                                       % current full path
category_directory=[current_path,category_directory];      % full directory
%----------check if the input is correct form of a directory---------------
if ~isdir(category_directory)
    disp('the input is not a directory');
    return; 
end;
%------------------extract information from input--------------------------
cd (category_directory);              % go to the specified directory
filename=strcat('*.','pcd');          % find all '.txt' files
filename=dir(filename);               % extract the corresponding file names
num_D=size(filename,1);               % the number of point_cloud files in the category

%------------align all other point clouds with the canocial one------------
cd (current_path);                    % come back to the full path 
for i=1:num_D
    %set the first one as the canonical one to align
    data=readPcd([category_directory,'/',filename(i,1).name]);
    data=data(1:end,1:3);
    save([category_directory,'/',num2str(i),'.txt'],'data','-ascii');
end;

