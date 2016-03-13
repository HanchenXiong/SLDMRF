function confusion_matrix(mat,tick)

%%
imagesc(mat);            
colormap(flipud(gray));  
num_class=size(mat,1);
 
textStrings = num2str(mat(:),'%0.2f');
textStrings = strtrim(cellstr(textStrings));
[x,y] = meshgrid(1:num_class);
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center', 'fontsize',20);
midValue = mean(get(gca,'CLim'));
textColors = repmat(mat(:) > midValue,1,3);

set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
 
xlabel('Classifiation with Global Model','fontsize',15);
ylabel('Ground Truth','fontsize',15);
set(gca,'xticklabel',tick,'XAxisLocation','top','fontsize',15);
set(gca,'yticklabel',tick,'fontsize',15);

 



%%
%example
% clc;
% clear;
% figure(1);
% mat = rand(6);
% confusion_matrix(mat,{'label_1','label_2','label_3', 'label_4', 'label_5', 'label_6'});