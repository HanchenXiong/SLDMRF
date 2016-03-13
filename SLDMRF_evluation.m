[instance_category_matrix,confusion_matrix]=SLDMRF_evluation()
confusion_matrix=zeros(5,5);

current_path=pwd;
airplanes_data_directory=[current_path, '/Category_point/airplanes_m/'];
cd airplanes_data_directory;
airplanes_filename=strcat('*.','txt');          % find all '.txt' files
airplanes_filename=dir(airplanes_filename);               % extract the corresponding file names
airplanes_num=size(airplanes_filename,1);       % the number of point_cloud files in the category
canonical_airplane=load(airplanes_filename(1,1).name);

cd current_path;
bikes_data_directory=[current_path, '/Category_point/bikes_m/'];
cd bikes_data_directory;
bikes_filename=strcat('*.','txt');          % find all '.txt' files
bikes_filename=dir(bikes_filename);               % extract the corresponding file names
bikes_num=size(bikes_filename,1);       % the number of point_cloud files in the category
canonical_bike=load(bikes_filename(1,1).name);


cd current_path;
cars_data_directory=[current_path, '/Category_point/cars_m/'];
cd cars_data_directory;
cars_filename=strcat('*.','txt');          % find all '.txt' files
cars_filename=dir(cars_filename);               % extract the corresponding file names
cars_num=size(cars_filename,1);       % the number of point_cloud files in the category
canonical_car=load(cars_filename(1,1).name);


cd current_path;
dogs_data_directory=[current_path, '/Category_point/dogs_m/'];
cd dogs_data_directory;
dogs_filename=strcat('*.','txt');          % find all '.txt' files
dogs_filename=dir(dogs_filename);               % extract the corresponding file names
dogs_num=size(dogs_filename,1);       % the number of point_cloud files in the category
canonical_dog=load(dogs_filename(1,1).name);

cd current_path;
motors_data_directory=[current_path, '/Category_point/motors_m/'];
cd motors_data_directory;
motors_filename=strcat('*.','txt');          % find all '.txt' files
motors_filename=dir(motors_filename);               % extract the corresponding file names
motors_num=size(motors_filename,1);       % the number of point_cloud files in the category
canonical_motor=load(motors_filename(1,1).name);

instance_category_matrix=zeros(5, airplanes_num+bikes_num+cars_num+dogs_num+motors_num);
instance_category_matrix_target=zeros(5, airplanes_num+bikes_num+cars_num+dogs_num+motors_num);
instance_category_matrix_target(1,1:airplanes_num)=1;
instance_category_matrix_target(2,airplanes_num+1:airplanes_num+bikes_num)=1;
instance_category_matrix_target(3,airplaens_num+bikes_num+1:airplaens_num+bikes_num+cars_num)=1;
instance_category_matrix_target(4,airplaens_num+bikes_num+cars_num+1:airplaens_num+bikes_num+cars_num+dogs_num)=1;
instance_category_matrix_target(5,airplaens_num+bikes_num+cars_num+dogs_num+1: airplanes_num+bikes_num+cars_num+dogs_num+motors_num)=1;

cd current_path;
airplanes_part_distribution=load('airplanes_part_distribution.txt');
airplanes_part_weight=load('airplanes_part_weight.txt');

bikes_part_distribution=load('bikes_part_distribution.txt');
bikes_part_weight=load('bikes_part_weight.txt');

cars_part_distribution=load('cars_part_distribution.txt');
cars_part_weight=load('cars_part_weight.txt');

dogs_part_distribution=load('dogs_part_distribution.txt');
dogs_part_weight=load('dogs_part_weight.txt');

motors_part_distribution=load('motors_part_distribution.txt');
motors_part_weight=load('motors_part_weight.txt');

num_airplanes_part=size(airplanes_part_distribution,1);
airplanes_part_weight=mean(airplanes_part_weight);
for i=1:airplanes_num
    points=load([motors_data_directory,motors_filename(1,1).name]);
    aligned_points=PCA_alignment(points,canonical_airplane,1);
    likelihood=1;
    num_points=size(points,1);
    for j=1:num_points
       for k=1:num_num_airplanes_part
           
       end; 
    end;  
end;
