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