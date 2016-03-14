# SLDMRF
## Spatial Latent Dirichlet Markov Random Fields


% --------------------------------------------------------------

%   author: **Hanchen Xiong** @ University of Innsbruck

% --------------------------------------------------------------


Please cite the paper if you use the code in your work: Hanchen Xiong, Sandor Szedmak, Justus Piater, **3D Object Class Geometry Modeling with Spatial Latent Dirichlet Markov Random Fields**. *35th German Conference on Pattern Recognition*, pp. 51–60, 2013. Springer LNCS 8142. 


**Application of SLDMRF for 3D part-based object modeling**. 

``` Matlab
% a simple example to use the code 

% do alignment for all instances within the same category 
[aligned_point_files, pre_aligned_point_files] = category_alignment('/Category_point/motors_m');
% constuct 3D vorcabulary and discrete MRF, by default a 20*20*20 size bounding box is used
[documents,connections,min_3D,interval] = discretization(aligned_point_files);
% the number of segments 
K = 5; 
% number of 3D visual words
V = 20^3; 
[labels,psi,theta]=sldmrf_gibbs_sampler(documents,connections,K,V);

% visualize the segmentations
display_labels_3D(labels,aligned_point_files);

% visualize probabilistic part models
display_theta_3D(theta);
```
![alt text][segmentation]

[segmentation]: https://github.com/HanchenXiong/SLDMRF/blob/master/SLDMRF_motorcycle.png
