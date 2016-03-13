function [U,S] = fast_pca(matrix,h)
%--------------------------------------------------------------------------
% fast pca implementation based on 
% Sharma, Alokanand and Paliwal, K.K. (2007) Fast principal component 
% analysis using fixed-point algorithm. Pattern Recognition Letters, 28 
% (10). pp. 1151-1155. ISSN 0167-8655
%--------------------------------------------------------------------------
d=size(matrix,1);
U=zeros(d,h);     % top h eigenvectors with largest eigenvalues
S=zeros(h);       % top h eigenvalues
for i=1:h
    u=rand(d,1);
    while 1
        u_old=u;
        u=matrix*u;
        temp=zeros(d,1);
        for j=1:i-1
            temp=temp+(u'*U(:,j))*U(:,j);
        end;
        u=u-temp;
        lambda=norm(u);
        u=u/lambda;

        if abs(u'*u_old-1)<0.000001
            U(:,i)=u;
            S(i)=lambda;
            matrix=matrix-lambda*u*u';
            break;
        end;
    end;
end;
end

