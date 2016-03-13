# SLDMRF
## Spatial Latent Dirichlet Markov Random Fields


% --------------------------------------------------------------

%   author: **Hanchen Xiong** @ University of Innsbruck

% --------------------------------------------------------------


**Application of SLDMRF for 3D part-based object modeling**. 

``` Matlab
% a simple example to use the code 

% do alignment for all instances within the same category 
[aligned_point_files, pre_aligned_point_files] = category_alignment("Category_point/motors_m");
% constuct 3D vorcabulary and discrete MRF, by default a 20*20*20 size bounding box is used
[documents,connections,min_3D,interval] = discretization(aligned_point_files);
% the number of segments 
K = 5; 
% number of 3D visual words
V = 20^3; 
[labels,psi,theta]=ldmrf_gibbs_sampler(documents,connections,K,V);

% visualize the segmentations
display_labels_3D(labels,aligned_point_files);

% visualize probabilistic part models
display_theta_3D(theta);
```
![alt text][segmentation]

[segmentation]: https://github.com/HanchenXiong/SLDMRF/blob/master/SLDMRF_motorcycle.png
